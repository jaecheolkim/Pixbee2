//
//  ProfileCardCell.h
//  Pixbee
//
//  Created by jaecheol kim on 2/26/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//


#import <UIKit/UIKit.h>
@protocol ProfileCardCellDelegate;
@interface ProfileCardCell : UICollectionViewCell
@property (nonatomic,assign) id<ProfileCardCellDelegate> delegate;

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blackOverlay;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (assign, nonatomic) int userColor;

- (void)resetFontShape;
@end

@protocol ProfileCardCellDelegate <NSObject>

- (void)nameDidBeginEditing:(ProfileCardCell *)cell;
- (void)nameDidEndEditing:(ProfileCardCell *)cell;
- (void)nameDidChange:(ProfileCardCell *)cell;

@end


