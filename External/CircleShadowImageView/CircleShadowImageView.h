//
//  CircleShadowImageView.h
//  CircleShadowImageView
//
//  Created by Josh Holtz on 1/30/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleShadowImageView : UIImageView

- (void)setShadow:(UIColor*)shadowColor shadowOffset:(CGSize)offset shadowOpacity:(CGFloat)opacity shadowRadius:(CGFloat)radius;

@end


//#import "CircleShadowImageView.h"
//
//@interface ViewController ()
//
//@property (nonatomic, strong) CircleShadowImageView *circleChadowImageView;
//
//@end
//
//@implementation ViewController
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    // Create with coooddeeezzzzzzz
//    _circleChadowImageView = [[CircleShadowImageView alloc] initWithFrame:CGRectMake(50.0f, 150.0f, 220.0f, 220.0f)];
//    [_circleChadowImageView setImage:[UIImage imageNamed:@"bandit-square"]];
//    [_circleChadowImageView setShadow:[UIColor colorWithRed:0.1f green:0.2f blue:0.4f alpha:1.0f]
//                         shadowOffset:CGSizeMake(7.0f, 7.0f)
//                        shadowOpacity:0.8f
//                         shadowRadius:15.0f];
//    [self.view addSubview:_circleChadowImageView];
//    
//    // OR could init with image
//    //    _circleChadowImageView = [[CircleShadowImageView alloc] initWithImage:[UIImage imageNamed:@"bandit-square"] highlightedImage:[UIImage imageNamed:@"josh-square"]];
//    
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [_circleChadowImageView setHighlighted:YES];
//}
