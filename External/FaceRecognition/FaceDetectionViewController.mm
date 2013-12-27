//
//  FaceDetectionViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/1/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "FaceDetectionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMotion/CoreMotion.h>
#import <AssertMacros.h>

#import "opencv2/highgui/ios.h"
#import "PBFaceLib.h"
#import "MotionOrientation.h"
#import "UIButton+Bootstrap.h"

#define CAPTURE_FPS 30


@interface FaceDetectionViewController ()
<UIGestureRecognizerDelegate,
AVCaptureMetadataOutputObjectsDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *previewView;
    IBOutlet UIView *faceView;
    IBOutlet UIImageView *faceImageView;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureMetadataOutput *metadataOutput;

    dispatch_queue_t videoDataOutputQueue;

    BOOL isUsingFrontFacingCamera;
    
    NSMutableDictionary *recognisedFaces;
    NSMutableDictionary *processing;
    
    BOOL isFaceRecRedy;
    
    CALayer *layer;
	CATransformLayer *transformLayer;
    CGPoint aniLoc;

    BOOL showGuide;
    UIImage *guideImage;

    BOOL isReadyToScanFace;

}
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) NSInteger numPicsTaken;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIImageView *hiveImageView;

- (IBAction)toggleFlash:(id)sender;
- (IBAction)switchCameras:(id)sender;
- (IBAction)closeCamera:(id)sender;
@end

@implementation FaceDetectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isReadyToScanFace = NO;
    [FaceLib initDetector:CIDetectorAccuracyLow Tacking:YES];
    
    if(self.faceMode == FaceModeRecognize)
        isFaceRecRedy = [FaceLib initRecognizer:LBPHFaceRecognizer models:[SQLManager getTrainModels]];
    

    recognisedFaces = @{}.mutableCopy;
    processing = @{}.mutableCopy;
    
    guideImage = [UIImage imageNamed:@"hive_line"];
    
    if(self.faceMode == FaceModeCollect){
        self.navigationController.navigationBarHidden = YES;
        [self setupGuide];
        self.numPicsTaken = 0;
    } else {
        [_hiveImageView setHidden:YES];
        [_instructionsLabel setHidden:YES];
    }

    [_closeButton bootstrapStyle];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	[self setupAVCapture];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isReadyToScanFace = YES;
}



- (void)viewWillDisappear:(BOOL)animated
{
	[self teardownAVCapture];
    
	[super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setupGuide
{

	transformLayer = [CATransformLayer layer];
	[faceView.layer addSublayer:transformLayer];
    
	layer = [CALayer layer];
	[transformLayer addSublayer:layer];
	
	
	layer.contents = (id)guideImage.CGImage;
	
    
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	[self.view addGestureRecognizer:tap];
    
    CGSize viewSize = faceView.bounds.size;
	layer.frame = CGRectMake((viewSize.width - 232)/2, (viewSize.height - 279)/2, 232, 279);
    
	transformLayer.frame =  faceView.bounds;

    showGuide = YES;

}



- (void)tap:(UITapGestureRecognizer*)tap
{
	CGPoint location = [tap locationInView:self.view];
	CGSize viewSize = self.view.bounds.size;
	aniLoc = CGPointMake((location.x - viewSize.width / 2) / viewSize.width,
                         (location.y - viewSize.height / 2) / viewSize.height);
    
//    [CATransaction begin];
//	[CATransaction setAnimationDuration:1.f];
//	transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI * aniLoc.x, 0, 1, 0), -M_PI * aniLoc.y, 1, 0, 0);
//	[CATransaction commit];
    
    [self guideAnimation:aniLoc];
}

- (void)guideAnimation:(CGPoint)point
{
    [CATransaction begin];
	[CATransaction setAnimationDuration:1.f];
<<<<<<< .merge_file_RIItGq
	transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI * aniLoc.x, 0, 1, 0), -M_PI * aniLoc.y, 1, 0, 0);
=======
	transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI * point.x, 0, 1, 0), -M_PI * point.y, 1, 0, 0);
