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

#import <MatrixKit/MatrixKit.h>

@class RoomMembersViewController;

/**
 `RoomMembersViewController` delegate.
 */
@protocol RoomMembersViewControllerDelegate <NSObject>

/**
 Tells the delegate that the user wants to mention a room member.
 
 @discussion the `RoomMembersViewController` instance is withdrawn automatically.
 
 @param roomMembersViewController the `RoomMembersViewController` instance.
 @param member the room member to mention.
 */
- (void)roomMembersViewController:(RoomMembersViewController *)roomMembersViewController mention:(MXRoomMember*)member;

@end

@interface RoomMembersViewController : MXKRoomMemberListViewController <MXKRoomMemberListViewControllerDelegate, MXKRoomMemberDetailsViewControllerDelegate>

/**
 Enable mention option in member details view. NO by default
 */
@property (nonatomic) BOOL enableMention;

/**
 The delegate for the view controller.
 */
@property (nonatomic) id<RoomMembersViewControllerDelegate> roomMembersViewControllerDelegate;

@end

