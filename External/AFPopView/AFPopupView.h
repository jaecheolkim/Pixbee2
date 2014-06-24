//
//  AFPopupView.h
//  AFPopup
//
//  Created by Alvaro Franco on 3/7/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//  https://github.com/AlvaroFranco/AFPopupView 

#import <UIKit/UIKit.h>

@interface AFPopupView : UIView

@property (nonatomic) BOOL hideOnBackgroundTap;

+(AFPopupView *)popupWithView:(UIView *)popupView;

-(void)show;
-(void)hide;

@end