>>>>>>> .merge_file_q8hv5z
	[CATransaction commit];

}

- (IBAction)toggleFlash:(id)sender {
}

- (IBAction)switchCameras:(id)sender {
    AVCaptureDevicePosition desiredPosition;
	if (isUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];
			break;
		}
	}
	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}

- (IBAction)closeCamera:(id)sender
{
    [self teardownAVCapture];
    
    if(self.faceMode == FaceModeCollect){
<<<<<<< .merge_file_RIItGq
        self.navigationController.navigationBarHidden = NO;
        [self performSegueWithIdentifier:SEGUE_ADDINGFACETOALBUM sender:self];
=======
        [self goNext];
>>>>>>> .merge_file_q8hv5z
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)goNext
{
    self.navigationController.navigationBarHidden = NO;
    [self performSegueWithIdentifier:SEGUE_ADDINGFACETOALBUM sender:self];

}

#pragma mark - AV setup
- (void)setupAVCapture
{
	NSError *error = nil;
	
	AVCaptureSession *session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPresetHigh] ;//AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == AVCaptureDevicePositionFront) {
			device = d;
			break;
		}
	}
    
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	require( error == nil, bail );
	{
        isUsingFrontFacingCamera = YES;
        if ( [session canAddInput:deviceInput] )
            [session addInput:deviceInput];
        
        // Make a still image output
        stillImageOutput = [AVCaptureStillImageOutput new];
        
        if ( [session canAddOutput:stillImageOutput] )
            [session addOutput:stillImageOutput];
        
        // Make a video data output
        videoDataOutput = [AVCaptureVideoDataOutput new];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                           [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [videoDataOutput setVideoSettings:rgbOutputSettings];
        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
        
        // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
        
        if ( [session canAddOutput:videoDataOutput] )
            [session addOutput:videoDataOutput];
        [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
        
        
        if(self.faceMode == FaceModeCollect){
            //FaceMetaDataOutput
            metadataOutput = [AVCaptureMetadataOutput new];
            if ([session canAddOutput:metadataOutput] ) {
                // Metadata processing will be fast, and mostly updating UI which should be done on the main thread
                // So just use the main dispatch queue instead of creating a separate one
                // (compare this to the expensive CoreImage face detection, done on a separate queue)
                [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                [session addOutput:metadataOutput];
            }
            
            if ( [metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace] ) {
                // We only want faces, if we don't set this we would detect everything available
                // (some objects may be expensive to detect, so best form is to select only what you need)
                metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeFace ];
            }
        }

        previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        CALayer *rootLayer = [previewView layer];
        [rootLayer setMasksToBounds:YES];
        [previewLayer setFrame:[rootLayer bounds]];
        [rootLayer addSublayer:previewLayer];
        [session startRunning];
        
        _frameNum = 0;
    }
bail:
    {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil] show];
            
            [self teardownAVCapture];
        }
    }
    
    
}

// clean up capture setup
- (void)teardownAVCapture
{
	//[stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
    
	[previewLayer removeFromSuperlayer];
}

- (void)clearGuide
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        @synchronized(self) {
            showGuide = NO;
            if([[faceView subviews] count]){
                for (UIView *view in [faceView subviews]) {
                    [view removeFromSuperview];
                }
            }
            
            [recognisedFaces removeAllObjects];
            [processing removeAllObjects];
        }
    });
}

