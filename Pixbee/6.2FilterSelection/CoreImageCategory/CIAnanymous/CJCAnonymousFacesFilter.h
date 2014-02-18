//
//  CJCAnonymousFacesFilter.h
//  CJC.FaceMaskingDemo
//
//  Created by Chris Cavanagh on 11/9/13.
//  Copyright (c) 2013 Chris Cavanagh. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CJCAnonymousFacesFilter : CIFilter
{
	CIImage *inputImage;
}

@property (nonatomic) CIImage *inputImage;
@property (nonatomic) NSArray *inputFacesMetadata;
@property (nonatomic, strong)NSMutableArray *faceImages;

@end