//
//  PBFaceLib.m
//  PBFaceLib
//
//  Created by jaecheol kim on 12/26/13.
//  Copyright (c) 2013 jaecheol kim. All rights reserved.
//

#import "PBFaceLib.h"
//#import "OpenCVData.h"
#import "opencv2/highgui/ios.h"
#include "opencv2/contrib/retina.hpp"

//#import "CustomFaceRecognizer.h"
#import "retinex.h"


#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

using namespace std;
using namespace cv;


@interface PBFaceLib ()
{
    CGColorSpaceRef colorSpace;
    cv::Ptr<cv::FaceRecognizer> _model;
    PBFaceRecognizer currentRecognizerType;
}

@property (nonatomic, strong) CIContext *context;

@end


@implementation PBFaceLib
@synthesize delegate;

// 초기화.
- (id)init {
	if ((self = [super init])) {
        _unknownPersonThreshold = 0.0f;
        _context = [CIContext contextWithOptions:nil];
        colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	return self;
}

+ (PBFaceLib *)sharedInstance {
    static dispatch_once_t pred;
    static PBFaceLib *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[PBFaceLib alloc] init];
    });
    return sharedInstance;
}


- (BOOL)initRecognizer:(PBFaceRecognizer)recognizerType models:(NSArray*)models
{
    if(_model.empty()) {
    //if(_model == nullptr) {
        switch (recognizerType) {
            case EigenFaceRecognizer:
                //_faceRecognizer = [[CustomFaceRecognizer alloc] initWithEigenFaceRecognizer];
                _unknownPersonThreshold = 0.5f;
                _model = cv::createEigenFaceRecognizer();
                break;
            case FisherFaceRecognizer:
                //_faceRecognizer = [[CustomFaceRecognizer alloc] initWithFisherFaceRecognizer];
                _unknownPersonThreshold = 0.7f;
                _model = cv::createFisherFaceRecognizer();
                break;
            case LBPHFaceRecognizer:
                //_faceRecognizer = [[CustomFaceRecognizer alloc] initWithLBPHFaceRecognizer];
                _unknownPersonThreshold = 0.6f;
                _model = cv::createLBPHFaceRecognizer();
                break;
            default:
                break;
        }
        int num_components = 0;// _model->getInt("num_components");
        double threshold = _model->getDouble("threshold");
        std::string name = _model->name();
        _modelName = @(name.c_str());
        NSLog(@"Active Model = %@ / componets = %d / threshold = %f", _modelName, num_components, threshold);
        currentRecognizerType = recognizerType;
        
        return [self trainModel:models];
        
    } else {
        NSLog(@"already exist model");
        //return [self updateModel:models];
        return [self trainModel:models];
    }

    
    
    
    //return [_faceRecognizer trainModel:models];
    
}

- (cv::Mat)dataToMat:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height
{
    cv::Mat output = cv::Mat([width intValue], [height intValue], CV_8UC1);
    output.data = (unsigned char*)data.bytes;
    
    return output;
}

