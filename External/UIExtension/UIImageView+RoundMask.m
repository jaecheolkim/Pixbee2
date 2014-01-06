//
//  UIImageView+RoundMask.m
//  matchme
//
//  Created by jaecheol kim on 10/25/13.
//  Copyright (c) 2013 jaecheol kim. All rights reserved.
//

#import "UIImageView+RoundMask.h"

@implementation UIImageView (RoundMask)

- (void)roundMask:(UIImage *)_image
{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.image = _image;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 50.0;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 3.0f;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
    self.clipsToBounds = YES;
}



 @end
