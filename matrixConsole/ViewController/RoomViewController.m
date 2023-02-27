/*
 Copyright 2014 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RoomViewController.h"

#import "MXKRoomBubbleTableViewCell.h"

#import "AppDelegate.h"

#import "RageShakeManager.h"

@interface RoomViewController ()
{
    // Members list
    id membersListener;
    
    // Voip call options
    UIButton *voipVoiceCallButton;
    UIButton *voipVideoCallButton;
    UIBarButtonItem *voipVoiceCallBarButtonItem;
    UIBarButtonItem *voipVideoCallBarButtonItem;
    
    // the user taps on a member thumbnail
    MXRoomMember *selectedRoomMember;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *showRoomMembersButtonItem;

@property (strong, nonatomic) MXKAlert *actionMenu;

@end

@implementation RoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set room title view
    [self setRoomTitleViewClass:MXKRoomTitleViewWithTopic.class];
    
    // Replace the default input toolbar view with the one based on `HPGrowingTextView`.
    [self setRoomInputToolbarViewClass:MXKRoomInputToolbarViewWithHPGrowingText.class];
    self.inputToolbarView.enableAutoSaving = YES;
    
    // Set rageShake handler
    self.rageShakeManager = [RageShakeManager sharedManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // hide action
    if (self.actionMenu)
    {
        [self.actionMenu dismiss:NO];
        self.actionMenu = nil;
    }
    
    if (self.roomDataSource)
    {
        if (membersListener)
        {
            [self.roomDataSource.room.liveTimeline removeListener:membersListener];
            membersListener = nil;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.childViewControllers)
    {
        // Dispose data source defined for room member list view controller (if any)
        for (id childViewController in self.childViewControllers)
        {
            if ([childViewController isKindOfClass:[RoomMembersViewController class]])
            {
                RoomMembersViewController *viewController = (RoomMembersViewController*)childViewController;
                MXKDataSource *dataSource = [viewController dataSource];
                [viewController destroy];
                [dataSource destroy];
            }
        }
    }
    
    [super viewDidAppear:animated];
    
    if (self.roomDataSource)
    {
        // Set visible room id
        [AppDelegate theDelegate].masterTabBarController.visibleRoomId = self.roomDataSource.roomId;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Reset visible room id
    [AppDelegate theDelegate].masterTabBarController.visibleRoomId = nil;
}

#pragma mark - Override MXKRoomViewController

- (void)displayRoom:(MXKRoomDataSource *)dataSource
{
    // Remove members listener (if any) before changing dataSource.
    if (membersListener)
    {
        [self.roomDataSource.room.liveTimeline removeListener:membersListener];
        membersListener = nil;
    }
    
    if (dataSource)
    {
        // Show the keyboard icon in the cells of the current writers
        dataSource.showTypingNotifications = YES;
    }
    
    [super displayRoom:dataSource];
}

- (void)updateViewControllerAppearanceOnRoomDataSourceState
{
    [super updateViewControllerAppearanceOnRoomDataSourceState];
    
    // Update UI by considering dataSource state
    if (self.roomDataSource && self.roomDataSource.state == MXKDataSourceStateReady)
    {
        // Register a listener for events that concern room members
        if (!membersListener)
        {
            membersListener = [self.roomDataSource.room.liveTimeline listenToEventsOfTypes:@[kMXEventTypeStringRoomMember] onEvent:^(MXEvent *event, MXTimelineDirection direction, id customObject) {
                
                // Consider only live event
                if (direction == MXTimelineDirectionForwards)
                {
                    // Update navigation bar items
                    [self updateNavigationBarButtonItems];
                }
            }];
        }
    }
    else
    {
        // Remove members listener if any.
        if (membersListener)
        {
            [self.roomDataSource.room.liveTimeline removeListener:membersListener];
            membersListener = nil;
        }
    }
    
    // Update navigation bar items
    [self updateNavigationBarButtonItems];
}

- (BOOL)isIRCStyleCommand:(NSString*)string
{
    // Override the default behavior for `/join` command in order to open automatically the joined room
    
    if ([string hasPrefix:kCmdJoinRoom])
    {
        // Join a room
        NSString *roomAlias = [string substringFromIndex:kCmdJoinRoom.length + 1];
        // Remove white space from both ends
        roomAlias = [roomAlias stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // Check
        if (roomAlias.length)
        {
            [self.mainSession joinRoom:roomAlias success:^(MXRoom *room)
             {
                 // Show the room
                 [[AppDelegate theDelegate].masterTabBarController showRoom:room.state.roomId withMatrixSession:self.mainSession];
             } failure:^(NSError *error)
             {
                 NSLog(@"[Console RoomVC] Join roomAlias (%@) failed: %@", roomAlias, error);
                 //Alert user
                 [[AppDelegate theDelegate] showErrorAsAlert:error];
             }];
        }
        else
        {
            // Display cmd usage in text input as placeholder
            self.inputToolbarView.placeholder = @"Usage: /join <room_alias>";
        }
        return YES;
    }
    return [super isIRCStyleCommand:string];
}

- (void)destroy
{
    if (membersListener)
    {
        [self.roomDataSource.room.liveTimeline removeListener:membersListener];
        membersListener = nil;
    }
    
    if (self.actionMenu)
    {
        [self.actionMenu dismiss:NO];
        self.actionMenu = nil;
    }
    
    [super destroy];
}

#pragma mark -

- (void)updateNavigationBarButtonItems
{
    // Update navigation bar buttons according to room members count
    if (self.roomDataSource && self.roomDataSource.state == MXKDataSourceStateReady)
    {
        // Check conditions to display voip call buttons
        if (self.roomDataSource.room.state.joinedMembers.count >= 2 && self.mainSession.callManager)
        {
            if (!voipVoiceCallBarButtonItem || !voipVideoCallBarButtonItem)
            {
                voipVoiceCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
                voipVoiceCallButton.frame = CGRectMake(0, 0, 36, 36);
                UIImage *voiceImage = [UIImage imageNamed:@"voice"];
                [voipVoiceCallButton setImage:voiceImage forState:UIControlStateNormal];
                [voipVoiceCallButton setImage:voiceImage forState:UIControlStateHighlighted];
                [voipVoiceCallButton addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                voipVoiceCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:voipVoiceCallButton];
                
                voipVideoCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
                voipVideoCallButton.frame = CGRectMake(0, 0, 36, 36);
                UIImage *videoImage = [UIImage imageNamed:@"video"];
                [voipVideoCallButton setImage:videoImage forState:UIControlStateNormal];
                [voipVideoCallButton setImage:videoImage forState:UIControlStateHighlighted];
                [voipVideoCallButton addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                voipVideoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:voipVideoCallButton];
            }
            
            _showRoomMembersButtonItem.enabled = YES;
            
            self.navigationItem.rightBarButtonItems = @[_showRoomMembersButtonItem, voipVideoCallBarButtonItem, voipVoiceCallBarButtonItem];
        }
        else
        {
            _showRoomMembersButtonItem.enabled = ([self.roomDataSource.room.state members].count != 0);
            self.navigationItem.rightBarButtonItems = @[_showRoomMembersButtonItem];
        }
    }
    else
    {
        _showRoomMembersButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItems = @[_showRoomMembersButtonItem];
    }
}

#pragma mark - MXKDataSource delegate

- (void)dataSource:(MXKDataSource *)dataSource didRecognizeAction:(NSString *)actionIdentifier inCell:(id<MXKCellRendering>)cell userInfo:(NSDictionary *)userInfo
{
    // Override default implementation in case of long press on avatar
    if ([actionIdentifier isEqualToString:kMXKRoomBubbleCellLongPressOnAvatarView])
    {
        selectedRoomMember = [self.roomDataSource.room.state memberWithUserId:userInfo[kMXKRoomBubbleCellUserIdKey]];
        if (selectedRoomMember)
        {
            [self performSegueWithIdentifier:@"showMemberDetails" sender:self];
        }
    }
    else
    {
        // Keep default implementation for other actions
        [super dataSource:dataSource didRecognizeAction:actionIdentifier inCell:cell userInfo:userInfo];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Keep ref on destinationViewController
    [super prepareForSegue:segue sender:sender];
    
    id pushedViewController = [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"showMemberList"])
    {
        if ([pushedViewController isKindOfClass:[RoomMembersViewController class]])
        {
            RoomMembersViewController* membersController = (RoomMembersViewController*)pushedViewController;
            
            membersController.roomMembersViewControllerDelegate = self;
            membersController.enableMention = YES;
            
            // Dismiss keyboard
            [self dismissKeyboard];
            
            MXKRoomMemberListDataSource *membersDataSource = [[MXKRoomMemberListDataSource alloc] initWithRoomId:self.roomDataSource.roomId andMatrixSession:self.mainSession];
            [membersDataSource finalizeInitialization];
            
            [membersController displayList:membersDataSource];
        }
    }
    else if ([[segue identifier] isEqualToString:@"showMemberDetails"])
    {
        if (selectedRoomMember)
        {
            MXKRoomMemberDetailsViewController *memberViewController = pushedViewController;
            
            // Set rageShake handler
            memberViewController.rageShakeManager = [RageShakeManager sharedManager];
            
            // Set delegate to handle start chat option
            memberViewController.delegate = self;
            memberViewController.enableMention = YES;
            
            [memberViewController displayRoomMember:selectedRoomMember withMatrixRoom:self.roomDataSource.room];
            
            selectedRoomMember = nil;
        }
    }
}

#pragma mark - MXKRoomMemberDetailsViewControllerDelegate

- (void)roomMemberDetailsViewController:(MXKRoomMemberDetailsViewController *)roomMemberDetailsViewController startChatWithMemberId:(NSString *)matrixId completion:(void (^)(void))completion
{
    [[AppDelegate theDelegate] startPrivateOneToOneRoomWithUserId:matrixId completion:completion];
}

- (void)roomMemberDetailsViewController:(MXKRoomMemberDetailsViewController *)roomMemberDetailsViewController mention:(MXRoomMember *)member
{
    [self mention:member];
}

#pragma mark - RoomMembersViewControllerDelegate

- (void)roomMembersViewController:(RoomMembersViewController *)roomMembersViewController mention:(MXRoomMember*)member
{
    [self mention:member];
}

#pragma mark - Action

- (IBAction)onButtonPressed:(id)sender
{
    if (sender == voipVoiceCallButton || sender == voipVideoCallButton)
    {
        BOOL isVideoCall = (sender == voipVideoCallButton);
        NSString *appDisplayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];

        // Check app permissions before placing the call
        [MXKTools checkAccessForCall:isVideoCall
         manualChangeMessageForAudio:[NSString stringWithFormat:[NSBundle mxk_localizedStringForKey:@"microphone_access_not_granted_for_call"], appDisplayName]
         manualChangeMessageForVideo:[NSString stringWithFormat:[NSBundle mxk_localizedStringForKey:@"camera_access_not_granted_for_call"], appDisplayName]
           showPopUpInViewController:self completionHandler:^(BOOL granted) {

               if (granted)
               {
                   [self.roomDataSource.room placeCallWithVideo:isVideoCall];
               }
               else
               {
                   NSLog(@"RoomViewController: Warning: The application does not have the perssion to place the call");
               }
           }];
    }
}

@end


