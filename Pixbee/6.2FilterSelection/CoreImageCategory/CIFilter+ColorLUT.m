//
//  CIFilter+ColorLUT.m
//  ColorLUT
//
//  Created by d71941 on 7/16/13.
//  Copyright (c) 2013 huangtw. All rights reserved.
//

#import "CIFilter+ColorLUT.h"
#import <CoreImage/CoreImage.h>
#import <OpenGLES/EAGL.h>

@implementation CIFilter (ColorLUT)

+ (UIImage *)ApplyFilter:(UIImage*)original withColorCube:(NSString*)cubeName
{
    CIFilter *colorCube = [CIFilter colorCubeWithColrLUTImageNamed:cubeName dimension:64];
    CIImage *inputImage = [[CIImage alloc] initWithImage: original];
    [colorCube setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [colorCube outputImage];
    
    CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:(__bridge id)(CGColorSpaceCreateDeviceRGB()) forKey:kCIContextWorkingColorSpace]];
    UIImage *newImage = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
    
    return  newImage;
}


+ (CIFilter *)colorCubeWithColrLUTImageNamed:(NSString *)imageName dimension:(NSInteger)n
{
    UIImage *image = [UIImage imageNamed:imageName];

    int width = CGImageGetWidth(image.CGImage);
    int height = CGImageGetHeight(image.CGImage);
    int rowNum = height / n;
    int columnNum = width / n;

    if ((width % n != 0) || (height % n != 0) || (rowNum * columnNum != n))
    {
        NSLog(@"Invalid colorLUT");
        return nil;
    }

    unsigned char *bitmap = [self createRGBABitmapFromImage:image.CGImage];
    
    if (bitmap == NULL)
    {
        return nil;
    }

    int size = n * n * n * sizeof(float) * 4;
    float *data = malloc(size);
    int bitmapOffest = 0;
    int z = 0;
    for (int row = 0; row <  rowNum; row++)
    {
        for (int y = 0; y < n; y++)
        {
            int tmp = z;
            for (int col = 0; col < columnNum; col++)
            {
                for (int x = 0; x < n; x++) {
                    float r = (unsigned int)bitmap[bitmapOffest];
                    float g = (unsigned int)bitmap[bitmapOffest + 1];
                    float b = (unsigned int)bitmap[bitmapOffest + 2];
                    float a = (unsigned int)bitmap[bitmapOffest + 3];
                    
                    int dataOffset = (z*n*n + y*n + x) * 4;

                    data[dataOffset] = r / 255.0;
                    data[dataOffset + 1] = g / 255.0;
                    data[dataOffset + 2] = b / 255.0;
                    data[dataOffset + 3] = a / 255.0;

                    bitmapOffest += 4;
                }
                z++;
            }
            z = tmp;
        }
        z += columnNum;
    }

    free(bitmap);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorCube"];
    [filter setValue:[NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES] forKey:@"inputCubeData"];
    [filter setValue:[NSNumber numberWithInteger:n] forKey:@"inputCubeDimension"];

    return filter;
}

+ (unsigned char *)createRGBABitmapFromImage:(CGImageRef)image
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmap;
    int bitmapSize;
    int bytesPerRow;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    bytesPerRow   = (width * 4);
    bitmapSize     = (bytesPerRow * height);
    
    bitmap = malloc( bitmapSize );
    if (bitmap == NULL)
    {
        return NULL;
    }
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        free(bitmap);
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmap,
                                     width,
                                     height,
                                     8,
                                     bytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease( colorSpace );
    
    if (context == NULL)
    {
        free (bitmap);
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(context);
    
    return bitmap;
}

@end