#pragma mark -
- (void)processImage:(CMSampleBufferRef)sampleBuffer
{
 
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	__block CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
    
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[MotionOrientation sharedInstance] deviceOrientation]; // [[UIDevice currentDevice] orientation];
	int exifOrientation;

	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    
    NSArray *features = [FaceLib detectFace:ciImage options:imageOptions];
    
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);

    
    if(self.faceMode == FaceModeCollect) { // 얼굴 등록일 경우.
        CIFaceFeature *feature = nil;
        
        if ([features count]) {
            feature = [features objectAtIndex:0];
            
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [self drawFaceBoxeForFeature:feature forVideoBox:clap orientation:curDeviceOrientation];
//            });
        }
        
        if (self.frameNum == 15) { //매 0.5초마다 검사.
            if(ciImage && feature) [self collectFace:feature inImage:ciImage ofUserID:_UserID];
            self.frameNum = 1;
        }
        else {
            self.frameNum++;
        }
        
    }
    else { // 얼굴 인식일 경우.
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
        });
        
        if ([features count]) {
            //NSLog(@"feature tracking id: %d", ((CIFaceFeature *)features[0]).trackingID);
            
            for (CIFaceFeature *feature in features) {
                if(ciImage) [self identifyFace:feature inImage:ciImage];
            }
        }
    }


}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)faces fromConnection:(AVCaptureConnection *)connection
{
	// We can assume all received metadata objects are AVMetadataFaceObject only
	// because we set the AVCaptureMetadataOutput's metadataObjectTypes
	// to solely provide AVMetadataObjectTypeFace (see setupAVFoundationFaceDetection)
	
	if ( !previewLayer.connection.enabled )
		return; // don't update face graphics when preview is frozen
    
	//NSMutableArray* collectForFacesMetadata = [NSMutableArray arrayWithCapacity:faces.count];
    
    for ( AVMetadataFaceObject * object in faces ) {
        AVMetadataFaceObject * adjusted = (AVMetadataFaceObject*)[previewLayer transformedMetadataObjectForMetadataObject:object];
        //NSLog(@"AVMetadataFaceObject bounds:%@ / faceID:%d / rollAngle:%f / yawAngle:%f", NSStringFromCGRect(adjusted.bounds), (int)adjusted.faceID, adjusted.rollAngle, adjusted.yawAngle);
        //[collectForFacesMetadata addObject:adjusted];
    }
//    @synchronized(self.sahredFaces) {
//        [self setSahredFaces:collectForFacesMetadata];
//    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(isReadyToScanFace)
        [self processImage:sampleBuffer];
}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
    //@synchronized(self) {
        for (UIView *view in [faceView subviews]) {
            [view removeFromSuperview];
            //[view setHidden:YES];
        }
        
        NSArray *sublayers = [NSArray arrayWithArray:[previewLayer sublayers]];
        NSInteger featuresCount = [features count], currentFeature = 0;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        // hide all the face layers
        for ( CALayer *sublayer in sublayers ) {
            if ( [[sublayer name] isEqualToString:@"FaceLayer"] )
                [sublayer setHidden:YES];
        }
        
        if ( featuresCount == 0 ) {
            [CATransaction commit];
            return; // early bail.
        }
        
        CGSize parentFrameSize = [previewView frame].size;
        NSString *gravity = [previewLayer videoGravity];
        
        CGRect previewBox = [self videoPreviewBoxForGravity:gravity
                                                  frameSize:parentFrameSize
                                               apertureSize:clap.size];
        
        for ( CIFaceFeature *ff in features ) {
            
            // find the correct position for the square layer within the previewLayer
            // the feature box originates in the bottom left of the video frame.
            // (Bottom right if mirroring is turned on)
            
            CGRect faceRect = ff.bounds;
            
            // flip preview width and height
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
            CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            
            if ( isUsingFrontFacingCamera )
                faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
            else
                faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            NSString *name = recognisedFaces[[NSNumber numberWithInt:ff.trackingID]];
            
            if (([features count] > 1) && (ff.trackingID == 0)) {
                name = nil;
            }
            
            [self showFaceRect:faceRect withName:name];
            
            currentFeature++;
        }
        
        [CATransaction commit];
   // }

}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxeForFeature:(CIFaceFeature *)ff forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{

    for (UIView *view in [faceView subviews]) {
        [view removeFromSuperview];
        //[view setHidden:YES];
    }
    
	NSArray *sublayers = [NSArray arrayWithArray:[previewLayer sublayers]];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for ( CALayer *sublayer in sublayers ) {
		if ( [[sublayer name] isEqualToString:@"FaceLayer"] )
			[sublayer setHidden:YES];
	}
	
	if ( ff == nil ) {
		[CATransaction commit];
		return; // early bail.
	}
    
	CGSize parentFrameSize = [previewView frame].size;
	NSString *gravity = [previewLayer videoGravity];
	
	CGRect previewBox = [self videoPreviewBoxForGravity:gravity
                                              frameSize:parentFrameSize
                                           apertureSize:clap.size];
	
    // find the correct position for the square layer within the previewLayer
    // the feature box originates in the bottom left of the video frame.
    // (Bottom right if mirroring is turned on)
    
    CGRect faceRect = ff.bounds;
    
    // flip preview width and height
    CGFloat temp = faceRect.size.width;
    faceRect.size.width = faceRect.size.height;
    faceRect.size.height = temp;
    temp = faceRect.origin.x;
    faceRect.origin.x = faceRect.origin.y;
    faceRect.origin.y = temp;
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
    CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
    faceRect.size.width *= widthScaleBy;
    faceRect.size.height *= heightScaleBy;
    faceRect.origin.x *= widthScaleBy;
    faceRect.origin.y *= heightScaleBy;
    
    if ( isUsingFrontFacingCamera )
        faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
    else
        faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
    
    NSString *name = recognisedFaces[[NSNumber numberWithInt:ff.trackingID]];
    
    //if (([features count] > 1) && (ff.trackingID == 0)) {
    if ((ff.trackingID == 0)) {
        name = nil;
    }
    
    [self showFaceRect:faceRect withName:name];
	
	[CATransaction commit];
}

