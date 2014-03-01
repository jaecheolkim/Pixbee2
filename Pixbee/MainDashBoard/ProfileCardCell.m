//
//  PlayingCardCell.m
//  LXRCVFL Example using Storyboard
//
//  Created by Stan Chang Khin Boon on 3/10/12.
//  Copyright (c) 2012 d--buzz. All rights reserved.
//

#import "ProfileCardCell.h"
#import "UIImageView+WebCache.h"

@implementation ProfileCardCell

- (void)setUserInfo:(NSDictionary *)userInfo
{
    _userInfo = userInfo;
    NSString *userImage = _userInfo[@"UserProfile"];
    NSString *userName = _userInfo[@"UserName"];
    
    int UserID = [_userInfo[@"UserID"] intValue];
    [_profileImageView setImage:[SQLManager getUserProfileImage:UserID]];
     _nameLabel.text = userName;
    
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
   _profileImageView.alpha = highlighted ? 0.75f : 1.0f;
}

- (void)setSelected:(BOOL)selected
{
    NSLog(@"setSelected");
}

@end
