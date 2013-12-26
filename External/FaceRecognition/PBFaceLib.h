//
//  PBFaceLib.h
//  Pixbee
//
//  Created by jaecheol kim on 12/11/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FaceLib [PBFaceLib sharedInstance]

typedef enum{
    EigenFaceRecognizer,
    FisherFaceRecognizer,
    LBPHFaceRecognizer,
}PBFaceRecognizer;


@protocol PBFaceLibDelegate;

@interface PBFaceLib : NSObject
@property (nonatomic,assign) id<PBFaceLibDelegate> delegate;

+(PBFaceLib*)sharedInstance;

#pragma mark init
- (BOOL)initRecognizer:(PBFaceRecognizer)type models:(NSArray*)models;
- (void)initDetector:(NSString*)accuracy Tacking:(BOOL)tracking;

#pragma mark Recognize Operations
- (NSDictionary *)recognizeFace:(cv::Mat&)image;
- (NSDictionary *)recognizeFaceFromUIImage:(UIImage*)faceImage;

#pragma mark trainModel Operations
- (BOOL)trainModel:(NSArray *)models;

#pragma mark Detect Operations
- (NSArray*)detectFace:(CIImage*)ciImage options:(NSDictionary *)options;


#pragma mark Utils
- (cv::Mat)getFaceImage:(CIImage *)ciImage feature:(CIFaceFeature *)feature orient:(UIImageOrientation)uiImageOrient landscape:(BOOL)isLandScape;
- (NSData *)serializeCvMat:(cv::Mat&)cvMat;

- (CGImageRef)getFaceCGImage:(CIImage *)ciImage bound:(CGRect)faceRect;
- (NSDictionary*)getFaceData:(CIImage *)ciImage bound:(CGRect)faceRect;

- (cv::Mat)UIImageToMat:(UIImage *)image;
- (UIImage*)MatToUIImage:(const cv::Mat&)image;

@end

@protocol PBFaceLibDelegate <NSObject>
@end