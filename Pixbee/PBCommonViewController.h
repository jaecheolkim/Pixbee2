//
//  PBCommonViewController.h
//  Pixbee
//
//  Created by jaecheol kim on 1/29/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBCommonViewController : UIViewController
@property (strong, nonatomic) UIImageView *bgImageView;
- (void)refreshBGImage:(UIImage*)image;
- (void)refreshNavigationBarColor:(UIColor*)color;
@end