// find where the video box is positioned within the preview layer based on the video size and gravity
- (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}


#pragma mark -
- (void)collectFace:(CIFaceFeature *)feature inImage:(CIImage *)ciImage ofUserID:(int)UserID
{
    if(_numPicsTaken > 10) return;
    
    if(feature.hasLeftEyePosition && feature.hasRightEyePosition){
        UIImageOrientation imageOrient = [[MotionOrientation sharedInstance] currentImageOrientationWithFrontCamera:isUsingFrontFacingCamera MirrorFlip:NO];
        BOOL isLandScape = [[MotionOrientation sharedInstance] deviceIsLandscape];
        cv::Mat cvImage = [FaceLib getFaceImage:ciImage feature:feature orient:imageOrient landscape:isLandScape];
        
        if(cvImage.data != NULL){
            NSData *serialized = [FaceLib serializeCvMat:cvImage];

            const char* insertSQL = "INSERT INTO FaceData (UserID, image) VALUES (?, ?)";
            sqlite3_stmt *statement;
            sqlite3 *sqlDB = [SQLManager getDBContext];
            if (sqlite3_prepare_v2(sqlDB, insertSQL, -1, &statement, nil) == SQLITE_OK) {
                sqlite3_bind_int(statement, 1, UserID);
                sqlite3_bind_blob(statement, 2, serialized.bytes, serialized.length, SQLITE_TRANSIENT);
                sqlite3_step(statement);
            }
            
            sqlite3_finalize(statement);

            self.numPicsTaken++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *faceImage = [FaceLib MatToUIImage:cvImage];
                if(faceImage) [faceImageView setImage:faceImage];
<<<<<<< .merge_file_RIItGq
                
=======
                if(_numPicsTaken%2 == 0){
                    NSString *imagePath = [NSString stringWithFormat:@"hive%d.png", (int)_numPicsTaken * 10];
                    [_hiveImageView setImage:[UIImage imageNamed:imagePath]];
                }
>>>>>>> .merge_file_q8hv5z
                self.instructionsLabel.text = [NSString stringWithFormat:@"Taken %@'s face : %ld of 10", self.UserName, (long)self.numPicsTaken];
                
                if (self.numPicsTaken == 10) {
<<<<<<< .merge_file_RIItGq
                    // 종료
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Good job!"
//                                                                    message:@"10 pictures have been taken."
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"OK"
//                                                          otherButtonTitles:nil];
//                    [alert show];
                    self.navigationController.navigationBarHidden = NO;
                    [self performSegueWithIdentifier:SEGUE_ADDINGFACETOALBUM sender:self];
=======
                    [self performSelector:@selector(goNext) withObject:nil afterDelay:2];
>>>>>>> .merge_file_q8hv5z
                }
            });
            

            
        }
    }
}





