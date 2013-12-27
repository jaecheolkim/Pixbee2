//
//  SwapImageView.h
//  Test
//
//  Created by skplanet on 2013. 12. 13..
//  Copyright (c) 2013년 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwapImageView : UIView


@property (nonatomic) BOOL order;
@property (nonatomic, strong) IBOutlet UIImageView   *inView;
@property (nonatomic, strong) IBOutlet UIImageView   *outView;

- (void)swapImage:(UIImage *)image;
- (void)swapImage:(UIImage *)image reverse:(BOOL)reverse;

@end
