//
//  PBNavigationBar.m
//  Pixbee
//
//  Created by jaecheol kim on 3/15/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBNavigationBar.h"

@interface PBNavigationBar ()

@property (strong, nonatomic) CALayer *extraColorLayer;

@end

static CGFloat const kDefaultColorLayerOpacity = .7f;
static CGFloat const kSpaceToCoverStatusBars = 64.f;


@implementation PBNavigationBar

#pragma mark - Instance

- (CALayer *)extraColorLayer
{
    if (_extraColorLayer)
        return _extraColorLayer;
    
    _extraColorLayer = [CALayer layer];
    _extraColorLayer.opacity = kDefaultColorLayerOpacity;
    [self.layer addSublayer:_extraColorLayer];
    
    return _extraColorLayer;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Return early if this is an older version of iOS.
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
        return;
    
    if (self.extraColorLayer)
        self.extraColorLayer.frame = CGRectMake(0.f, -kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
    
    [self.extraColorLayer removeFromSuperlayer];
    [self.layer insertSublayer:_extraColorLayer atIndex:1];
}

#pragma mark - UINavigationBar

- (void)setBarTintColor:(UIColor *)barTintColor
{
    [super setBarTintColor:barTintColor];
    
    // Return early if this is an older version of iOS.
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
        return;
    
    self.extraColorLayer.backgroundColor = barTintColor.CGColor;
}

@end
