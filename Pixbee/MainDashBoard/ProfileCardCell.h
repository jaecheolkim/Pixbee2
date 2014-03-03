//
//  ProfileCardCell.h
//  Pixbee
//
//  Created by jaecheol kim on 2/26/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ProfileCardCell : UICollectionViewCell

@property (weak, nonatomic) NSDictionary *userInfo;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic) int userColor;

@end

