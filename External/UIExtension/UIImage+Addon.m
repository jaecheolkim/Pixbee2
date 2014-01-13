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
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, mask_Image.size.width, mask_Image.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease( colorSpace );
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat widthratio = 0;
    CGFloat heightratio = 0;
    
    widthratio = mask_Image.size.width / image.size.width;
    heightratio = mask_Image.size.height / image.size.height;
    
    CGRect rect1 = {{0, 0}, {mask_Image.size.width, mask_Image.size.height}};
    CGRect rect2 = {{-((image.size.width*widthratio)-mask_Image.size.width)/2 , -((image.size.height*heightratio)-mask_Image.size.height)/2}, {image.size.width*widthratio, image.size.height*heightratio}};
    
    CGContextSetShouldAntialias(mainViewContentContext, YES);
    CGContextSetAllowsAntialiasing(mainViewContentContext, YES);
    CGContextSetInterpolationQuality(mainViewContentContext, kCGInterpolationHigh);
    
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

- (UIImage*)fixRotation
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
