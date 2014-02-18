//
//  CJCAnonymousFacesFilter.m
//  CJC.FaceMaskingDemo
//
//  Created by Chris Cavanagh on 11/9/13.
//  Copyright (c) 2013 Chris Cavanagh. All rights reserved.
//

#import "CJCAnonymousFacesFilter.h"
#import <AVFoundation/AVFoundation.h>

@interface CJCAnonymousFacesFilter ()
{
    CIContext *context;
}
@property (nonatomic) CIFilter *anonymize;
@property (nonatomic) CIFilter *blend;
@property (atomic) CIImage *maskImage;

@end

@implementation CJCAnonymousFacesFilter
@synthesize inputImage;
@synthesize inputFacesMetadata;
@synthesize faceImages;

- (CIImage *)outputImage
{
	// Create a pixellated version of the image
	[self.anonymize setValue:inputImage forKey:kCIInputImageKey];

	CIImage *maskImage = self.maskImage;
	CIImage *outputImage = nil;

	if ( maskImage )
	{
		// Blend the pixellated image, mask and original image
		[self.blend setValue:_anonymize.outputImage forKey:kCIInputImageKey];
		[_blend setValue:inputImage forKey:kCIInputBackgroundImageKey];
		[_blend setValue:self.maskImage forKey:kCIInputMaskImageKey];

		outputImage = _blend.outputImage;

		[_blend setValue:nil forKey:kCIInputImageKey];
		[_blend setValue:nil forKey:kCIInputBackgroundImageKey];
		[_blend setValue:nil forKey:kCIInputMaskImageKey];
	}
	else
	{
		outputImage = _anonymize.outputImage;
	}

	[_anonymize setValue:nil forKey:kCIInputImageKey];

	return outputImage;
}

- (CIFilter *)anonymize
{
	if ( !_anonymize )
	{
//		_anonymize = [CIFilter filterWithName:@"CIGaussianBlur"];
//		[_anonymize setValue:@( 40 ) forKey:kCIInputRadiusKey];

		_anonymize = [CIFilter filterWithName:@"CIPixellate"];
		[_anonymize setValue:@( 40 ) forKey:kCIInputScaleKey];
	}

	return _anonymize;
}

- (CIFilter *)blend
{
	if ( !_blend )
	{
		_blend = [CIFilter filterWithName:@"CIBlendWithMask"];
	}

	return _blend;
}

- (void)setInputFacesMetadata:(NSArray *)theInputFacesMetadata
{
	inputFacesMetadata = theInputFacesMetadata;

	self.maskImage = theInputFacesMetadata ? [self createMaskImageFromMetadata:theInputFacesMetadata] : nil;
}

- (UIImage *)Crop:(CGRect)rect
{
    NSLog(@"Crop Rect : %@", NSStringFromCGRect(rect) );
//    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
//    CIVector *cropRect = [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height];
//    [cropFilter setValue:inputImage forKey:@"inputImage"];
//    [cropFilter setValue:cropRect forKey:@"inputRectangle"];
//    CIImage *croppedImage = cropFilter.outputImage;
    
    context = [CIContext contextWithOptions:nil];
    float _size = (rect.size.width > rect.size.height)? rect.size.height : rect.size.width ;
    CGRect _rect = CGRectMake(rect.origin.x, rect.origin.y, _size, _size);
    CGImageRef cgImg = [context createCGImage:inputImage fromRect:_rect];
    
    UIImage *returnedImage = [UIImage imageWithCGImage:cgImg scale:1.0f orientation:UIImageOrientationUp];
    
    CGImageRelease(cgImg);
//    [cropFilter setValue:nil forKey:@"inputImage"];
    return returnedImage;
}


- (CIImage *) createMaskImageFromMetadata:(NSArray *)metadataObjects
{
	CIImage *maskImage = nil;
    
    [self setFaceImages:[NSMutableArray array]];
    
	for ( AVMetadataObject *object in metadataObjects )
	{
		if ( [[object type] isEqual:AVMetadataObjectTypeFace] )
		{
			AVMetadataFaceObject* face = (AVMetadataFaceObject*)object;
			CGRect faceRectangle = [face bounds];
            float faceAngle = (face.hasRollAngle) ? [face rollAngle] : 0;
            
			CGFloat height = inputImage.extent.size.height;
			CGFloat width = inputImage.extent.size.width;

			CGFloat centerY = ( height * ( 1 - ( faceRectangle.origin.x + faceRectangle.size.width / 2.0 ) ) );
			CGFloat centerX = width * ( 1 - ( faceRectangle.origin.y + faceRectangle.size.height / 2.0 ) );
			CGFloat radiusX = width * ( faceRectangle.size.width / 1.5 );
			CGFloat radiusY = height * ( faceRectangle.size.height / 1.5 );

            CIImage *circleImage = [self createCircleImageWithCenter:CGPointMake( centerX, centerY )
															  radius:CGVectorMake( radiusX, radiusY )
															   angle:faceAngle];
            
            CGRect rect = CGRectMake(width * (1-faceRectangle.origin.y), height * (1-faceRectangle.origin.y),
                                     width * faceRectangle.size.height, height * faceRectangle.size.width);
            

            
            

			maskImage = [self compositeImage:circleImage ontoBaseImage:maskImage];
            
            
            UIImage *_faceImage = [self Crop:circleImage.extent];
            if(_faceImage)
                [self.faceImages addObject:_faceImage];
            
		}
	}

	return maskImage;
}

- (CIImage *) createCircleImageWithCenter:(CGPoint)center
								   radius:(CGVector)radius
									angle:(CGFloat)angle
{
	CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient" keysAndValues:
								@"inputRadius0", @(radius.dx),
								@"inputRadius1", @(radius.dx + 1.0f ),
								@"inputColor0", [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
								@"inputColor1", [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
								kCIInputCenterKey, [CIVector vectorWithX:0 Y:0],
								nil];

	CGAffineTransform transform = CGAffineTransformMakeTranslation( center.x, center.y );
	transform = CGAffineTransformRotate( transform, angle );
	transform = CGAffineTransformScale( transform, 1.2, 1.6 );

	CIFilter *maskScale = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:
						   kCIInputImageKey, radialGradient.outputImage,
						   kCIInputTransformKey, [NSValue valueWithBytes:&transform objCType:@encode( CGAffineTransform )],
						   nil];

	return [maskScale valueForKey:kCIOutputImageKey];
}

- (CIImage *) compositeImage:(CIImage *)ciImage
			   ontoBaseImage:(CIImage *)baseImage
{
	if ( nil == baseImage ) return ciImage;

	CIFilter *filter = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
						kCIInputImageKey, ciImage,
						kCIInputBackgroundImageKey, baseImage,
						nil];

	return [filter valueForKey:kCIOutputImageKey];
}

@end