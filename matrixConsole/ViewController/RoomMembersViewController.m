/*
 Copyright 2015 OpenMarket Ltd
 
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

#import "RoomMembersViewController.h"

#import "AppDelegate.h"
#import "RageShakeManager.h"

@interface RoomMembersViewController ()
{
    /**
     The selected member
     */
    MXRoomMember *selectedMember;
    
    /**
     */
    MXKRoomMemberDetailsViewController *detailsViewController;
}

@end

@implementation RoomMembersViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup `MXKRoomMemberListViewController` properties
    self.rageShakeManager = [RageShakeManager sharedManager];
    
    // The view controller handles itself the selected roomMember
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (detailsViewController)
    {
        [detailsViewController destroy];
        detailsViewController = nil;
    }
}

- (void)dealloc
{
    selectedMember = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setEnableMention:(BOOL)enableMention
{
    if (_enableMention != enableMention)
    {
        _enableMention = enableMention;
        
        if (detailsViewController)
        {
            detailsViewController.enableMention = enableMention;
        }
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Keep ref on destinationViewController
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        if (selectedMember)
        {
            detailsViewController = segue.destinationViewController;
            
            // Set rageShake handler
            detailsViewController.rageShakeManager = [RageShakeManager sharedManager];
            // Set delegate to handle start chat option
            detailsViewController.delegate = self;
            detailsViewController.enableMention = _enableMention;
            
            [detailsViewController displayRoomMember:selectedMember withMatrixRoom:[self.mainSession roomWithRoomId:self.dataSource.roomId]];
        }
    }
}

#pragma mark - MXKRoomMemberListViewControllerDelegate
- (void)roomMemberListViewController:(MXKRoomMemberListViewController *)roomMemberListViewController didSelectMember:(MXRoomMember *)member
{
    // Report the selected member and open details view
    selectedMember = member;
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

#pragma mark - MXKRoomMemberDetailsViewControllerDelegate

- (void)roomMemberDetailsViewController:(MXKRoomMemberDetailsViewController *)roomMemberDetailsViewController startChatWithMemberId:(NSString *)matrixId completion:(void (^)(void))completion
{
    [[AppDelegate theDelegate] startPrivateOneToOneRoomWithUserId:matrixId completion:completion];
}

- (void)roomMemberDetailsViewController:(MXKRoomMemberDetailsViewController *)roomMemberDetailsViewController mention:(MXRoomMember *)member
{
    if (_roomMembersViewControllerDelegate)
    {
        id<RoomMembersViewControllerDelegate> delegate = _roomMembersViewControllerDelegate;
        
        [self withdrawViewControllerAnimated:YES completion:^{
            
            [delegate roomMembersViewController:self mention:member];
            
        }];
    }
}

@end
