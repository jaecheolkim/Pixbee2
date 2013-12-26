//
//  DemoTableControllerViewController.h
//  FPPopoverDemo
//
//  Created by Alvise Susmel on 4/13/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FBFriendControllerDelegate;

@interface FBFriendController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,assign) id<FBFriendControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *searchFriends;
@property (strong, nonatomic) NSString *searchTerm;

- (void)appearPopup:(CGPoint)point reverse:(BOOL)reverse;
- (void)disAppearPopup;
- (void)handleSearchForTerm:(NSString *)searchTerm;

@end

@protocol FBFriendControllerDelegate <NSObject>

- (void)selectedFBFriend:(NSDictionary *)friend;

@end
