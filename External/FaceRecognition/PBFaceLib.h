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
@property (nonatomic, assign) id<PBFaceLibDelegate> delegate;
@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, assign) float unknownPersonThreshold;
@property (nonatomic, strong) CIDetector *faceDetector;

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

- (cv::Mat)getFaceCVData:(CIImage *)ciImage feature:(CIFaceFeature *)face;
- (NSDictionary*)getFaceData:(CIImage *)ciImage feature:(CIFaceFeature *)face;

// 큰 얼굴이 있는 사진에서는 얼굴인식이 잘 안되므로 얼굴 이외의 영역을 패딩(회색 테두리)해 준다.
// 보통 scale 은 1.2로 세팅 해 줄 것임.
- (UIImage *)scaleImage:(CGImageRef)cgImage scale:(float)scale;

- (cv::Mat)UIImageToMat:(UIImage *)image;
- (UIImage*)MatToUIImage:(const cv::Mat&)image;
- (double)getSimilarity:(const cv::Mat)A with:(const cv::Mat)B;
@end

@protocol PBFaceLibDelegate <NSObject>
@end