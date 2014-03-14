//
//  UIButton+FaceIcon.h
//  Pixbee
//
//  Created by jaecheol kim on 1/7/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton_FaceIcon : UIButton
@property (nonatomic) int UserID;
@property (nonatomic) int index;
@property (nonatomic) CGRect originRect;
@property (nonatomic) BOOL choice;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) UIImage *penTagonProfileImage;

//- (void)setPenTagonProfileImage:(UIImage *)penTagonProfileImage selected:(BOOL)selected;

@end
