//
//  UserCell.h
//  Pixbee
//
//  Created by skplanet on 2013. 12. 3..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@protocol UserCellDelegate;

@interface UserCell : UITableViewCell

@property (nonatomic,assign) id<UserCellDelegate> delegate;
// 기본상태
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIcon;
@property (strong, nonatomic) UIImageView *borderView;

// 에디트 상태
@property (strong, nonatomic) IBOutlet UITextField *inputName;
@property (strong, nonatomic) IBOutlet UIImageView *lineView;
@property (strong, nonatomic) IBOutlet UIButton *trashButton;

// Selection
@property (strong, nonatomic) IBOutlet UIImageView *checkIcon;


- (IBAction)editButtonClickHandler:(id)sender;
- (IBAction)deleteButtonClickHandler:(id)sender;
- (IBAction)doneButtonClickHandler:(id)sender;

- (void)updateBorder:(NSIndexPath *)indexPath;
- (void)updateCell:(NSDictionary *)user count:(NSUInteger)count;

@end

@protocol UserCellDelegate <NSObject>

- (void)editUserCell:(UserCell *)cell;
- (void)frientList:(UserCell *)cell appear:(BOOL)show;
- (void)doneUserCell:(UserCell *)cell;
- (void)deleteUserCell:(UserCell *)cell;
- (void)searchFriend:(UserCell *)cell name:(NSString *)name;

@end
