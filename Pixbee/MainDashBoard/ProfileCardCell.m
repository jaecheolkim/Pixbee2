//
//  ProfileCardCell.m
//  Pixbee
//
//  Created by jaecheol kim on 2/26/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//


#import "ProfileCardCell.h"
#import "UIImageView+WebCache.h"

@interface ProfileCardCell ()
{
}
@end

@implementation ProfileCardCell

- (void)setUserInfo:(NSDictionary *)userInfo
{
    _userInfo = userInfo;
    
    NSString *userName = _userInfo[@"UserName"];
    
    int UserID = [_userInfo[@"UserID"] intValue];
    
    int colorValue = 0;
    if(!IsEmpty(_userInfo[@"color"])) {
        colorValue = [_userInfo[@"color"] intValue] ;
    }
    
    [self setUserColor:colorValue];

    [_profileImageView setImage:[SQLManager getUserProfileImage:UserID]];
     _nameLabel.text = userName;
}

- (void)setUserColor:(int)userColor
{
    UIColor *color = [SQLManager getUserColor:userColor];
    [_nameLabel setBackgroundColor:color];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
   _profileImageView.alpha = highlighted ? 0.75f : 1.0f;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(self.selected) _checkImageView.image = [UIImage imageNamed:@"checked"];
    else _checkImageView.image = [UIImage imageNamed:@"checkbox"];
}

@end
