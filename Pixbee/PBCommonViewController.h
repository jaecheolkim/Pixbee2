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
@property (strong, nonatomic) UIView *colorBar;
@property (weak, nonatomic) UITextField *inputTextField;

- (void)refreshBGImage:(UIImage*)image;
- (void)refreshNavigationBarColor:(UIColor*)color;
- (UIImageView *)getSnapShot;


// UIKeyboard Protocol
-(void)keyboardWillShow:(NSNotification*)notification;
-(void)keyboardDidShow:(NSNotification*)notification;
-(void)keyboardWillHide:(NSNotification*)notification;
-(void)keyboardDidHide:(NSNotification*)notification;

// ColorButton Protocol
- (void)colorButtonHandler:(id)sender;
@end