- (void)identifyFace:(CIFaceFeature *)feature inImage:(CIImage *)ciImage
{
    if (!recognisedFaces[[NSNumber numberWithInt:feature.trackingID]]) {
        if (!processing[[NSNumber numberWithInt:feature.trackingID]]) {
            processing[[NSNumber numberWithInt:feature.trackingID]] = @"1";
            
            if(feature.hasLeftEyePosition && feature.hasRightEyePosition){
                
                UIImageOrientation imageOrient = [[MotionOrientation sharedInstance] currentImageOrientationWithFrontCamera:isUsingFrontFacingCamera MirrorFlip:NO];
                BOOL isLandScape = [[MotionOrientation sharedInstance] deviceIsLandscape];
                cv::Mat cvImage = [FaceLib getFaceImage:ciImage feature:feature orient:imageOrient landscape:isLandScape];
                
                if(cvImage.data != NULL){
                    [self parseFace:cvImage
                              forId:feature.trackingID];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *faceImage = [FaceLib MatToUIImage:cvImage];
                        if(faceImage) [faceImageView setImage:faceImage];
                    });
                }

            }
        }
    } else {
        //NSLog(@"%d is %@", feature.trackingID, recognisedFaces[[NSNumber numberWithInt:feature.trackingID]]);
    }
}

- (void)parseFace:(cv::Mat &)image forId:(int)trackingID
{
    NSDictionary *match = [FaceLib recognizeFace:image];
    if(match == nil) return;
    
    int UserID = [[match objectForKey:@"UserID"] intValue];
    
    NSLog(@"trackingID : %d / match: %@", trackingID, match);
    
    // Match found
    if (UserID != -1)
    {
        double confidence = [[match objectForKey:@"confidence"] doubleValue];
        
<<<<<<< .merge_file_RIItGq
        if(confidence < 50.f)
            recognisedFaces[[NSNumber numberWithInt:trackingID]] = [SQLManager getUserName:UserID];
        else
            recognisedFaces[[NSNumber numberWithInt:trackingID]] = @"Unknown";
        //[match objectForKey:@"UserName"];
        
=======
        if(confidence < 50.f){
            recognisedFaces[[NSNumber numberWithInt:trackingID]] = [SQLManager getUserName:UserID];
        }
        else if(confidence > 50.f && confidence < 70.f){
            NSString *name = [NSString stringWithFormat:@"? %@", [SQLManager getUserName:UserID]];
            recognisedFaces[[NSNumber numberWithInt:trackingID]] = name;
        }
        else {
           recognisedFaces[[NSNumber numberWithInt:trackingID]] = @"Unknown";
        }
 
>>>>>>> .merge_file_q8hv5z
    }

    [processing removeObjectForKey:[NSNumber numberWithInt:trackingID]];
}


- (void)showFaceRect:(CGRect)rect withName:(NSString *)name
{
    NSString *searchChar = @"?";
    NSRange rang =[name rangeOfString:searchChar options:NSCaseInsensitiveSearch];
    BOOL mayBe = FALSE;
    if (rang.length == [searchChar length]) mayBe = TRUE;
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.layer.contents = (id)guideImage.CGImage;
    view.layer.borderWidth = 1.0f;
<<<<<<< .merge_file_RIItGq
    view.layer.borderColor = (name) ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
=======
    view.layer.borderColor = (name && !mayBe) ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
>>>>>>> .merge_file_q8hv5z
    
    if (name) {
        UILabel *nameLabel = [UILabel new];
        nameLabel.text = name;
        [nameLabel sizeToFit];
<<<<<<< .merge_file_RIItGq
        nameLabel.textColor = [UIColor greenColor];
=======
        nameLabel.textColor = (name && !mayBe) ? [UIColor greenColor] : [UIColor redColor];
>>>>>>> .merge_file_q8hv5z
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
        
        [view addSubview:nameLabel];
    }
    
    [faceView addSubview:view];
}

@end
