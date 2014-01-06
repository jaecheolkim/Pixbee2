//
//  UIImage+Mask.m
//  Pixbee
//
//  Created by jaecheol kim on 1/7/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "UIImage+Addon.h"

@implementation UIImage (Addon)
//+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
//{
//    
//	CGImageRef maskRef = maskImage.CGImage;
//    
//	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                        CGImageGetHeight(maskRef),
//                                        CGImageGetBitsPerComponent(maskRef),
//                                        CGImageGetBitsPerPixel(maskRef),
//                                        CGImageGetBytesPerRow(maskRef),
//                                        CGImageGetDataProvider(maskRef), NULL, false);
//    
//	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
//    CGImageRelease(mask);
//    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
//    CGImageRelease(masked);
//    
//	return maskedImage;
//}

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)mask_Image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //UIImage *maskImage = maskImage1;
    CGImageRef maskImageRef = [mask_Image CGImage];
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, mask_Image.size.width, mask_Image.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat widthratio = 0;
    CGFloat heightratio = 0;
    
    widthratio = mask_Image.size.width / image.size.width;
    heightratio = mask_Image.size.height / image.size.height;
    
    CGRect rect1 = {{0, 0}, {mask_Image.size.width, mask_Image.size.height}};
    CGRect rect2 = {{-((image.size.width*widthratio)-mask_Image.size.width)/2 , -((image.size.height*heightratio)-mask_Image.size.height)/2}, {image.size.width*widthratio, image.size.height*heightratio}};
    
    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    CGContextDrawImage(mainViewContentContext, rect2, image.CGImage);
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
    
}
@end
