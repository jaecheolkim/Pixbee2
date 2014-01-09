//
//  UIView+Hexagon.m
//  Hexagon
//
//  Created by 호석 이 on 2013. 12. 22..
//
//

#import "UIView+Hexagon.h"

@implementation UIView (Hexagon)

- (void)configureLayerForHexagon
{
    UIImage *maskImage = [UIImage imageNamed:@"photo_profile_hive@2x.png"];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.frame = self.bounds;
    maskLayer.contents = (__bridge id)([maskImage CGImage]);
//    CGFloat width = self.frame.size.width;
//    CGFloat height = self.frame.size.height;
//    CGFloat hPadding = width * 1 / 8 / 2;
//    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(width/2, 0)];
//    [path addLineToPoint:CGPointMake(width - hPadding, height / 4)];
//    [path addLineToPoint:CGPointMake(width - hPadding, height * 3 / 4)];
//    [path addLineToPoint:CGPointMake(width - hPadding, height / 4)];
//    [path addLineToPoint:CGPointMake(width - hPadding, height * 3 / 4)];
//    [path addLineToPoint:CGPointMake(width / 2, height)];
//    [path addLineToPoint:CGPointMake(hPadding, height * 3 / 4)];
//    [path addLineToPoint:CGPointMake(hPadding, height / 4)];
//    [path closePath];
//    [path fill];
//    maskLayer.path = path.CGPath;
    
    self.layer.mask = maskLayer;
}

@end
