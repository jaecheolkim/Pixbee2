//
//  UIImage+Mask.h
//  Pixbee
//
//  Created by jaecheol kim on 1/7/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Addon)
+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
- (UIImage*)fixRotation;
@end
