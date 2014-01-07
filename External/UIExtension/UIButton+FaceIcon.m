//
//  UIButton+FaceIcon.m
//  Pixbee
//
//  Created by jaecheol kim on 1/7/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "UIButton+FaceIcon.h"
#import "UIImage+Addon.h"

@implementation UIButton_FaceIcon

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setProfileImage:(UIImage *)profileImage
{
    UIImage *image = [UIImage maskImage:profileImage
                               withMask:[UIImage imageNamed:@"photo_profile_hive.png"]];
    _profileImage = image;
    [self setImage:_profileImage forState:UIControlStateNormal];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
