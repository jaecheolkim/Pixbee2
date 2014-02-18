//
//  CIFilter+ColorLUT.h
//  ColorLUT
//
//  Created by d71941 on 7/16/13.
//  Copyright (c) 2013 huangtw. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIFilter (ColorLUT)

+ (UIImage *)ApplyFilter:(UIImage*)original withColorCube:(NSString*)cubeName;
+ (CIFilter *)colorCubeWithColrLUTImageNamed:(NSString *)imageName dimension:(NSInteger)n;

@end