- (BOOL)trainModel:(NSArray *)models
{
    if(IsEmpty(models)) return NO;
    
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    for(NSDictionary *model in models){
        int UserID = [model[@"UserID"] intValue];
        NSData *imageData = model[@"imageData"];
        
        // Then convert NSData to a cv::Mat. Images are standardized into 100x100
        cv::Mat faceData = [self dataToMat:imageData
                                     width:@100 //[NSNumber numberWithInt:100]
                                    height:@100]; //[NSNumber numberWithInt:100]];
        // Put this image into the model
        images.push_back(faceData);
        labels.push_back(UserID);
        
    }
    
    if (images.size() > 0 && labels.size() > 0) {
        _model->train(images, labels);
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)trainModel:(NSArray *)models withOut:(NSMutableArray*)exceptIDs
{
    if(IsEmpty(models) || IsEmpty(exceptIDs)) return NO;
    
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    for(NSDictionary *model in models){
        int UserID = [model[@"UserID"] intValue];
        if(![exceptIDs containsObject:@(UserID)]) {
        //if(UserID != exceptID){
            NSLog(@"UserID = %d model Added..", UserID);
            NSData *imageData = model[@"imageData"];
            
            // Then convert NSData to a cv::Mat. Images are standardized into 100x100
            cv::Mat faceData = [self dataToMat:imageData
                                         width:@100 //[NSNumber numberWithInt:100]
                                        height:@100]; //[NSNumber numberWithInt:100]];
            // Put this image into the model
            images.push_back(faceData);
            labels.push_back(UserID);
        }

        
    }
    
    if (images.size() > 0 && labels.size() > 0) {
        _model->train(images, labels);
        return YES;
    }
    else {
        return NO;
    }
   
}

- (BOOL)updateModel:(NSArray *)models
{
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    for(NSDictionary *model in models){
        int UserID = [[model objectForKey:@"UserID"] intValue];
        NSData *imageData = [model objectForKey:@"imageData"];
        
        // Then convert NSData to a cv::Mat. Images are standardized into 100x100
        cv::Mat faceData = [self dataToMat:imageData
                                     width:[NSNumber numberWithInt:100]
                                    height:[NSNumber numberWithInt:100]];
        // Put this image into the model
        images.push_back(faceData);
        labels.push_back(UserID);
        
    }
    
    if (images.size() > 0 && labels.size() > 0) {
        _model->update(images, labels);
        return YES;
    }
    else {
        return NO;
    }
}

- (void)initDetector:(NSString*)accuracy Tacking:(BOOL)tracking
{
    @synchronized(self.faceDetector) {
        if(self.faceDetector) [self setFaceDetector:nil];
        NSDictionary *detectorOptions = @{ CIDetectorAccuracy : accuracy, CIDetectorTracking : @(tracking) };
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        [self setFaceDetector:detector];
    }

}

#pragma mark Recognize Operations
- (NSDictionary *)recognizeFace:(cv::Mat&)image
{

    int identity = -1;
    double confidence =0.0, similarity = 0.0;
    UIImage *reconst = nil;
    
    // LBP Algorithm modelName
    if(currentRecognizerType == LBPHFaceRecognizer){
        _model->predict(image, identity, confidence);
        
    }
    // FisherFace or EigenFace Algorithm
    else {
        // Generate a face approximation by back-projecting the eigenvectors & eigenvalues.
        
        cv::Mat reconstructedFace = [self reconstructFace:image];
        
        //similarity = getSimilarity(image, reconstructedFace);
        similarity = [self getSimilarity:image with:reconstructedFace];
        
        reconst = [self MatToUIImage:reconstructedFace];
        reconstructedFace.release();
        // Crop the confidence rating between 0.0 to 1.0, to show in the bar.
        confidence = 1.0 - cv::min(cv::max(similarity, 0.0), 1.0);
        
        if (similarity < _unknownPersonThreshold) {
            // Identify who the person is in the preprocessed face image.
            identity = _model->predict(image);
        }
        else {
            // Since the confidence is low, assume it is an unknown person.
            identity = -1;
        }
    }
    
    NSDictionary *d = @{     @"currentRecognizerType" : @(currentRecognizerType),
                             @"similarity" : @(similarity),
                             @"reconstruct" : ObjectOrNull(reconst),
                             @"UserID": @(identity), //[NSNumber numberWithInt:identity],
                             @"confidence": @(confidence) //[NSNumber numberWithDouble:confidence]
                             };
    

    
    return d;
    
}

- (NSDictionary *)recognizeFaceFromUIImage:(UIImage*)faceImage
{
    cv::Mat cvImage = [self UIImageToMat:faceImage];
    cv::resize(cvImage, cvImage, cv::Size(100, 100), 0, 0);
    NSDictionary *result = [self recognizeFace:cvImage];
    cvImage.release();
    return result;
    //    NSDictionary *match = [_faceRecognizer recognizeFace:cvImage];
    //    return match;
}

#pragma mark Detect Operations
- (NSArray*)detectFace:(CIImage*)ciImage options:(NSDictionary *)options
{
    NSArray *features = nil;
    @synchronized(self.faceDetector) {
        if(!self.faceDetector){
            [FaceLib initDetector:CIDetectorAccuracyLow Tacking:NO];
        }
        if(self.faceDetector && ciImage){
            features = [self.faceDetector featuresInImage:ciImage options:options];
        }
        
    }

    return features;
}



#pragma mark Utils

// Histogram Equalize seperately for the left and right sides of the face.

void equalizeLeftAndRightHalves(Mat &faceImg)

{
    
    // It is common that there is stronger light from one half of the face than the other. In that case,
    
    // if you simply did histogram equalization on the whole face then it would make one half dark and
    
    // one half bright. So we will do histogram equalization separately on each face half, so they will
    
    // both look similar on average. But this would cause a sharp edge in the middle of the face, because
    
    // the left half and right half would be suddenly different. So we also histogram equalize the whole
    
    // image, and in the middle part we blend the 3 images together for a smooth brightness transition.
    
    
    
    int w = faceImg.cols;
    
    int h = faceImg.rows;
    
    
    
    // 1) First, equalize the whole face.
    
    Mat wholeFace;
    
    equalizeHist(faceImg, wholeFace);
    
    
    
    // 2) Equalize the left half and the right half of the face separately.
    
    int midX = w/2;
    
    Mat leftSide = faceImg(cv::Rect(0,0, midX,h));
    
    Mat rightSide = faceImg(cv::Rect(midX,0, w-midX,h));
    
    equalizeHist(leftSide, leftSide);
    
    equalizeHist(rightSide, rightSide);
    
    
    
    // 3) Combine the left half and right half and whole face together, so that it has a smooth transition.
    
    for (int y=0; y<h; y++) {
        
        for (int x=0; x<w; x++) {
            
            int v;
            
            if (x < w/4) {          // Left 25%: just use the left face.
                
                v = leftSide.at<uchar>(y,x);
                
            }
            
            else if (x < w*2/4) {   // Mid-left 25%: blend the left face & whole face.
                
                int lv = leftSide.at<uchar>(y,x);
                
                int wv = wholeFace.at<uchar>(y,x);
                
                // Blend more of the whole face as it moves further right along the face.
                
                float f = (x - w*1/4) / (float)(w*0.25f);
                
                v = cvRound((1.0f - f) * lv + (f) * wv);
                
            }
            
            else if (x < w*3/4) {   // Mid-right 25%: blend the right face & whole face.
                
                int rv = rightSide.at<uchar>(y,x-midX);
                
                int wv = wholeFace.at<uchar>(y,x);
                
                // Blend more of the right-side face as it moves further right along the face.
                
                float f = (x - w*2/4) / (float)(w*0.25f);
                
                v = cvRound((1.0f - f) * wv + (f) * rv);
                
            }
            
            else {                  // Right 25%: just use the right face.
                
                v = rightSide.at<uchar>(y,x-midX);
                
            }
            
            faceImg.at<uchar>(y,x) = v;
            
        }// end x loop
        
    }//end y loop
    
    leftSide.release();
    rightSide.release();
    wholeFace.release();
}

- (void)unsharpMask:(cv::Mat&)im
{
    cv::Mat tmp;
    cv::GaussianBlur(im, tmp, cv::Size(5,5), 5);
    cv::addWeighted(im, 1.5, tmp, -0.5, 0, im);
}


- (cv::Mat)CropNRotate:(cv::Mat &)MyImage LEye:(CvPoint)leftEye REye:(CvPoint)rightEye destSize:(int)desiredFaceWidth
{
    if(leftEye.x + rightEye.x > 0){
        
        const double DESIRED_LEFT_EYE_X = 0.16;// 0.16;     // Controls how much of the face is visible after preprocessing.
        const double DESIRED_LEFT_EYE_Y = 0.14; //0.14;
        const double FACE_ELLIPSE_CY = 0.40;
        const double FACE_ELLIPSE_W = 0.70; //0.50;         // Should be atleast 0.5
        const double FACE_ELLIPSE_H = 0.90; //0.80;         // Controls how tall the face mask is.
        
        // Use square faces.
        int desiredFaceHeight = desiredFaceWidth;
        
        // Make the face image the same size as the training images.
        // Since we found both eyes, lets rotate & scale & translate the face so that the 2 eyes
        // line up perfectly with ideal eye positions. This makes sure that eyes will be horizontal,
        // and not too far left or right of the face, etc.
        
        // Get the center between the 2 eyes.
        Point2f eyesCenter = Point2f( (leftEye.x + rightEye.x) * 0.5f, (leftEye.y + rightEye.y) * 0.5f );
        
        // Get the angle between the 2 eyes.
        double dy = (rightEye.y - leftEye.y);
        double dx = (rightEye.x - leftEye.x);
        double len = sqrt(dx*dx + dy*dy);
        double angle = atan2(dy, dx) * 180.0/CV_PI; // Convert from radians to degrees.
        
        // Hand measurements shown that the left eye center should ideally be at roughly (0.19, 0.14) of a scaled face image.
        const double DESIRED_RIGHT_EYE_X = (1.0f - DESIRED_LEFT_EYE_X);
        
        // Get the amount we need to scale the image to be the desired fixed size we want.
        double desiredLen = (DESIRED_RIGHT_EYE_X - DESIRED_LEFT_EYE_X) * desiredFaceWidth;
        
        double scale = desiredLen / len;
        
        // Get the transformation matrix for rotating and scaling the face to the desired angle & size.
        Mat rot_mat = getRotationMatrix2D(eyesCenter, angle, scale);
        
        // Shift the center of the eyes to be the desired center between the eyes.
        rot_mat.at<double>(0, 2) += desiredFaceWidth * 0.5f - eyesCenter.x;
        rot_mat.at<double>(1, 2) += desiredFaceHeight * DESIRED_LEFT_EYE_Y - eyesCenter.y;
        
        // Rotate and scale and translate the image to the desired angle & size & position!
        // Note that we use 'w' for the height instead of 'h', because the input face has 1:1 aspect ratio.
        Mat warped = Mat(desiredFaceHeight, desiredFaceWidth, CV_8U, Scalar(128)); // Clear the output image to a default grey.
        warpAffine(MyImage, warped, rot_mat, warped.size());
        cv::Mat filtered;
        
//        {
//            equalizeLeftAndRightHalves(warped);
//            //equalizeHist(warped, warped);
//            filtered = Mat(warped.size(), CV_8U);
//            cv::bilateralFilter(warped, filtered, 0, 20.0, 2.0);
//        }
        
//        {
//            filtered = [self getRetinexImage:warped];
//        }
        
//        {
//            warped = [self getRetinexImage:warped];
//            filtered = Mat(warped.size(), CV_8U);
//            cv::bilateralFilter(warped, filtered, 0, 20.0, 2.0);
//        }
 
//        {
//            filtered = [self getRetinexImage:warped];
//        }

        {   //맨 마지막 버전 (1/31) 최종 배포 버전.
            filtered = warped;
        }
        

        
        
        
        
        // Filter out the corners of the face, since we mainly just care about the middle parts.
        // Draw a filled ellipse in the middle of the face-sized image.
        Mat mask = Mat(warped.size(), CV_8U, Scalar(0)); // Start with an empty mask.
        cv::Point faceCenter = cv::Point( desiredFaceWidth/2, cvRound(desiredFaceHeight * FACE_ELLIPSE_CY) );
        cv::Size size = cv::Size( cvRound(desiredFaceWidth * FACE_ELLIPSE_W), cvRound(desiredFaceHeight * FACE_ELLIPSE_H) );
        ellipse(mask, faceCenter, size, 0, 0, 360, Scalar(255), CV_FILLED);
        
        // Use the mask, to remove outside pixels.
        
        Mat dstImg = Mat(warped.size(), CV_8U, Scalar(128)); // Clear the output image to a default gray.
        
        // Apply the elliptical mask on the face.
        filtered.copyTo(dstImg, mask);  // Copies non-masked pixels from filtered to dstImg.
        
        rot_mat.release();
        mask.release();
        warped.release();
        filtered.release();
        
        return dstImg;
    }
    return Mat();
}

- (cv::Mat)CropNRotate:(cv::Mat &)MyImage faceInfo:(CIFaceFeature *)ff destSize:(int)desiredFaceWidth

{
//    const double DESIRED_LEFT_EYE_X = 0.16;// 0.16;     // Controls how much of the face is visible after preprocessing.
//    const double DESIRED_LEFT_EYE_Y = 0.14; //0.14;
//    const double FACE_ELLIPSE_CY = 0.40;
//    const double FACE_ELLIPSE_W = 0.70; //0.50;         // Should be atleast 0.5
//    const double FACE_ELLIPSE_H = 0.90; //0.80;         // Controls how tall the face mask is.

//    // Use square faces.
//    int desiredFaceHeight = desiredFaceWidth;

    CvPoint leftEye;
    CvPoint rightEye;
    CvPoint mouth;

    leftEye.x = ff.leftEyePosition.x;
    leftEye.y = MyImage.rows - ff.leftEyePosition.y;

    rightEye.x = ff.rightEyePosition.x;
    rightEye.y = MyImage.rows - ff.rightEyePosition.y;
    
    mouth.x = ff.mouthPosition.x;
    mouth.y = MyImage.rows - ff.mouthPosition.y;
    
//    // Draw light-blue anti-aliased circles for the 2 eyes.
//    Scalar eyeColor = CV_RGB(0,255,255);
//    if (leftEye.x >= 0) {   // Check if the eye was detected
//        circle(MyImage, leftEye, 6, eyeColor, 1, CV_AA);
//    }
//    if (rightEye.x >= 0) {   // Check if the eye was detected
//        circle(MyImage, rightEye, 6, eyeColor, 1, CV_AA);
//    }
//    if(mouth.x >= 0) {
//        circle(MyImage, mouth, 6, eyeColor, 1, CV_AA);
//    }
    
    //return MyImage;
    
    cv::Mat dstImage = [self CropNRotate:MyImage LEye:leftEye REye:rightEye destSize:desiredFaceWidth];
    
    return dstImage;
    
//    if(leftEye.x + rightEye.x > 0){
//        
//        const double DESIRED_LEFT_EYE_X = 0.16;// 0.16;     // Controls how much of the face is visible after preprocessing.
//        const double DESIRED_LEFT_EYE_Y = 0.14; //0.14;
//        const double FACE_ELLIPSE_CY = 0.40;
//        const double FACE_ELLIPSE_W = 0.70; //0.50;         // Should be atleast 0.5
//        const double FACE_ELLIPSE_H = 0.90; //0.80;         // Controls how tall the face mask is.
//        
//        // Use square faces.
//        int desiredFaceHeight = desiredFaceWidth;
//
//        // Make the face image the same size as the training images.
//        // Since we found both eyes, lets rotate & scale & translate the face so that the 2 eyes
//        // line up perfectly with ideal eye positions. This makes sure that eyes will be horizontal,
//        // and not too far left or right of the face, etc.
//
//        // Get the center between the 2 eyes.
//        Point2f eyesCenter = Point2f( (leftEye.x + rightEye.x) * 0.5f, (leftEye.y + rightEye.y) * 0.5f );
//        
//        // Get the angle between the 2 eyes.
//        double dy = (rightEye.y - leftEye.y);
//        double dx = (rightEye.x - leftEye.x);
//        double len = sqrt(dx*dx + dy*dy);
//        double angle = atan2(dy, dx) * 180.0/CV_PI; // Convert from radians to degrees.
//
//        // Hand measurements shown that the left eye center should ideally be at roughly (0.19, 0.14) of a scaled face image.
//        const double DESIRED_RIGHT_EYE_X = (1.0f - DESIRED_LEFT_EYE_X);
//
//        // Get the amount we need to scale the image to be the desired fixed size we want.
//        double desiredLen = (DESIRED_RIGHT_EYE_X - DESIRED_LEFT_EYE_X) * desiredFaceWidth;
//        
//        double scale = desiredLen / len;
//
//        // Get the transformation matrix for rotating and scaling the face to the desired angle & size.
//        Mat rot_mat = getRotationMatrix2D(eyesCenter, angle, scale);
//        
//        // Shift the center of the eyes to be the desired center between the eyes.
//        rot_mat.at<double>(0, 2) += desiredFaceWidth * 0.5f - eyesCenter.x;
//        rot_mat.at<double>(1, 2) += desiredFaceHeight * DESIRED_LEFT_EYE_Y - eyesCenter.y;
//
//        // Rotate and scale and translate the image to the desired angle & size & position!
//        // Note that we use 'w' for the height instead of 'h', because the input face has 1:1 aspect ratio.
//        Mat warped = Mat(desiredFaceHeight, desiredFaceWidth, CV_8U, Scalar(128)); // Clear the output image to a default grey.
//        warpAffine(MyImage, warped, rot_mat, warped.size());
//
//        
//        
//        // Give the image a standard brightness and contrast, in case it was too dark or had low contrast.
//        // Do it seperately for the left and right sides of the face.
//        //equalizeLeftAndRightHalves(warped);
//        //equalizeHist(warped, warped);
//        cv::Mat filtered = [self getRetinexImage:warped];
//
//        // Use the "Bilateral Filter" to reduce pixel noise by smoothing the image, but keeping the sharp edges in the face.
//        //cv::Mat filtered = Mat(warped.size(), CV_8U);
//        //cv::bilateralFilter(warped, filtered, 0, 20.0, 2.0);
// 
//        // Filter out the corners of the face, since we mainly just care about the middle parts.
//        // Draw a filled ellipse in the middle of the face-sized image.
//        Mat mask = Mat(warped.size(), CV_8U, Scalar(0)); // Start with an empty mask.
//        cv::Point faceCenter = cv::Point( desiredFaceWidth/2, cvRound(desiredFaceHeight * FACE_ELLIPSE_CY) );
//        cv::Size size = cv::Size( cvRound(desiredFaceWidth * FACE_ELLIPSE_W), cvRound(desiredFaceHeight * FACE_ELLIPSE_H) );
//        ellipse(mask, faceCenter, size, 0, 0, 360, Scalar(255), CV_FILLED);
//
//        // Use the mask, to remove outside pixels.
//        
//        Mat dstImg = Mat(warped.size(), CV_8U, Scalar(128)); // Clear the output image to a default gray.
//
//        // Apply the elliptical mask on the face.
//        filtered.copyTo(dstImg, mask);  // Copies non-masked pixels from filtered to dstImg.
//        
//        rot_mat.release();
//        mask.release();
//        warped.release();
//        filtered.release();
//        
//        return dstImg;
//    }
//    return Mat();
}

//얼굴만 있는 이미지는 눈/코/입을 찾을 수 없어서 얼굴 이외의 빈 영역을 더 만들어 줌.
- (UIImage *)drawOverlayImage:(UIImage *)img
{
    CGFloat _width = 300;
    CGFloat _height = 300;
    
    colorSpace = CGImageGetColorSpace(img.CGImage);
    CGContextRef ctx = CGBitmapContextCreate (nil, _width, _height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
 
    CGContextSetRGBFillColor (ctx, 0.7, 0.7, 0.7, 1.0);
    CGContextFillRect (ctx, CGRectMake (0, 0, 300, 300));
    
    CGContextSetAlpha (ctx, 1.0);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextDrawImage(ctx, CGRectMake(50, 50, 200, 200), [img CGImage]);
    
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
    
	UIImage *imageCopied = [UIImage imageWithCGImage:imageRef];
    
	CGImageRelease(imageRef);
    
	return imageCopied;
}

// 큰 얼굴이 있는 사진에서는 얼굴인식이 잘 안되므로 얼굴 이외의 영역을 패딩해 준다.
// 보통 scale 은 1.2로 세팅 해 줄 것임.
- (UIImage *)scaleImage:(CGImageRef)cgImage scale:(float)scale
{
    CGFloat _width = CGImageGetWidth(cgImage);
    CGFloat _height = CGImageGetHeight(cgImage);
    CGFloat _scaleWidth = _width * scale;
    CGFloat _scaleHeight = _height * scale;
    
    NSLog(@"Orignal Size = w(%f)/h(%f) || scale Size = w(%f)/h(%f)", _width, _height, _scaleWidth, _scaleHeight);
    colorSpace = CGImageGetColorSpace(cgImage);
    
    CGContextRef ctx = CGBitmapContextCreate (nil, _scaleWidth, _scaleHeight, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextSetRGBFillColor (ctx, 0.7, 0.7, 0.7, 1.0);
    CGContextFillRect (ctx, CGRectMake (0, 0, _scaleWidth, _scaleHeight));
    
    CGContextSetAlpha (ctx, 1.0);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextDrawImage(ctx, CGRectMake((_scaleWidth - _width)/2, (_scaleHeight - _height)/2, _width, _height), cgImage);
    
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
    
	UIImage *imageCopied = [UIImage imageWithCGImage:imageRef];
    
	CGImageRelease(imageRef);
    
	return imageCopied;

}

- (void)getRetinaImage:(cv::Mat&)image
{
    //Retinex(image, 20.0, 128, 128);
}

- (cv::Mat)getFaceImage:(CIImage *)ciImage feature:(CIFaceFeature *)feature orient:(UIImageOrientation)uiImageOrient landscape:(BOOL)isLandScape
{
    
    CGImageRef cgImage = [_context createCGImage:ciImage fromRect:feature.bounds];
    UIImage *tmpImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:uiImageOrient];
    CGImageRelease(cgImage);
    
    //int maxResolution = MAX(feature.bounds.size.width, feature.bounds.size.height);
    UIImage *baseImage = [self scaleAndRotate:tmpImage maxResolution:200 orientation:tmpImage.imageOrientation];

    UIImage *image = [self drawOverlayImage:baseImage];

    CIImage *faceImage = [CIImage imageWithCGImage:image.CGImage];
    
    cv::Mat cvImage = [FaceLib UIImageToMat:image];
    
    //[self getRetinaImage:cvImage];
    //return cvImage;
    
    NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @(NO) };
    CIDetector *cFaceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    NSArray *features = [cFaceDetector featuresInImage:faceImage options:nil];

    cv::Mat resultImage = Mat();
    
    for(CIFaceFeature *ff in features){
        //if(CGRectIntersectsRect(ff.bounds,feature.bounds)){
            NSLog(@"faceImage bound = %@ / feature.bounds = %@ / Feature.leftEyePosition = %@ / Feature.rightEyePosition = %@",
                  NSStringFromCGRect(faceImage.extent), NSStringFromCGRect(ff.bounds), NSStringFromCGPoint(ff.leftEyePosition), NSStringFromCGPoint(ff.rightEyePosition));
        resultImage = [self CropNRotate:cvImage faceInfo:ff destSize:100];

        //}

    }
    
    cvImage.release();
    
    return resultImage;

}

- (NSData *)serializeCvMat:(cv::Mat&)cvMat
{
    return [[NSData alloc] initWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
}

- (cv::Mat)pullStandardizedFace:(cv::Mat&)image
{
    // Pull the grayscale face ROI out of the captured image
    cv::Mat onlyTheFace;
    
    if (image.channels() == 3) {
        cvtColor(image, onlyTheFace, CV_BGR2GRAY);
    }
    else if (image.channels() == 4) {
        cvtColor(image, onlyTheFace, CV_BGRA2GRAY);
    }
    else {
        // Access the input image directly, since it is already grayscale.
        onlyTheFace = image;
    }
    
    //    cv::cvtColor(image, onlyTheFace, CV_RGB2GRAY);
    
    int rows = onlyTheFace.rows;
    int cols = onlyTheFace.cols;
    // Standardize the face to 100x100 pixels
    if(rows != 100 || cols != 100)
        cv::resize(onlyTheFace, onlyTheFace, cv::Size(100, 100), 0, 0);
    
    return onlyTheFace;
}

//- (cv::Mat)getFaceImage_old:(CIImage *)ciImage feature:(CIFaceFeature *)feature orient:(UIImageOrientation)uiImageOrient landscape:(BOOL)isLandScape
//{
//    
//    //    //float rotation = atan2((float)(eye_direction.y),(float)(eye_direction.x));
//    float rotation = 0.f;
//    if(feature.leftEyePosition.x != feature.rightEyePosition.x)
//        rotation = atan (feature.leftEyePosition.y - feature.rightEyePosition.y ) / (feature.leftEyePosition.x - feature.rightEyePosition.x);
//    
//    
//    CGRect faceBound = feature.bounds;
//    CGPoint leftEyePosition = feature.leftEyePosition;
//    CGPoint rightEyePosition = feature.rightEyePosition;
//    
//    if(leftEyePosition.x > rightEyePosition.x) {
//        CGPoint eye = leftEyePosition;
//        leftEyePosition = rightEyePosition;
//        rightEyePosition = eye;
//    }
//    
//    CGPoint LEyePosition, REyePosition;
//    if(isLandScape) {
//        LEyePosition = CGPointMake(leftEyePosition.x - faceBound.origin.x, leftEyePosition.y - faceBound.origin.y);
//        REyePosition = CGPointMake(rightEyePosition.x - faceBound.origin.x, rightEyePosition.y - faceBound.origin.y);
//        
//    } else {
//        LEyePosition = CGPointMake(leftEyePosition.y - faceBound.origin.y, leftEyePosition.x - faceBound.origin.x);
//        REyePosition = CGPointMake(rightEyePosition.y - faceBound.origin.y, rightEyePosition.x - faceBound.origin.x);
//    }
//    
//    CvPoint cvLEYE;
//    cvLEYE.x = LEyePosition.x;
//    cvLEYE.y = LEyePosition.y;
//    
//    CvPoint cvREYE;
//    cvREYE.x = REyePosition.x;
//    cvREYE.y = REyePosition.y;
//    
//    CvPoint offset_pct;
//    offset_pct.x = 25;
//    offset_pct.y = 30;
//    
//    CvPoint dest_sz;
//    dest_sz.x = 100;
//    dest_sz.y = 100;
//    
//    
//    
//    NSLog(@"original Size : %@ / face rect : %@ / LE : %@ / RE : %@ / rotation : %f / isLandScape : %d",
//          NSStringFromCGRect(ciImage.extent) , NSStringFromCGRect(feature.bounds),
//          NSStringFromCGPoint(feature.leftEyePosition), NSStringFromCGPoint(feature.rightEyePosition), rotation, (isLandScape)? 1 : 0);
//    
//    
//    //
//    //    CGImageRef cgImage = [_context createCGImage:ciImage fromRect:feature.bounds];
//    //    colorSpace = CGImageGetColorSpace(cgImage);
//    //
//    //    CGFloat cols = CGImageGetWidth(cgImage); //  image.size.width;
//    //    CGFloat rows = CGImageGetHeight(cgImage); //image.size.height;
//    //
//    //    cv::Mat cvMat(rows, cols, CV_8UC4);
//    //
//    //    CGContextRef contextRef = CGBitmapContextCreate(
//    //                                                    cvMat.data,                 // Pointer to  data
//    //                                                    cols,                       // Width of bitmap
//    //                                                    rows,                       // Height of bitmap
//    //                                                    8,                          // Bits per component
//    //                                                    cvMat.step[0],              // Bytes per row
//    //                                                    colorSpace,                 // Colorspace
//    //                                                    kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault // Bitmap info flags
//    //                                                    );
//    //
//    //
//    ////    CGContextRotateCTM (contextRef, -90 * M_PI / 180);
//    ////    CGContextTranslateCTM (contextRef, -cols, 0);
//    //
//    //    CGContextRotateCTM (contextRef, rotation);
//    //
//    //    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), cgImage);
//    //    CGContextRelease(contextRef);
//    //
//    //    cv::Mat cvImage;
//    //    cvtColor(cvMat, cvImage, CV_RGB2GRAY);
//    ///////////////////////////////////////////////////////
//    
//    //    CGRect faceBound = feature.bounds;
//    //    CGPoint leftEyePosition = feature.leftEyePosition;
//    //    CGPoint rightEyePosition = feature.rightEyePosition;
//    //
//    //    if(leftEyePosition.x > rightEyePosition.x) {
//    //        CGPoint eye = leftEyePosition;
//    //        leftEyePosition = rightEyePosition;
//    //        rightEyePosition = eye;
//    //    }
//    //
//    //    CGPoint LEyePosition = CGPointMake(leftEyePosition.y - faceBound.origin.y, leftEyePosition.x - faceBound.origin.x);
//    //    CGPoint REyePosition = CGPointMake(rightEyePosition.y - faceBound.origin.y, rightEyePosition.x - faceBound.origin.x);
//    //
//    //    CGImageRef cgImage = [_context createCGImage:ciImage fromRect:faceBound];
//    //    //CGImageRef cgImage = [FaceLib getFaceCGImage:ciImage bound:faceBound];
//    //    UIImage *tmpImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:uiImageOrient];//(UIImageOrientation)UIImageOrientationLeftMirrored];
//    //    CGImageRelease(cgImage);
//    //
//    //
//    //    UIImage *image = [FaceLib fixrotation:tmpImage];
//    //    cv::Mat cvImage = [FaceLib UIImageToMat:image];
//    //
//    //    CvPoint cvLEYE;
//    //    cvLEYE.x = LEyePosition.x;
//    //    cvLEYE.y = LEyePosition.y;
//    //
//    //    CvPoint cvREYE;
//    //    cvREYE.x = REyePosition.x;
//    //    cvREYE.y = REyePosition.y;
//    //
//    //    CvPoint offset_pct;
//    //    offset_pct.x = 25;
//    //    offset_pct.y = 30;
//    //
//    //    CvPoint dest_sz;
//    //    dest_sz.x = 100;
//    //    dest_sz.y = 100;
//    
//    
//    CGImageRef cgImage = [_context createCGImage:ciImage fromRect:feature.bounds];
//    UIImage *tmpImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:uiImageOrient];
//    CGImageRelease(cgImage);
//    
//    UIImage *image = [FaceLib fixrotation:tmpImage];
//    
//    //UIImage *image = [self scaleAndRotate:tmpImage maxResolution:100 orientation:tmpImage.imageOrientation];
//    
//    
//    
//    //    CIImage *cropImage = [CIImage imageWithCGImage:image.CGImage];
//    //
//    //    NSArray *features = [_faceDetector featuresInImage:cropImage options:nil];
//    //    //NSArray *features = [FaceLib detectFace:cropImage options:nil];
//    //    if([features count]){
//    //        CIFaceFeature *faceFeature = [features objectAtIndex:0];
//    //
//    //        float rotation = 0.f;
//    //        if(faceFeature.leftEyePosition.x != faceFeature.rightEyePosition.x)
//    //            rotation = atan (faceFeature.leftEyePosition.y - faceFeature.rightEyePosition.y ) / (faceFeature.leftEyePosition.x - faceFeature.rightEyePosition.x);
//    //
//    //
//    //        NSLog(@"original Size : %@ / face rect : %@ / LE : %@ / RE : %@ / rotation : %f / orient : %d",
//    //              NSStringFromCGRect(cropImage.extent) , NSStringFromCGRect(faceFeature.bounds),
//    //              NSStringFromCGPoint(faceFeature.leftEyePosition), NSStringFromCGPoint(faceFeature.rightEyePosition), rotation, (int)uiImageOrient);
//    //
//    //
//    //    } else {
//    //        return Mat();
//    //    }
//    //
//    //    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustRedEye]];
//    //
//    //    for (CIFilter* filter in adjustments)
//    //    {
//    //        [filter setValue:cropImage forKey:kCIInputImageKey];
//    //        cropImage = filter.outputImage;
//    //    }
//    //    cgImage =[_context createCGImage:cropImage fromRect:cropImage.extent];
//    //    image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
//    //    CGImageRelease(cgImage);
//    //cgImage = CGImageCreateWithImageInRect(<#CGImageRef image#>, <#CGRect rect#>);
//    
//    cv::Mat cvImage = [FaceLib UIImageToMat:image];
//    
//    
//    
//    
//    if(cvImage.data == NULL) return Mat();
//    
//    //[FaceLib CropFace:cvImage eye_left:cvLEYE eye_right:cvREYE offset_pct:offset_pct dest_sz:dest_sz ];
//    
//    //cvImage = [self getRetinexImage:cvImage];
//    return cvImage;
//}

- (CGImageRef)getFaceCGImage:(CIImage *)ciImage bound:(CGRect)faceRect
{
    CGImageRef img = [_context createCGImage:ciImage fromRect:faceRect];
    return img;
}

- (UIImage *)getFaceUIImage:(CIImage *)ciImage bound:(CGRect)faceRect
{
    CGImageRef img = [_context createCGImage:ciImage fromRect:faceRect];
    UIImage *tmpImage = [UIImage imageWithCGImage:img];
    if(img) CGImageRelease(img);

    return tmpImage;
}

- (cv::Mat)getFaceCVData:(CIImage *)ciImage feature:(CIFaceFeature *)face
{
    CGRect faceRect = face.bounds;
    
    
    CGImageRef img = [_context createCGImage:ciImage fromRect:faceRect];
    UIImage *tmpImage = [UIImage imageWithCGImage:img];
    if(img) CGImageRelease(img);
    
    if(tmpImage == nil) {
        return Mat();
    }
    
    NSLog(@"ciImage.bound = %@ / face.bound = %@ / lefteye = %@ / righteye = %@ / mouth = %@",
          NSStringFromCGRect(ciImage.extent), NSStringFromCGRect(face.bounds),
          NSStringFromCGPoint(face.leftEyePosition), NSStringFromCGPoint(face.rightEyePosition),
          NSStringFromCGPoint(face.mouthPosition));
    
    
    cv::Mat cvImage = [FaceLib UIImageToMat:tmpImage];
    
    
    CvPoint leftEye, rightEye, mouth;
    
    leftEye.x = face.leftEyePosition.x - faceRect.origin.x;
    leftEye.y = cvImage.rows - (face.leftEyePosition.y - faceRect.origin.y);
    
    rightEye.x = face.rightEyePosition.x - faceRect.origin.x;
    rightEye.y = cvImage.rows - (face.rightEyePosition.y - faceRect.origin.y);
    
    mouth.x = face.mouthPosition.x - faceRect.origin.x;
    mouth.y = cvImage.rows - (face.mouthPosition.y - faceRect.origin.y);
    
    cv::Mat resultImage = [self CropNRotate:cvImage LEye:leftEye REye:rightEye destSize:100];
    
    return resultImage;
}


- (NSDictionary*)getFaceData:(CIImage *)ciImage feature:(CIFaceFeature *)face
{
    CGRect faceRect = face.bounds;
    
    
    CGImageRef img = [_context createCGImage:ciImage fromRect:faceRect];
    UIImage *tmpImage = [UIImage imageWithCGImage:img];
    if(img) CGImageRelease(img);
    
    if(tmpImage == nil) {
        return nil;
    }
    
    NSLog(@"ciImage.bound = %@ / face.bound = %@ / lefteye = %@ / righteye = %@ / mouth = %@",
          NSStringFromCGRect(ciImage.extent), NSStringFromCGRect(face.bounds),
          NSStringFromCGPoint(face.leftEyePosition), NSStringFromCGPoint(face.rightEyePosition),
          NSStringFromCGPoint(face.mouthPosition));

 
    cv::Mat cvImage = [FaceLib UIImageToMat:tmpImage];
    
    
    CvPoint leftEye, rightEye, mouth;
    
    leftEye.x = face.leftEyePosition.x - faceRect.origin.x;
    leftEye.y = cvImage.rows - (face.leftEyePosition.y - faceRect.origin.y);
    
    rightEye.x = face.rightEyePosition.x - faceRect.origin.x;
    rightEye.y = cvImage.rows - (face.rightEyePosition.y - faceRect.origin.y);
    
    mouth.x = face.mouthPosition.x - faceRect.origin.x;
    mouth.y = cvImage.rows - (face.mouthPosition.y - faceRect.origin.y);

    cv::Mat resultImage = [self CropNRotate:cvImage LEye:leftEye REye:rightEye destSize:100];
    
    
    //cv::Mat resultImage = [self CropNRotate:cvImage faceInfo:face destSize:100];

    NSData *serialized = [self serializeCvMat:resultImage];
    
    NSString *PhotoBound = NSStringFromCGRect(ciImage.extent);
    NSString *faceBound = NSStringFromCGRect(faceRect);
    
    UIImage *processImage = [self MatToUIImage:resultImage];
    NSDictionary *result = @{@"PhotoBound": PhotoBound, @"faceBound":faceBound,
                             @"image": serialized, @"faceImage":tmpImage, @"process":processImage };
    
    
    cvImage.release();
    resultImage.release();
    
    return result;
}

//- (NSDictionary*)getFaceData:(CIImage *)ciImage feature:(CIFaceFeature *)face
////- (NSDictionary*)getFaceData:(CIImage *)ciImage bound:(CGRect)faceRect
//{
//    CGRect faceRect = face.bounds;
//    
//    CGImageRef img = [_context createCGImage:ciImage fromRect:faceRect];
//    UIImage *tmpImage = [UIImage imageWithCGImage:img];
//    if(img) CGImageRelease(img);
//    
//    if(tmpImage == nil) return nil;
//    
//    UIImage *baseImage = [self scaleAndRotate:tmpImage maxResolution:200 orientation:tmpImage.imageOrientation];
//    UIImage *image = [self drawOverlayImage:baseImage];
//    CIImage *faceImage = [CIImage imageWithCGImage:image.CGImage];
//    
//    cv::Mat cvImage = [FaceLib UIImageToMat:image];
//    
////    NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @(NO) };
////    CIDetector *cFaceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
////    NSArray *features = [cFaceDetector featuresInImage:faceImage options:nil];
//    
////    NSArray *features = [FaceLib detectFace:faceImage options:nil];
//    
//    NSArray *features = [self.faceDetector featuresInImage:faceImage];
//    
//    cv::Mat resultImage = Mat();
//    
//    for(CIFaceFeature *ff in features){
//        //if(CGRectIntersectsRect(ff.bounds,feature.bounds)){
//        NSLog(@"faceImage bound = %@ / feature.bounds = %@ / Feature.leftEyePosition = %@ / Feature.rightEyePosition = %@",
//              NSStringFromCGRect(faceImage.extent), NSStringFromCGRect(ff.bounds),
//              NSStringFromCGPoint(ff.leftEyePosition), NSStringFromCGPoint(ff.rightEyePosition));
//        resultImage = [self CropNRotate:cvImage faceInfo:ff destSize:100];
//        
//        //}
//        
//    }
//    
//    features = nil;
//    
//    
//    //cv::Mat cvimage = [self UIImageToMat:tmpImage];
//    //cv::Mat faceData = [self pullStandardizedFace:resultImage];
//    NSData *serialized = [self serializeCvMat:resultImage];
//    
//    NSString *PhotoBound = NSStringFromCGRect(ciImage.extent);
//    NSString *faceBound = NSStringFromCGRect(faceRect);
//    
//    NSDictionary *result = @{@"PhotoBound": PhotoBound, @"faceBound":faceBound,
//                             @"image": serialized, @"faceImage":tmpImage };
//    
//    
//    cvImage.release();
//    resultImage.release();
//    
//    return result;
//}

- (cv::Mat)UIImageToMat:(UIImage *)image
{
    return [self UIImageToMat:image usingColorSpace:CV_RGB2GRAY];
}

- (cv::Mat)UIImageToMat:(UIImage *)image usingColorSpace:(int)outputSpace
{
    colorSpace = CGImageGetColorSpace(image.CGImage);
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault;
    
    CGColorSpaceModel cspacemodel = CGColorSpaceGetModel(colorSpace);
    if(cspacemodel == kCGColorSpaceModelMonochrome){
        bitmapInfo = kCGImageAlphaNone;
    }
    
    
    //colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    bitmapInfo //kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault // Bitmap info flags
                                                    );
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    //CGColorSpaceRelease(colorSpace);
    
    cv::Mat finalOutput;
    cvtColor(cvMat, finalOutput, outputSpace);
    cvMat.release();
    return finalOutput;
}

- (UIImage*)MatToUIImage:(const cv::Mat&)image
{
    
    NSData *data = [NSData dataWithBytes:image.data
                                  length:image.elemSize()*image.total()];
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,
                                        image.rows,
                                        8,
                                        8 * image.elemSize(),
                                        image.step.p[0],
                                        colorSpace,
                                        kCGImageAlphaNone|
                                        kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    //CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}



- (UIImage*)getRetinexUIImage:(UIImage*)uiImage
{
    
    cv::Mat image = [self UIImageToMat:uiImage];
    
    //    cv::Mat preprocessed = tan_triggs_preprocessing(image);
    //    preprocessed = norm_0_255(preprocessed);
    cv::Mat preprocessed = [self getRetinexImage:image];
    
    UIImage *resulImg = [self MatToUIImage:preprocessed];
    
    image.release();
    preprocessed.release();
    
    //    cv::Mat image;
    //    UIImageToMat(uiImage, image, NO);
    //    UIImage *resulImg = MatToUIImage(image);
    return resulImg;
}

- (cv::Mat)getRetinexImage:(cv::Mat)image
{
    cv::Mat preprocessed = tan_triggs_preprocessing(image);
    cv::Mat result = norm_0_255(preprocessed);
    preprocessed.release();
    
    return result;
}

- (UIImage*)getSkinUIImage:(UIImage*)uiImage
{
    cv::Mat image =  [self UIImageToMat:uiImage usingColorSpace:CV_RGB2BGR]; //[self UIImageToMat:uiImage];
    
    cv::Mat preprocessed = [self getSkinImage:image];
    
    UIImage *resulImg = [self MatToUIImage:preprocessed];
    
    return resulImg;
}


- (cv::Mat)getSkinImage:(cv::Mat)image
{
    // Put a little Gaussian blur on:
    cv::blur(image, image, cv::Size(5,5));
    // Filter for skin:
    cv::Mat skin = ThresholdSkin(image);
    // And finally perform a little dilation and erosion, I'll just
    // steal from:
    //
    //      http://docs.opencv.org/doc/tutorials/imgproc/erosion_dilatation/erosion_dilatation.html
    //
    
    int dilation_size = 5;
    int erosion_size = 5;
    
    cv::dilate(skin, skin, cv::getStructuringElement(
                                                     cv::MORPH_RECT,
                                                     cv::Size(2*dilation_size+1, 2*dilation_size+1),
                                                     cv::Point(dilation_size, dilation_size)));
    
    cv::erode(skin, skin, cv::getStructuringElement(
                                                    cv::MORPH_RECT,
                                                    cv::Size(2*erosion_size+1, 2*erosion_size+1),
                                                    cv::Point(erosion_size, erosion_size)));
    
    return skin;
}

#pragma mark For  TanTriggs Preprocessing

// Normalizes a given image into a value range between 0 and 255.
cv::Mat norm_0_255(const cv::Mat& src) {
    // Create and return normalized image:
    cv::Mat dst;
    switch(src.channels()) {
        case 1:
            cv::normalize(src, dst, 0, 255, cv::NORM_MINMAX, CV_8UC1);
            break;
        case 3:
            cv::normalize(src, dst, 0, 255, cv::NORM_MINMAX, CV_8UC3);
            break;
        default:
            src.copyTo(dst);
            break;
    }
    return dst;
}

//
// Calculates the TanTriggs Preprocessing as described in:
//
//      Tan, X., and Triggs, B. "Enhanced local texture feature sets for face
//      recognition under difficult lighting conditions.". IEEE Transactions
//      on Image Processing 19 (2010), 1635–650.
//
// Default parameters are taken from the paper.
// From : https://github.com/bytefish/opencv/blob/master/misc/tan_triggs.cpp
//      // Load image & get skin proportions:
//      Mat image = imread(argv[1], CV_LOAD_IMAGE_GRAYSCALE);
//      // Calculate the TanTriggs Preprocessed image with default parameters:
//      Mat preprocessed = tan_triggs_preprocessing(image);
//      // Draw it on screen:
//      imshow("Original Image", image);
//      imshow("TanTriggs Preprocessed Image", norm_0_255(preprocessed));

cv::Mat tan_triggs_preprocessing(cv::InputArray src,
                                 float alpha = 0.1, float tau = 10.0, float gamma = 0.2, int sigma0 = 1,
                                 int sigma1 = 2) {
    
    // Convert to floating point:
    cv::Mat X = src.getMat();
    X.convertTo(X, CV_32FC1);
    // Start preprocessing:
    cv::Mat I;
    cv::pow(X, gamma, I);
    // Calculate the DOG Image:
    {
        cv::Mat gaussian0, gaussian1;
        // Kernel Size:
        int kernel_sz0 = (3*sigma0);
        int kernel_sz1 = (3*sigma1);
        // Make them odd for OpenCV:
        kernel_sz0 += ((kernel_sz0 % 2) == 0) ? 1 : 0;
        kernel_sz1 += ((kernel_sz1 % 2) == 0) ? 1 : 0;
        cv::GaussianBlur(I, gaussian0, cv::Size(kernel_sz0,kernel_sz0), sigma0, sigma0, cv::BORDER_CONSTANT);
        cv::GaussianBlur(I, gaussian1, cv::Size(kernel_sz1,kernel_sz1), sigma1, sigma1, cv::BORDER_CONSTANT);
        cv::subtract(gaussian0, gaussian1, I);
    }
    
    {
        double meanI = 0.0;
        {
            cv::Mat tmp;
            cv::pow(abs(I), alpha, tmp);
            meanI = cv::mean(tmp).val[0];
            tmp.release();
            
        }
        I = I / cv::pow(meanI, 1.0/alpha);
    }
    
    {
        double meanI = 0.0;
        {
            cv::Mat tmp;
            cv::pow(cv::min(cv::abs(I), tau), alpha, tmp);
            meanI = cv::mean(tmp).val[0];
            tmp.release();
        }
        I = I / cv::pow(meanI, 1.0/alpha);
    }
    
    // Squash into the tanh:
    {
        for(int r = 0; r < I.rows; r++) {
            for(int c = 0; c < I.cols; c++) {
                I.at<float>(r,c) = tanh(I.at<float>(r,c) / tau);
            }
        }
        I = tau * I;
    }
    
    X.release();
    
    return I;
}


#pragma mark For  Skin Color Thresholding
// This snippet implements common Skin Color Thresholding rules taken from:
//
//  Nusirwan Anwar bin Abdul Rahman, Kit Chong Wei and John See. RGB-H-CbCr Skin Colour Model for Human Face Detection.
//  (Online available at http://pesona.mmu.edu.my/~johnsee/research/papers/files/rgbhcbcr_m2usic06.pdf)
bool R1(int R, int G, int B) {
    bool e1 = (R>95) && (G>40) && (B>20) && ((max(R,max(G,B)) - min(R, min(G,B)))>15) && (abs(R-G)>15) && (R>G) && (R>B);
    bool e2 = (R>220) && (G>210) && (B>170) && (abs(R-G)<=15) && (R>B) && (G>B);
    return (e1||e2);
}

bool R2(float Y, float Cr, float Cb) {
    bool e3 = Cr <= 1.5862*Cb+20;
    bool e4 = Cr >= 0.3448*Cb+76.2069;
    bool e5 = Cr >= -4.5652*Cb+234.5652;
    bool e6 = Cr <= -1.15*Cb+301.75;
    bool e7 = Cr <= -2.2857*Cb+432.85;
    return e3 && e4 && e5 && e6 && e7;
}

bool R3(float H, float S, float V) {
    return (H<25) || (H > 230);
}

Mat ThresholdSkin(const Mat &src) {
    // Allocate the result matrix
    Mat dst = Mat::zeros(src.rows, src.cols, CV_8UC1);
    // We operate in YCrCb and HSV:
    Mat src_ycrcb, src_hsv;
    // OpenCV scales the YCrCb components, so that they
    // cover the whole value range of [0,255], so there's
    // no need to scale the values:
    cvtColor(src, src_ycrcb, CV_BGR2YCrCb);
    // OpenCV scales the Hue Channel to [0,180] for
    // 8bit images, make sure we are operating on
    // the full spectrum from [0,360] by using floating
    // point precision:
    src.convertTo(src_hsv, CV_32FC3);
    cvtColor(src_hsv, src_hsv, CV_BGR2HSV);
    // And then scale between [0,255] for the rules in the paper
    // to apply. This uses normalize with CV_32FC3, which may fail
    // on older OpenCV versions. If so, you probably want to split
    // the channels first and call normalize independently on each
    // channel:
    normalize(src_hsv, src_hsv, 0.0, 255.0, NORM_MINMAX, CV_32FC3);
    // Iterate over the data:
    for(int i = 0; i < src.rows; i++) {
        for(int j = 0; j < src.cols; j++) {
            // Get the pixel in BGR space:
            Vec3b pix_bgr = src.ptr<Vec3b>(i)[j];
            int B = pix_bgr.val[0];
            int G = pix_bgr.val[1];
            int R = pix_bgr.val[2];
            // And apply RGB rule:
            bool a = R1(R,G,B);
            // Get the pixel in YCrCB space:
            Vec3b pix_ycrcb = src_ycrcb.ptr<Vec3b>(i)[j];
            int Y = pix_ycrcb.val[0];
            int Cr = pix_ycrcb.val[1];
            int Cb = pix_ycrcb.val[2];
            // And apply the YCrCB rule:
            bool b = R2(Y,Cr,Cb);
            // Get the pixel in HSV space:
            Vec3f pix_hsv = src_hsv.ptr<Vec3f>(i)[j];
            float H = pix_hsv.val[0];
            float S = pix_hsv.val[1];
            float V = pix_hsv.val[2];
            // And apply the HSV rule:
            bool c = R3(H,S,V);
            // If not skin, then black
            if(a && b && c) {
                dst.at<unsigned char>(i,j) = 255;
            }
        }
    }
    return dst;
}

- (UIImage *)fixrotation:(UIImage *)image
{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
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
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

- (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution orientation:(UIImageOrientation)orientation;
{
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > maxResolution || height > maxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = maxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = maxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	switch (orientation) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return imageCopy;
}



float Distance(CvPoint p1, CvPoint p2)
{
	int dx = p2.x - p1.x;
	int dy = p2.y - p1.y;
	return sqrt(dx*dx+dy*dy);
}

//////////////////////////////////////////////
// rotate picture (to align eyes-y)
//////////////////////////////////////////////
cv::Mat rotate(cv::Mat& image, double angle, CvPoint centre)
{
    cv::Point2f src_center(centre.x, centre.y);
	// conversion en degre
	angle = angle*180.0/3.14157;
    // 	DEBUG printf("(D) rotate : rotating : %fÂ° %d %d\n",angle, centre.x, centre.y);
    cv::Mat rot_matrix = getRotationMatrix2D(src_center, angle, 1.0);
    
    cv::Mat rotated_img(cv::Size(image.size().height, image.size().width), image.type());
    
    warpAffine(image, rotated_img, rot_matrix, image.size());
    
    rot_matrix.release();
    
    return (rotated_img);
}

//https://github.com/Itseez/opencv/blob/master/modules/contrib/doc/facerec/tutorial/facerec_video_recognition.rst
//Aligning Face Images

- (int)CropFace:(cv::Mat &)MyImage
       eye_left:(CvPoint)eye_left
      eye_right:(CvPoint)eye_right
     offset_pct:(CvPoint)offset_pct dest_sz:(CvPoint)dest_sz
{
    
	// calculate offsets in original image
	int offset_h = (offset_pct.x*dest_sz.x/100);
	int offset_v = (offset_pct.y*dest_sz.y/100);
    //	DEBUG printf("(D) CropFace : offeth=%d, offsetv=%d\n",offset_h,offset_v);
	
	// get the direction
	CvPoint eye_direction;
	eye_direction.x = eye_right.x - eye_left.x;
	eye_direction.y = eye_right.y - eye_left.y;
	
	
	// calc rotation angle in radians
	//float rotation = atan2((float)(eye_direction.y),(float)(eye_direction.x));
	float rotation = atan ( eye_left.y - eye_right.y ) / (eye_left.x - eye_right.x);
    
	// distance between them
	float dist = Distance(eye_left, eye_right);
    //	DEBUG printf("(D) CropFace : dist=%f\n",dist);
	
	// calculate the reference eye-width
	int reference = dest_sz.x - 2*offset_h;
	
	// scale factor
	float scale = dist/(float)reference;
    //    DEBUG printf("(D) CropFace : scale=%f\n",scale);
	
	// rotate original around the left eye
    //	char sTmp[16];
    //	sprintf(sTmp,"%f",rotation);
    //	trace("-- rotate image "+string(sTmp));
	MyImage = rotate(MyImage, (double)rotation, eye_left);
	
	// crop the rotated image
	CvPoint crop_xy;
	crop_xy.x = abs(eye_left.x - scale*offset_h);
	crop_xy.y = abs(eye_left.y - scale*offset_v);
	
	CvPoint crop_size;
	crop_size.x = dest_sz.x*scale;
	crop_size.y = dest_sz.y*scale;
	
	// Crop the full image to that image contained by the rectangle myROI
    //	trace("-- crop image");
    //	DEBUG printf("(D) CropFace : crop_xy.x=%d, crop_xy.y=%d, crop_size.x=%d, crop_size.y=%d",crop_xy.x, crop_xy.y, crop_size.x, crop_size.y);
	
	cv::Rect myROI(crop_xy.x, crop_xy.y, crop_size.x, crop_size.y);
	if ((crop_xy.x+crop_size.x<MyImage.size().width)&&(crop_xy.y+crop_size.y<MyImage.size().height))
    {MyImage = MyImage(myROI);}
	else
    {
        //        trace("-- error cropping");
        return 0;
    }
    
    //resize it
    //    trace("-- resize image");
    cv::resize(MyImage, MyImage, cv::Size(dest_sz));
    
    // cv::equalizeHist( MyImage, MyImage);
    return 1;
}

// Generate an approximately reconstructed face by back-projecting the eigenvectors & eigenvalues of the given (preprocessed) face.
- (cv::Mat)reconstructFace:(cv::Mat)preprocessedFace
{
    // Since we can only reconstruct the face for some types of FaceRecognizer models (ie: Eigenfaces or Fisherfaces),
    // we should surround the OpenCV calls by a try/catch block so we don't crash for other models.
    try {
        
        // Get some required data from the FaceRecognizer model.
        cv::Mat eigenvectors = _model->get<cv::Mat>("eigenvectors");
        cv::Mat averageFaceRow = _model->get<cv::Mat>("mean");
        
        int faceHeight = preprocessedFace.rows;
        
        // Project the input image onto the PCA subspace.
        cv::Mat projection = subspaceProject(eigenvectors, averageFaceRow, preprocessedFace.reshape(1,1));
        //printMatInfo(projection, "projection");
        
        // Generate the reconstructed face back from the PCA subspace.
        cv::Mat reconstructionRow = subspaceReconstruct(eigenvectors, averageFaceRow, projection);
        //printMatInfo(reconstructionRow, "reconstructionRow");
        
        // Convert the float row matrix to a regular 8-bit image. Note that we
        // shouldn't use "getImageFrom1DFloatMat()" because we don't want to normalize
        // the data since it is already at the perfect scale.
        
        // Make it a rectangular shaped image instead of a single row.
        cv::Mat reconstructionMat = reconstructionRow.reshape(1, faceHeight);
        // Convert the floating-point pixels to regular 8-bit uchar pixels.
        cv::Mat reconstructedFace = cv::Mat(reconstructionMat.size(), CV_8U);
        reconstructionMat.convertTo(reconstructedFace, CV_8U, 1, 0);
        //printMatInfo(reconstructedFace, "reconstructedFace");
        
        averageFaceRow.release();
        eigenvectors.release();
        projection.release();
        reconstructionRow.release();
        reconstructionMat.release();
        
        return reconstructedFace;
        
    } catch (cv::Exception e) {
        //cout << "WARNING: Missing FaceRecognizer properties." << endl;
        return cv::Mat();
    }
}

// Compare two images by getting the L2 error (square-root of sum of squared error).
- (double)getSimilarity:(const cv::Mat)A with:(const cv::Mat)B
{
    if (A.rows > 0 && A.rows == B.rows && A.cols > 0 && A.cols == B.cols) {
        // Calculate the L2 relative error between the 2 images.
        double errorL2 = cv::norm(A, B, CV_L2);
        // Convert to a reasonable scale, since L2 error is summed across all pixels of the image.
        double similarity = errorL2 / (double)(A.rows * A.cols);
        return similarity;
    }
    else {
        //cout << "WARNING: Images have a different size in 'getSimilarity()'." << endl;
        return 100000000.0;  // Return a bad value
    }

}

//double getSimilarity(const cv::Mat A, const cv::Mat B)
//{
//    if (A.rows > 0 && A.rows == B.rows && A.cols > 0 && A.cols == B.cols) {
//        // Calculate the L2 relative error between the 2 images.
//        double errorL2 = cv::norm(A, B, CV_L2);
//        // Convert to a reasonable scale, since L2 error is summed across all pixels of the image.
//        double similarity = errorL2 / (double)(A.rows * A.cols);
//        return similarity;
//    }
//    else {
//        //cout << "WARNING: Images have a different size in 'getSimilarity()'." << endl;
//        return 100000000.0;  // Return a bad value
//    }
//}


@end