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
//#import "UIButton+Bootstrap.h"
#import "BasicBottomView.h"
#import "MBSwitch.h"

#import "PBFilterViewController.h"
//#import "AddingFaceToAlbumController.h"
#import "PBSearchFaceViewController.h"
#import "AllPhotosController.h"
#import "UIButton+FaceIcon.h"
#import "NSTimer+Pause.h"

#import "RMDownloadIndicator.h"
#import "UIImage+ImageEffects.h"
#import "SDImageCache.h"

#import "FXBlurView.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"


static void *IsAdjustingFocusingContext = &IsAdjustingFocusingContext;

#define CAPTURE_FPS 30
const int TOTAL_COLLECT = 10;
const double CHANGE_IN_IMAGE_FOR_COLLECTION = 0.1; //0.3;
// How much the facial image should change before collecting a new face photo for training.
const double CHANGE_IN_SECONDS_FOR_COLLECTION = 0.2 ; //1.0 원래는 1초에 하나씩이지만 0.3초마다 수집하게 바꿈.
// How much time must pass before collecting a new face photo for training.

CGPoint AnglePoint[10] = {
    CGPointMake(160, 284),
    CGPointMake(219.5, 275.5),
    CGPointMake(52, 285.5),
    CGPointMake(155, 163),
    CGPointMake(154, 413),
    CGPointMake(32, 185.5),
    CGPointMake(86, 194.5),
    CGPointMake(232.5, 384),
    CGPointMake(91, 387),
    CGPointMake(160, 284)};

NSString *AngleDesc[10] = {
    @"중앙을 바라보세요.",
    @"왼쪽으로 고개를 돌리세요.",
    @"오른쪽으로 고개를 돌리세요.",
    @"위를 바라 보세요.",
    @"아래를 바라 보세요.",
    @"위 오른쪽을 바라 보세요.",
    @"위 왼쪽을 바라 보세요.",
    @"아래 오른쪽을 바라 보세요.",
    @"아래 왼쪽을 바라 보세요.",
    @"중앙을 보시고 웃으세요."
};

CGRect DetectFaceTabs[6] = {
    CGRectMake(195, 476, 65, 76),
    CGRectMake(59, 476, 65, 76),
    CGRectMake(162, 419, 65, 76),
    CGRectMake(94, 419, 65, 76),
    CGRectMake(227, 419, 65, 76),
    CGRectMake(29, 419, 65, 76)
};


@interface FaceDetectionViewController ()
<UIGestureRecognizerDelegate,
AVCaptureMetadataOutputObjectsDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *previewView;
    IBOutlet UIView *faceView;
    IBOutlet UIImageView *faceImageView;
    
    __weak IBOutlet UIImageView *reconstImageView;
    
    AVCaptureDeviceInput *deviceInput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureMetadataOutput *metadataOutput;

    dispatch_queue_t videoDataOutputQueue;

    BOOL isUsingFrontFacingCamera;
    BOOL isFlashOn;
    
    NSMutableDictionary *recognisedFaces;
    NSMutableDictionary *processing;
    
    BOOL isFaceRecRedy;
    
    CALayer *layer;
	CATransformLayer *transformLayer;
    CGPoint aniLoc;

    BOOL showGuide;
    UIImage *guideImage;

    BOOL isReadyToScanFace;
    
    NSArray *instructPoint;
    NSArray *instructStr;
    
    NSData *imageData;
    
    CIDetector *faceDetector;
    
    NSMutableArray *selectedUsers;
    NSMutableArray *unSelectedUSers;
    
    NSMutableArray *selectedUserButtons;
    
    cv::Mat old_prepreprocessedFace;
    double old_time;
    
    int ani_step;
    
    NSTimer *aniTimer;
    
    double currentAngle;
    BOOL isFeedingSafe;
    
    BOOL isStart;

}
@property (weak, nonatomic) IBOutlet UIView *topView;
//@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) NSInteger numPicsTaken;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIImageView *hiveImageView;
@property (weak, nonatomic) IBOutlet BasicBottomView *CameraBottomView;
@property (nonatomic, retain) MBSwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UIScrollView *faceListScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *shutterImage;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImage;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UIButton *GalleryButton;
@property (weak, nonatomic) IBOutlet UIView *DimmedView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, retain) CALayer *adjustingFocusLayer;

@property (weak, nonatomic) RMDownloadIndicator *mixedIndicator;
@property (assign, nonatomic)CGFloat downloadedBytes;

- (IBAction)toggleFlash:(id)sender;
- (IBAction)switchCameras:(id)sender;
- (IBAction)closeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)startButtonHandler:(id)sender;
- (IBAction)goAlbum:(id)sender;


@end

@implementation FaceDetectionViewController





// Add this Method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.BlurView.tintColor  = RGBA_COLOR(255, 255, 255, 0.3);
    //self.BlurView.dynamic = YES;
    //self.BlurView.alpha = 0.9;

    NSLog(@"SegueFrom = %@", _segueid);
    if([_segueid isEqualToString:@"Segue3_1to6_1"]){
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    }
    
    if(_segueid == nil){
        //viewDidload
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            // iOS 7
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        } else {
            // iOS 6
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
        
        
        
    }
    
    
    isStart = NO;
    
//    _topView.backgroundColor = [UIColor clearColor];
    
    old_time = 0;
    old_prepreprocessedFace = cv::Mat();
    
    instructPoint = @[NSStringFromCGPoint(CGPointMake(0, 0)),  ];

    isReadyToScanFace = NO;
    //[FaceLib initDetector:CIDetectorAccuracyLow Tacking:YES];
    
//    NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @(YES) };
//	faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
//
//    if(self.faceMode == FaceModeRecognize) {
//        NSArray *trainModel = [SQLManager getTrainModels];
//        NSLog(@"trainModel = %@", trainModel);
//        
//        if(!IsEmpty(trainModel)){
//            isFaceRecRedy = [FaceLib initRecognizer:LBPHFaceRecognizer models:trainModel];
//        }
//    }
    
    NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @(YES) };
	faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    if(self.faceMode == FaceModeRecognize) {
        NSArray *trainModel = [SQLManager getTrainModels];
        //NSLog(@"trainModel = %@", trainModel);
        
        if(!IsEmpty(trainModel)){
            isFaceRecRedy = [FaceLib initRecognizer:LBPHFaceRecognizer models:trainModel];
        }
    }
    
    isReadyToScanFace = YES;
    
    

    recognisedFaces = @{}.mutableCopy;
    processing = @{}.mutableCopy;
    selectedUsers = [NSMutableArray array];
    unSelectedUSers = [NSMutableArray array];
    selectedUserButtons = [NSMutableArray array];
    
    
    guideImage = [UIImage imageNamed:@"focus"];//[UIImage imageNamed:@"hive_line"];
    
    _instructionsLabel.hidden = YES;
    _nameLabel.hidden = YES;
    
    [_faceListScrollView setBackgroundColor:[UIColor blackColor]];
    [_faceListScrollView setAlpha:0.7];
    [_faceListScrollView setHidden:YES];
    
    if(self.faceMode == FaceModeCollect){
        
        self.navigationController.navigationBarHidden = YES;
        [_snapButton setHidden:YES];
        [_GalleryButton setHidden:YES];
        
        //_timeLabel.hidden = YES;

        
        [self setupGuide];
        
        _nameLabel.text = _UserName;
        
        self.numPicsTaken = 0;
        
        [_hiveImageView setHidden:YES];
        RMDownloadIndicator *mixedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(115, 450, 90, 90) type:kRMMixedIndictor];
        [mixedIndicator setBackgroundColor:[UIColor clearColor]];
        
        //    [mixedIndicator setFillColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
        //    [mixedIndicator setStrokeColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
        [mixedIndicator setFillColor:[UIColor colorWithRed:237.0/255.0 green:188.0/255.0 blue:49.0/255.0 alpha:1.0]];
        [mixedIndicator setStrokeColor:[UIColor colorWithRed:237.0/255.0 green:188.0/255.0 blue:49.0/255.0 alpha:1.0]];
        mixedIndicator.radiusPercent = 0.45;
        [self.view addSubview:mixedIndicator];
        [mixedIndicator loadIndicator];
        _mixedIndicator = mixedIndicator;
        
        _instructionsLabel.hidden = NO;
        [_instructionsLabel setText:@"Please Smile !"];
        [_instructionsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:16]];//[UIFont systemFontOfSize:16]];
        [_instructionsLabel setTextColor:[UIColor whiteColor]];
        [_instructionsLabel setShadowColor:[UIColor grayColor]];
        [_instructionsLabel setShadowOffset:CGSizeMake(1, 1)];
        [_instructionsLabel setNumberOfLines:2];
        [_instructionsLabel setBackgroundColor:[UIColor clearColor]];
        [_instructionsLabel setTextAlignment:NSTextAlignmentCenter];
        
        _nameLabel.hidden = NO;
        
        [_nameLabel setText:@"Sahra"];
        [_nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:16]];
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_nameLabel setShadowColor:[UIColor grayColor]];
        [_nameLabel setShadowOffset:CGSizeMake(1, 1)];
        [_nameLabel setNumberOfLines:2];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        layer.hidden = YES;
        _switchButton.hidden = YES;
        _nameLabel.hidden = YES;
        _instructionsLabel.hidden = YES;
        _mixedIndicator.hidden = YES;
        
        
        
    } else {
        [_GalleryButton setHidden:YES];
        _DimmedView.hidden = YES;
        _startButton.hidden = YES;
        
        //[_closeButton setHidden:YES];
        [_hiveImageView setHidden:YES];
        [_instructionsLabel setHidden:YES];
        
        self.cameraSwitch = [[MBSwitch alloc] initWithFrame:CGRectMake(248, 41, 61.0, 18.0)]; //12
        [self.CameraBottomView addSubview:_cameraSwitch];
        [_cameraSwitch addTarget:self action:@selector(switchCameraVideo:) forControlEvents:UIControlEventValueChanged];
        
#warning 이번 버전(최초)에서는 카메라/비디오 스위치와 비디오 모드 빼고 가기로 함.
        _cameraSwitch.hidden = YES;
        _cameraImage.hidden = YES;
        _videoImage.hidden = YES;
    }

    [_closeButton bootstrapStyle];
    
    ani_step = 0;
    currentAngle = 0.0;
    //[self startTimer];
    

    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    
    
    [self refreshAlbumIcon];
}




//
//- (UIViewController *)childViewControllerForStatusBarHidden {
//    return nil;
//}



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    self.navigationController.navigationBarHidden = YES;
    
    
    NSLog(@"- (void)viewWillAppear:(BOOL)animated ");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationEventHandler:)
												 name:MotionOrientationChangedNotification object:nil];

	
    
    [self setupAVCapture];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    

    
}




- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
     NSLog(@"- (void)viewWillDisappear:(BOOL)animated ");
    
    
    isReadyToScanFace = NO;
    [self teardownAVCapture];
    [selectedUsers removeAllObjects];
    [unSelectedUSers removeAllObjects];
    [selectedUserButtons removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MotionOrientationChangedNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (void)OrientationEventHandler:(NSNotification *)notification
{
    double degree = [[MotionOrientation sharedInstance] degreeOrientation];
    NSLog(@"Orientation = %f", degree);
    currentAngle = degree * (M_PI/180.0);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [UIView animateWithDuration:0.2 animations:^{
            _shutterImage.transform = CGAffineTransformMakeRotation(currentAngle) ;
            _cameraImage.transform = CGAffineTransformMakeRotation(currentAngle) ;
            _videoImage.transform = CGAffineTransformMakeRotation(currentAngle) ;
            _GalleryButton.transform = CGAffineTransformMakeRotation(currentAngle) ;
            
            _flashButton.transform  = CGAffineTransformMakeRotation(currentAngle) ;
            _switchButton.imageView.transform  = CGAffineTransformMakeRotation(currentAngle) ;
            
            // Face Icon rotate
            for(UIView *view in _faceListScrollView.subviews){
                if([view isKindOfClass:[UIButton class]]){
                    view.transform  = CGAffineTransformMakeRotation(currentAngle) ;
                }
            }
        }];

    });

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
    //layer.frame = CGRectMake(viewSize.width/2 - 150, viewSize.height/2 - 150, 300, 300);
	transformLayer.frame =  faceView.bounds;

    showGuide = YES;

}



- (void)tap:(UITapGestureRecognizer*)tap
{
	CGPoint location = [tap locationInView:self.view];
	CGSize viewSize = self.view.bounds.size;
	aniLoc = CGPointMake((location.x - viewSize.width / 2) / viewSize.width,
                         (location.y - viewSize.height / 2) / viewSize.height);
 
    NSLog(@"GuidePoint = %@ in View(%@)", NSStringFromCGPoint(location), NSStringFromCGRect(self.view.bounds));
    [self guideAnimation:aniLoc];
}

- (void)guideAnimation:(CGPoint)point
{
    [CATransaction begin];
	[CATransaction setAnimationDuration:1.f];
	transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI * point.x, 0, 1, 0), -M_PI * point.y, 1, 0, 0);
	[CATransaction commit];
    
}

- (void)startTimer
{
    if(ani_step < 9)
        aniTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(spinit:) userInfo:nil repeats:YES];
        //[self performSelector:@selector(spinit:) withObject:nil afterDelay:3];
}

- (void)spinit:(NSTimer *)timer
{
     dispatch_async(dispatch_get_main_queue(), ^{

         if(ani_step > 9) {
             [aniTimer invalidate];
             aniTimer = nil;
             _instructionsLabel.text = @"수고하셨습니다";
             return;
         }
         
         // AnglePoint[10] AngleDesc[10]
         
         CGPoint location = AnglePoint[ani_step];
         CGSize viewSize = self.view.bounds.size;
         aniLoc = CGPointMake((location.x - viewSize.width / 2) / viewSize.width,
                              (location.y - viewSize.height / 2) / viewSize.height);
         
         NSLog(@"GuidePoint = %@ in View(%@)", NSStringFromCGPoint(location), NSStringFromCGRect(self.view.bounds));
         
         _instructionsLabel.text = AngleDesc[ani_step];
         
         [self guideAnimation:aniLoc];
         
         ani_step++;
         
         [aniTimer pause];
     });
    

    
    
    //[aniTimer pause];
    
}

//center = 160,284
//{320, 568}
//
//중앙        CGPointMake(160, 284)
//왼쪽        CGPointMake(219.5, 275.5)
//오른족       CGPointMake(52, 285.5)
//위          CGPointMake(155, 163)
//아래        CGPointMake(154, 413)
//위 오른쪽     CGPointMake(32, 185.5)
//위 왼쪽      CGPointMake(86, 194.5)
//아래 오른족    CGPointMake(232.5, 384)
//아래 왼쪽     CGPointMake(91, 387)
//중앙        CGPointMake(160, 284)
//웃어라
//찡그려라


- (IBAction)toggleFlash:(id)sender
{
//    [self setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];

    if(isFlashOn)
        [self setFlashMode:AVCaptureFlashModeOff];
    else
        [self setFlashMode:AVCaptureFlashModeOn];
    
    isFlashOn = !isFlashOn;
        
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    if (isUsingFrontFacingCamera) return;
    
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device hasFlash] && [device isFlashModeSupported:flashMode])
        {
            NSError *error = nil;
            if ([device lockForConfiguration:&error])
            {
                [device setFlashMode:flashMode];
                [device unlockForConfiguration];
                if(flashMode == AVCaptureFlashModeOff)
                    [_flashButton setImage:[UIImage imageNamed:@"flash_camera_selcet.png"] forState:UIControlStateNormal];
                else if(flashMode == AVCaptureFlashModeOn)
                    [_flashButton setImage:[UIImage imageNamed:@"flash_camera.png"] forState:UIControlStateNormal];
            }
            else
            {
                NSLog(@"%@", error);
            }
        }
	}
}


- (IBAction)switchCameras:(id)sender {
    [self clearGuide];
    
    isFeedingSafe = NO;
    
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
    if(isUsingFrontFacingCamera)  _flashButton.enabled = NO;
    else _flashButton.enabled = YES;
    
    isFeedingSafe = YES;
}


- (IBAction)closeCamera:(id)sender
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    self.navigationController.navigationBarHidden = NO;
    
    if([_segueid isEqualToString:@"FromMenu"]){
        [self.sideMenuViewController presentMenuViewController];
    }
    else { // Go MainDashBoard
        NSArray *trainModel = [SQLManager getTrainModelsForID:self.UserID];
        if(IsEmpty(trainModel)){
            [SQLManager deleteUser:self.UserID];
        }
        
        self.modalTransitionStyle =   UIModalTransitionStyleFlipHorizontal;
        
        [self dismissViewControllerAnimated:YES completion:^{

        }];

    }
    
    
    
    
    
}


//- (IBAction)closeCamera:(id)sender
//{
//    //[self teardownAVCapture];
//    
//    if(self.faceMode == FaceModeCollect && [_segueid isEqualToString:SEGUE_FACEANALYZE])
//    {
//        [self goNext];
//        
//    } else {
//        if([_segueid isEqualToString:SEGUE_3_1_TO_6_1]) {
//            // Check face DB
//        }
//        
//        self.navigationController.navigationBarHidden = NO;
//        [self.navigationController popViewControllerAnimated:YES];
//        //[self dismissViewControllerAnimated:YES completion:nil];
//    }
//}


- (IBAction)snapStillImage:(id)sender
{
    [[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)previewLayer connection] videoOrientation]];
    // Capture a still image.
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer)
        {
            imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            ALAssetsLibrary *assLib = [[ALAssetsLibrary alloc] init];
            
            [assLib saveImageData:imageData
                         metadata:nil
                          toAlbum:@"Pixbee"
              withCompletionBlock:^(NSURL *assetURL, NSError *error) {
                  if (error) {
                      //if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]) {
                      if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized) {
                          
                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                          BOOL showCameraRollGuide = [userDefaults boolForKey:@"SHOWCAMERAROLLGUIDE"];
                          
                          if (!showCameraRollGuide) {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"To save Photos to Camera Roll", @"To save Photos to Camera Roll")
                                                                              message:NSLocalizedString(@"Go to iPhone Settings > Privacy > Photo,\nand turn ON Pixbee.", @"Go to iPhone Settings > Privacy > Photo,\nand turn ON Pudding Camera.")
                                                                             delegate:nil
                                                                    cancelButtonTitle:NSLocalizedString(@"Done", @"Done")
                                                                    otherButtonTitles:nil];
                              [alert show];
                              
                              [userDefaults setBool:YES forKey:@"SHOWCAMERAROLLGUIDE"];
                              [userDefaults synchronize];
                          }
                      }
                      // }
                  }
                  
                  else {
                      UIImage *image = [UIImage imageWithData:imageData];
                      image = [image fixRotation];
                      [[SDImageCache sharedImageCache] storeImage:image forKey:@"LastImage" toDisk:YES];
                      
                      NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
                      
                      [self savePhoto:assetURL users:selectedUsers];
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                                          object:self
                                                                        userInfo:@{@"refreshBGImage":@"YES"}];
                  }
            }];
            
            
            
//            [[[ALAssetsLibrary alloc] init] writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error2)
//             {
////                 if (error2) {
////                     NSLog(@"ERROR: the image failed to be written");
////                 }
//                 
//                 if (error2) {
//                     //if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]) {
//                         if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized) {
//                             
//                             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                             BOOL showCameraRollGuide = [userDefaults boolForKey:@"SHOWCAMERAROLLGUIDE"];
//                             
//                             if (!showCameraRollGuide) {
//                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"To save Photos to Camera Roll", @"To save Photos to Camera Roll")
//                                                                                 message:NSLocalizedString(@"Go to iPhone Settings > Privacy > Photo,\nand turn ON Pixbee.", @"Go to iPhone Settings > Privacy > Photo,\nand turn ON Pudding Camera.")
//                                                                                delegate:nil
//                                                                       cancelButtonTitle:NSLocalizedString(@"Done", @"Done")
//                                                                       otherButtonTitles:nil];
//                                 [alert show];
//                                 
//                                 [userDefaults setBool:YES forKey:@"SHOWCAMERAROLLGUIDE"];
//                                 [userDefaults synchronize];
//                             }
//                         }
//                    // }
//                 }
//                 
//                 else {
//                     NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
//                     
//                     [self savePhoto:assetURL users:selectedUsers];
//                 }
//             }];
        }
    }];
}

- (IBAction)startButtonHandler:(id)sender {
   
    [UIView animateWithDuration:0.5
                     animations:^{
                         _DimmedView.alpha = 0.0;
                         _startButton.hidden = YES;
                         layer.hidden = NO;
                         _switchButton.hidden = NO;
                         //_nameLabel.hidden = NO;
                         _instructionsLabel.hidden = NO;
                         _mixedIndicator.hidden = NO;
                         
                     } completion:^(BOOL finished) {
                         isStart = YES;
                     }];
}

- (IBAction)goAlbum:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    [self performSegueWithIdentifier:@"Segue6_1to4_3" sender:self];

}

- (void)savePhoto:(NSURL *)assetURL users:(NSArray*)users
{
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
    {
//        NSLog(@"success load ALAsset.... ");
//        //UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
//        [SQLManager saveNewUserPhotoToDB:asset users:users];
//        int count = (int)AssetLib.totalAssets.count;
//        NSString *GroupURL = [AssetLib.totalAssets[count-1] objectForKey:@"GroupURL"];
//        [AssetLib.totalAssets addObject:@{@"Asset":asset , @"GroupURL":GroupURL}];
//        NSLog(@"Last TotalAsset[%d] = %@", count, AssetLib.totalAssets[count-1]);
        
        
        NSLog(@"success load ALAsset.... ");
        NSLog(@"SAVE || selectedUsers = %@", users);
        [SQLManager saveNewUserPhotoToDB:asset users:users];
        
//        int count = 0;
//        for (NSArray *array in AssetLib.totalAssets) {
//            count = count + (int)[array count];
//        }
        NSString *GroupURL = AssetLib.totalAssets[0][0][@"GroupURL"];
        
        //[AssetLib.totalAssets[count-1] addObject:@{@"Asset":asset , @"GroupURL":GroupURL}];
        
        NSMutableArray *array = [AssetLib.totalAssets lastObject];
        [array addObject:@{@"Asset":asset , @"GroupURL":GroupURL}];
        
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        GlobalValue.lastAssetURL = assetURL.absoluteString;
        
        [self refreshAlbumIcon];
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
    };
    
    [AssetLib.assetsLibrary assetForURL:assetURL
                            resultBlock:resultBlock
                           failureBlock:failureBlock];

}

- (void)refreshAlbumIcon
{
    [AssetLib loadThumbImage:^(UIImage *thumbImage)
     {
         [_GalleryButton setImage:thumbImage forState:UIControlStateNormal];
     }];
}

- (void)switchCameraVideo:(id)sender {
}

- (void)goNext
{
    self.navigationController.navigationBarHidden = NO;
    //[self performSegueWithIdentifier:SEGUE_6_1_TO_2_2 sender:self];
    
    
    
    [self performSegueWithIdentifier:@"goInvitation" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:SEGUE_GO_FILTER]){
//        self.navigationController.navigationBarHidden = NO;
//        PBFilterViewController *destination = segue.destinationViewController;
//        destination.imageData = imageData;
//        
//    }
//    else
    
    
    
    if([segue.identifier isEqualToString:SEGUE_6_1_TO_2_2]){
        PBSearchFaceViewController *destination = segue.destinationViewController;
        destination.UserName = self.UserName;
        destination.UserID = self.UserID;
    }
    else if([segue.identifier isEqualToString:SEGUE_6_1_TO_4_4]){
        AllPhotosController *destination = segue.destinationViewController;
        destination.segueIdentifier = SEGUE_6_1_TO_4_4;

    }
    else if([segue.identifier isEqualToString:@"Segue6_1to4_3"]){ // Back MainDashBoard

        
    }

}

- (void)addNewFaceButton:(int)UserID
{

    int faceCount = (int)[selectedUsers count];
    
    //5개 까지만 허용
    if(faceCount > 5) return;
    
    // 동일 사용자 중복 체크
    if ([selectedUsers containsObject:@(UserID)]) return;

    UIImage *profileImage = [SQLManager getUserProfileImage:UserID];
    
    UIButton_FaceIcon* button = [UIButton_FaceIcon buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(imageTouch:withEvent:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(imageEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    button.choice = NO;
    [button setPenTagonProfileImage:profileImage];
    
    
    button.frame = DetectFaceTabs[faceCount];
    
    button.UserID = UserID;
    button.index = faceCount;
    button.originRect = button.frame;
    
    [self.view addSubview:button];

    [selectedUsers addObject:@(UserID)];
    [selectedUserButtons addObject:button];
    
    NSLog(@"ADD || selectedUsers = %@", selectedUsers);
    NSLog(@"facecount = %d / frame = %@",faceCount, NSStringFromCGRect(button.frame));
    
    //[_faceListScrollView setContentSize:CGSizeMake(10 + faceCount*60 + 50, 67.0)];
}

- (void) imageTouch:(id) sender withEvent:(UIEvent *) event
{

    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    UIButton_FaceIcon *button0 = (UIButton_FaceIcon*)sender;
 
    button0.originRect = button0.frame;
    button0.center = point;
    
    [UIView animateWithDuration:0.2 animations:^{
        button0.frame = CGRectMake(button0.frame.origin.x, button0.frame.origin.y - 50, 100, 100);
        [button0 setImage:nil forState:UIControlStateNormal];
        [button0 setBackgroundImage:button0.profileImage forState:UIControlStateNormal];
    }];
}

- (void) imageMoved:(id)sender withEvent:(UIEvent *) event
{
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    control.center = point;
}

- (void) imageEnd:(id) sender withEvent:(UIEvent *) event
{
 
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    
    UIButton_FaceIcon *button0 = (UIButton_FaceIcon*)sender;
    
    int index = button0.index;
    
    if(!CGRectContainsPoint (DetectFaceTabs[index], point)){
        NSLog(@"---------------Drag End Outside");
        
        int userid = button0.UserID;
        
        [self exceptUSerFromTrainDB:userid];
        [selectedUserButtons removeObject:button0];
        
        [button0 removeFromSuperview];
        NSLog(@"REMOVE || selectedUsers = %@", selectedUsers);
        
        if(!IsEmpty(selectedUserButtons)){
            NSInteger userButtonCount = [selectedUserButtons count];
            for(NSInteger i = 0; i < userButtonCount; i++){
                UIButton_FaceIcon *button1 = [selectedUserButtons objectAtIndex:i];
                button1.frame = DetectFaceTabs[i];
            }
        }
        
        
        
    } else {
        NSLog(@"---------------Drag End Inside ==> TouchUpInside");
        UIImage *profileImage = [SQLManager getUserProfileImage:button0.UserID];
        button0.frame = DetectFaceTabs[index];
        
        button0.choice = !button0.choice;
        
        [button0 setPenTagonProfileImage:profileImage];
        
        //[button0 setImage:profileImage forState:UIControlStateNormal];
        //[button0 setBackgroundImage:nil forState:UIControlStateNormal];
        //[self.view addSubview:button0];

        
    }
}


//- (void)addNewFaceIcon:(int)UserID
//{
//    [_faceListScrollView setHidden:NO];
//    
//    int faceCount = (int)_faceListScrollView.subviews.count;
//    
//    // 동일 사용자 중복
//    for(UIView *view in _faceListScrollView.subviews){
//        if([view isKindOfClass:[UIButton class]]){
//            UIButton_FaceIcon *button = (UIButton_FaceIcon*)view;
//            if(button.UserID == UserID) return;
//        }
//    }
//    
//    UIImage *profileImage = [SQLManager getUserProfileImage:UserID];
//
//    UIButton_FaceIcon* button = [UIButton_FaceIcon buttonWithType:UIButtonTypeCustom];
//    [button addTarget:self action:@selector(imageTouch:withEvent:) forControlEvents:UIControlEventTouchDown];
//    [button addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
//    [button addTarget:self action:@selector(imageEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
//    
//    //[button setProfileImage:profileImage];
//    [button setPenTagonProfileImage:profileImage];
//
//    button.frame = CGRectMake(10+faceCount*60, 9.0f, 50.0f, 50.0f);
//    button.UserID = UserID;
//    button.index = faceCount;
//    button.originRect = button.frame;
//    
//    [_faceListScrollView addSubview:button];
//
//    [selectedUsers addObject:@(UserID)];
//    
//    NSLog(@"ADD || selectedUsers = %@", selectedUsers);
//    NSLog(@"facecount = %d / frame = %@",faceCount, NSStringFromCGRect(button.frame));
//    
//    [_faceListScrollView setContentSize:CGSizeMake(10 + faceCount*60 + 50, 67.0)];
////    [_faceListScrollView setContentOffset:button.frame.origin animated:YES];
//    
//}

//
//- (void) imageTouch:(id) sender withEvent:(UIEvent *) event
//{
//    if(_faceListScrollView.dragging || _faceListScrollView.decelerating) return;
//    
//    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
//    UIButton_FaceIcon *button0 = (UIButton_FaceIcon*)sender;
//    [self.view addSubview:button0];
//    button0.originRect = button0.frame;
//    button0.center = point;
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        button0.frame = CGRectMake(button0.frame.origin.x, button0.frame.origin.y - 50, 100, 100);
//        [button0 setImage:nil forState:UIControlStateNormal];
//        [button0 setBackgroundImage:button0.profileImage forState:UIControlStateNormal];
//    }];
//
//    int index = button0.index;
//    
//    // Face Icon 재정렬
//    for(UIView *view in _faceListScrollView.subviews){
//        if([view isKindOfClass:[UIButton class]]){
//            UIButton_FaceIcon *button = (UIButton_FaceIcon*)view;
//            if(button.index > index){
//                button.index = button.index - 1;
//                [UIView animateWithDuration:0.2 animations:^{
//                    button.frame = CGRectMake(10+button.index*60, 9.0f, 50.0f, 50.0f);
//                    button.originRect = button.frame;
//                }];
//            }
//        }
//    }
//    
//}
//
//- (void) imageMoved:(id)sender withEvent:(UIEvent *) event
//{
//    if(_faceListScrollView.dragging || _faceListScrollView.decelerating) return;
//    
//    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
//    UIControl *control = sender;
//    control.center = point;
//}
//
//- (void) imageEnd:(id) sender withEvent:(UIEvent *) event
//{
//    if(_faceListScrollView.dragging || _faceListScrollView.decelerating) return;
//    
//    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
//    
//    UIButton_FaceIcon *button0 = (UIButton_FaceIcon*)sender;
//
//    if(!CGRectContainsPoint (_faceListScrollView.frame, point)){
//        NSLog(@"---------------Drag End Outside");
//        
//        [button0 removeFromSuperview];
//        
//        int userid = button0.UserID;
//        
//        [self exceptUSerFromTrainDB:userid];
//        
//        NSLog(@"REMOVE || selectedUsers = %@", selectedUsers);
//        
//    
//    } else {
//        NSLog(@"---------------Drag End Inside");
//        
//        int index = button0.index;
//
//        for(UIView *view in _faceListScrollView.subviews){
//            if([view isKindOfClass:[UIButton class]]){
//                UIButton_FaceIcon *button = (UIButton_FaceIcon*)view;
//                if(button.index >= index){
//                    button.index = button.index + 1;
//                    [UIView animateWithDuration:0.2 animations:^{
//                        button.frame = CGRectMake(10+button.index*60, 9.0f, 50.0f, 50.0f);
//                        button.originRect = button.frame;
//                    }];
//                }
//            }
//        }
//        
//        button0.frame = CGRectMake(10+index*60, 9.0f, 50.0f, 50.0f);
//        [button0 setImage:button0.profileImage forState:UIControlStateNormal];
//        [button0 setBackgroundImage:nil forState:UIControlStateNormal];
//        [_faceListScrollView addSubview:button0];
//    }
//}

- (void)exceptUSerFromTrainDB:(int)userid
{
    [selectedUsers removeObject:@(userid)];
    [unSelectedUSers addObject:@(userid)];
    //if(![unSelectedUSers containsObject:@(userid)])
        
    
    NSArray *users = [SQLManager getAllUsers];
    int userCount = (int)[users count];
    int unSelectedUserCount = (int)[unSelectedUSers count];
    
    [self clearGuide];
    
    isFaceRecRedy = NO;
    
    if(userCount > unSelectedUserCount) {
        NSArray *trainModel = [SQLManager getTrainModels];
        if(!IsEmpty(trainModel))
            [FaceLib trainModel:trainModel withOut:unSelectedUSers];
    }
    else if(userCount <= unSelectedUserCount){
        [unSelectedUSers removeAllObjects];
        NSArray *trainModel = [SQLManager getTrainModels];
        if(!IsEmpty(trainModel))
            [FaceLib trainModel:trainModel];

    }

    isFaceRecRedy = YES;

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
    
	deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
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
        
        isFlashOn = NO;
        [self setFlashMode:AVCaptureFlashModeOff];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cameraWantsRefocus:)
                                                     name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:IsAdjustingFocusingContext];
        
        
        if ( !self.adjustingFocusLayer) {
            CALayer *adjustingFocusBox = [self createLayerBoxWithColor:[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:.8f]];
            [self.view.layer addSublayer:adjustingFocusBox];
            self.adjustingFocusLayer = adjustingFocusBox;
        }
        
        isFeedingSafe = YES;

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
            
            isFeedingSafe = NO;
        }
        
       
    }
    
    
}

// clean up capture setup
- (void)teardownAVCapture
{
	//[stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[previewLayer removeFromSuperlayer];
    self.adjustingFocusLayer = nil;
}

- (void)cameraWantsRefocus:(NSNotification *)n
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ( YES == [device lockForConfiguration:NULL] ) {
		if ( [device isFocusPointOfInterestSupported] ) {
			[device setFocusPointOfInterest:CGPointMake(.5, .5)];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
		}
		if ( [device isExposurePointOfInterestSupported] ) {
			[device setExposurePointOfInterest:CGPointMake(.5, .5)];
			[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
		}
		[device setSubjectAreaChangeMonitoringEnabled:NO];
		[device unlockForConfiguration];
	}
    
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

- (CALayer *)createLayerBoxWithColor:(UIColor *)color
{
    NSDictionary *unanimatedActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"bounds",[NSNull null], @"frame",[NSNull null], @"position", nil];
    CALayer *box = [[CALayer alloc] init];
    [box setActions:unanimatedActions];
    [box setBorderWidth:1.f];
    [box setBorderColor:[color CGColor]];
    [box setOpacity:0.f];
    [unanimatedActions release];
    
    return [box autorelease];
}

- (void)addAdjustingAnimationToLayer:(CALayer *)focusLayer removeAnimation:(BOOL)remove
{
    if (remove) {
        [focusLayer removeAnimationForKey:@"animateOpacity"];
    }
    if ([focusLayer animationForKey:@"animateOpacity"] == nil) {
        [focusLayer setHidden:NO];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setDuration:.3f];
        [opacityAnimation setRepeatCount:1.f];
        [opacityAnimation setAutoreverses:YES];
        [opacityAnimation setFromValue:@1.f];
        [opacityAnimation setToValue:@.0f];
        [focusLayer addAnimation:opacityAnimation forKey:@"animateOpacity"];
    }
}

// 포커스가 변경되면 호출되는 부분...
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( context == IsAdjustingFocusingContext ) {
		BOOL isAdjusting = [change[NSKeyValueChangeNewKey] boolValue];
		CALayer *focusLayer = self.adjustingFocusLayer;
		[focusLayer setBorderWidth:2.f];
		[focusLayer setBorderColor:[[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:.7f] CGColor]];
		[focusLayer setCornerRadius:8.f];
		[self addAdjustingAnimationToLayer:layer removeAnimation:YES];
		
		if (isAdjusting == YES) {
			// Size the layer
			CGPoint poi = [(AVCaptureDevice *)object focusPointOfInterest];
			CGSize layerSize;
			if ( CGPointEqualToPoint(poi, CGPointMake(.5, .5)) )
                //				layerSize = CGSizeMake(self.previewView.bounds.size.width * .8, self.previewView.bounds.size.height * .8);
                layerSize = CGSizeMake(self.view.bounds.size.width * .6, self.view.bounds.size.height * .6);
			else {
                //				CGFloat points = MIN(self.previewView.bounds.size.width * .25, self.previewView.bounds.size.height * .25);
                CGFloat points = MIN(self.view.bounds.size.width * .2, self.view.bounds.size.height * .2);
				layerSize = CGSizeMake(points, points);
			}
            //			poi = [(AVCaptureVideoPreviewLayer *)self.previewView.layer pointForCaptureDevicePointOfInterest:poi];
            poi = [self pointForCaptureDevicePointOfInterest:poi];
			[focusLayer setFrame:CGRectMake(0., 0., layerSize.width, layerSize.height)];
			[focusLayer setPosition:poi];
            
            NSLog(@"==============================> LayerSize c_x : %f / c_y : %f / width : %f / height : %f", poi.x, poi.y, layerSize.width, layerSize.height);
            NSLog(@"==============================> ViewSize width : %f / height : %f", self.view.bounds.size.width, self.view.bounds.size.height);
		}
	}
}

// 스크린 화면을 위한 POI (화면사이즈)
- (CGPoint)pointForCaptureDevicePointOfInterest:(CGPoint)pointOfInterest
{
    CGPoint point;
    // Otherwise manually convert the point from point-of-interest coordinates
    // to preview layer coordinates. Notice we set the content gravity of the
    // preview layer to AVLayerVideoGravityResizeAspectFill.
    CGRect bounds = [self.view bounds];
    CGFloat width = CGRectGetWidth(bounds); //CGRectGetHeight(bounds);
    CGFloat height = CGRectGetHeight(bounds); //CGRectGetWidth(bounds);
    //    CGFloat aspectRatio = self.view.frame.size.height / self.view.frame.size.width;
    //    if (width / height > aspectRatio) {
    //        point.x = (pointOfInterest.y - 0.5) * width * aspectRatio - height / 2.0;
    //        point.y = pointOfInterest.x * width;
    //    } else {
    point.x = pointOfInterest.x * width; //(1.0 - pointOfInterest.x) * width;
    point.y = pointOfInterest.y * height; //(1.0 - pointOfInterest.y) * height; //(0.5 - pointOfInterest.x) * height / aspectRatio - width / 2.0;
    //    }
    
    //    point = self.view.center;
    return point;
}

// 카메라 디바이스를 위한 POI (0 ~ 1)
- (CGPoint)captureDevicePointOfInterestForPoint:(CGPoint)point
{
    // Same discussion above.
    CGPoint pointOfInterest;
    
    
    CGRect bounds = [self.view bounds];
    CGFloat width = CGRectGetWidth(bounds); //bounds.size.width; // CGRectGetHeight(bounds);
    CGFloat height = CGRectGetHeight(bounds); //bounds.size.height; // CGRectGetWidth(bounds);
    //    CGFloat aspectRatio = self.view.frame.size.height / self.view.frame.size.width;
    //    if (width / height > aspectRatio) {
    pointOfInterest.x = point.x / width;
    pointOfInterest.y = point.y / height; //0.5 + (height / 2.0 + point.y) / width / aspectRatio;
    //    } else {
    //        pointOfInterest.x = 0.5 - (width / 2.0 + point.y) / height * aspectRatio;
    //        pointOfInterest.y = 1.0 - point.x / height;
    //    }
    
    //pointOfInterest = CGPointMake(0.5, 0.5);
    
    return pointOfInterest;
}


#pragma mark -
//- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer

- (void)processImage:(CMSampleBufferRef)sampleBuffer
{
    if(!isReadyToScanFace) return;
    
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
    
//    //// add auto enhance
//    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustRedEye]];
//    
//	for (CIFilter* filter in adjustments)
//	{
//		[filter setValue:ciImage forKey:kCIInputImageKey];
//		ciImage = filter.outputImage;
//	}
//    //// add auto enhance
    
	UIDeviceOrientation curDeviceOrientation = [[MotionOrientation sharedInstance] deviceOrientation];
    // [[UIDevice currentDevice] orientation];
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
    
	NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    
    NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
    
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    
    
    if(self.faceMode == FaceModeCollect) { // 얼굴 등록일 경우.
        
        if(!isStart) return;
        
        CIFaceFeature *feature = nil;
        
        if ([features count]) {
            feature = [features objectAtIndex:0];
        }
        
        if (self.frameNum == 15) { //매 0.5초마다 검사.
            if(ciImage && [features count] == 1){
                dispatch_async(dispatch_get_main_queue(), ^(void) {

                    [self collectFace:feature inImage:ciImage ofUserID:_UserID];
                    

                    
                });
                
            }
            else if(ciImage && [features count] > 1 ) {
#warning 한명 이상은 얼굴 등록 할 수 없음 메시지 뿌려주기
                
            }
            self.frameNum = 1;
        }
        else {
            self.frameNum++;
        }
        
    }
    else { // 얼굴 인식일 경우.
        if(isFaceRecRedy){
            if(IsEmpty(features)){
                [recognisedFaces removeAllObjects];
                [processing removeAllObjects];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
            });
            
            if ([features count]) {
                //NSLog(@"feature tracking id: %d", ((CIFaceFeature *)features[0]).trackingID);
                
                for (CIFaceFeature *feature in features) {
                    if(ciImage){
                        [self identifyFace:feature inImage:ciImage];
                    }
                }
            }
        }
#warning 얼굴인식 데이터가 없을 때 안내 메시지? 뿌려주기.
        else {
            
        }
    }
    
}

// 화면 터치하면 얼굴인식 다시 되게..
- (void)tapScreen:(id)sender
{
    [self clearGuide];
}


//- (void)processImage:(CMSampleBufferRef)sampleBuffer
//{
// 
//	// got an image
//	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
//	__block CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
//	if (attachments)
//		CFRelease(attachments);
//
//	UIDeviceOrientation curDeviceOrientation = [[MotionOrientation sharedInstance] deviceOrientation];
//    // [[UIDevice currentDevice] orientation];
//	int exifOrientation;
//
//	enum {
//		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
//		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
//		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
//		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
//		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
//		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
//		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
//		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
//	};
//	
//	switch (curDeviceOrientation) {
//		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
//			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
//			break;
//		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
//			if (isUsingFrontFacingCamera)
//				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
//			else
//				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
//			break;
//		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
//			if (isUsingFrontFacingCamera)
//				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
//			else
//				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
//			break;
//		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
//		default:
//			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
//			break;
//	}
//    
//	NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
// 
//    NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
//    
//    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
//
//    
//    if(self.faceMode == FaceModeCollect) { // 얼굴 등록일 경우.
//        CIFaceFeature *feature = nil;
//        
//        if ([features count]) {
//            feature = [features objectAtIndex:0];
//        }
//        
//        if (self.frameNum == 15) { //매 0.5초마다 검사.
//            if(ciImage && [features count] == 1)
//                [self collectFace:feature inImage:ciImage ofUserID:_UserID];
//            else if(ciImage && [features count] > 1 ) {
//#warning 한명 이상은 얼굴 등록 할 수 없음 메시지 뿌려주기
//                
//            }
//            self.frameNum = 1;
//        }
//        else {
//            self.frameNum++;
//        }
//        
//    }
//    else { // 얼굴 인식일 경우.
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
//        });
//        
//        if ([features count]) {
//            //NSLog(@"feature tracking id: %d", ((CIFaceFeature *)features[0]).trackingID);
//            
//            for (CIFaceFeature *feature in features) {
//                if(ciImage) [self identifyFace:feature inImage:ciImage];
//            }
//        }
//    }
//
//}

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
    if(isFeedingSafe){
        [self processImage:sampleBuffer];
    }
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
            
            NSString *name = nil;
            if(!IsEmpty(recognisedFaces))
                name = recognisedFaces[@(ff.trackingID)];
            
            if (([features count] > 1) && (ff.trackingID == 0)) {
                name = nil;
            }
            
            if(!IsEmpty(name)){
                if(!GlobalValue.testMode) {

                    if ([name rangeOfString:@"Unknown"].location != NSNotFound) {
                        name = @"Unknown";
                    }
                    
                    else {
                        name = [self getPrefix:name divider:@":"];
                    }
                }
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
    
    NSString *name = recognisedFaces[@(ff.trackingID)];
    
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
//- (void)collectFace:(CIFaceFeature *)feature inImage:(CIImage *)ciImage ofUserID:(int)UserID
//{
//    if(_numPicsTaken > 10) return;
// 
//    if(feature.hasLeftEyePosition && feature.hasRightEyePosition){
//        UIImageOrientation imageOrient = [[MotionOrientation sharedInstance] currentImageOrientationWithFrontCamera:isUsingFrontFacingCamera MirrorFlip:NO];
//        BOOL isLandScape = [[MotionOrientation sharedInstance] deviceIsLandscape];
//        cv::Mat cvImage = [FaceLib getFaceImage:ciImage feature:feature orient:imageOrient landscape:isLandScape];
//        
//        if(cvImage.data != NULL){
//            NSData *serialized = [FaceLib serializeCvMat:cvImage];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [SQLManager addTrainModelForUserID:UserID withFaceData:serialized];
//                
//                UIImage *faceImage = [FaceLib MatToUIImage:cvImage];
//                if(faceImage) [faceImageView setImage:faceImage];
//
//                if(_numPicsTaken%2 == 0){
//                    NSString *imagePath = [NSString stringWithFormat:@"hive%d.png", (int)_numPicsTaken * 10];
//                    [_hiveImageView setImage:[UIImage imageNamed:imagePath]];
//                }
//
//                self.instructionsLabel.text = [NSString stringWithFormat:@"Taken %@'s face : %ld of 10", self.UserName, (long)self.numPicsTaken];
//                
//                if (self.numPicsTaken == 10) {
//                    [self performSelector:@selector(goNext) withObject:nil afterDelay:2];
//                }
//            });
//            
//            self.numPicsTaken++;
//
//            
//        }
//    }
//}

- (void)showShutterFlash
{
    UIView *flashView = [[UIView alloc] initWithFrame:[[self view] frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];
}

- (void)collectFace:(CIFaceFeature *)feature inImage:(CIImage *)ciImage ofUserID:(int)UserID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_numPicsTaken > TOTAL_COLLECT) return;
        
        double current_time = (double)cv::getTickCount();
        double timeDiff_seconds = (current_time - old_time)/cv::getTickFrequency();
        
        if(feature.hasLeftEyePosition && feature.hasRightEyePosition){
            UIImageOrientation imageOrient = [[MotionOrientation sharedInstance] currentImageOrientationWithFrontCamera:isUsingFrontFacingCamera MirrorFlip:NO];
            BOOL isLandScape = [[MotionOrientation sharedInstance] deviceIsLandscape];
            cv::Mat preprocessedFace = [FaceLib getFaceImage:ciImage feature:feature orient:imageOrient landscape:isLandScape];
            
            if(preprocessedFace.data != NULL){
                
                double imageDiff = 10000000000.0;
                if (old_prepreprocessedFace.data) {
                    imageDiff = [FaceLib getSimilarity:preprocessedFace with:old_prepreprocessedFace];
                }
                
                
                if ((imageDiff > CHANGE_IN_IMAGE_FOR_COLLECTION) && (timeDiff_seconds > CHANGE_IN_SECONDS_FOR_COLLECTION)) {
                    // Also add the mirror image to the training set, so we have more training data, as well as to deal with faces looking to the left or right.
                    
                    [self showShutterFlash];
                    
                    cv::Mat mirroredFace;
                    cv::flip(preprocessedFace, mirroredFace, 1);
                    
                    NSData *serialized = [FaceLib serializeCvMat:preprocessedFace];
                    [SQLManager addTrainModelForUserID:UserID withFaceData:serialized];
                    
                    serialized = [FaceLib serializeCvMat:mirroredFace];
                    [SQLManager addTrainModelForUserID:UserID withFaceData:serialized];
                    
                    if(GlobalValue.testMode){
                        UIImage *faceImage = [FaceLib MatToUIImage:preprocessedFace];
                        if(faceImage) [faceImageView setImage:faceImage];
                    }
                    
                    if(_numPicsTaken%2 == 0){
//                        NSString *imagePath = [NSString stringWithFormat:@"hive%d.png", (int)_numPicsTaken * TOTAL_COLLECT];
//                        [_hiveImageView setImage:[UIImage imageNamed:imagePath]];
                        
                        [_mixedIndicator updateWithTotalBytes:100 downloadedBytes:(int)_numPicsTaken * TOTAL_COLLECT];
                    }
                    
                    self.instructionsLabel.text = [NSString stringWithFormat:@"Taken %d / 10", (int)self.numPicsTaken];
                    
                    //if(ani_step > 9){
                    if (self.numPicsTaken == TOTAL_COLLECT) {
                        
                        CGImageRef cgimage = [FaceLib getFaceCGImage:ciImage bound:feature.bounds];
                        UIImage *profileImage = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:imageOrient];
                        CGImageRelease(cgimage);
                        profileImage = [profileImage fixRotation];
                        
                        //UIImage *profileImage = [UIImage imageWithCIImage:ciImage];
                        [SQLManager setUserProfileImage:profileImage UserID:UserID];
                        
                        //최종 사진을 Blur 처리해서 이미지 저장.
                        cgimage = [FaceLib getFaceCGImage:ciImage bound:ciImage.extent];
                        profileImage = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:imageOrient];
                        CGImageRelease(cgimage);
                        profileImage = [profileImage fixRotation];

                        [[SDImageCache sharedImageCache] storeImage:profileImage forKey:@"LastImage" toDisk:YES];
                        //UIImage *lastImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"LastImage"];
                        
                        //if(UserID > 1) // 처음 사용자 아니면
                        //    [self performSelector:@selector(goAlbum) withObject:nil afterDelay:2];
                        //else
                            [self performSelector:@selector(goNext) withObject:nil afterDelay:2];
                    }
                    
                    // Keep a copy of the processed face, to compare on next iteration.
                    old_prepreprocessedFace = preprocessedFace;
                    old_time = current_time;
                    
                    self.numPicsTaken++;
                    
                    if(!aniTimer.isValid)[aniTimer resume];
                }
            }
        }
    });
    

}




- (void)identifyFace:(CIFaceFeature *)feature inImage:(CIImage *)ciImage
{
    if (!recognisedFaces[@(feature.trackingID)]) {
        if (!processing[@(feature.trackingID)]) {
            processing[@(feature.trackingID)] = @"1";
            
            if(feature.hasLeftEyePosition && feature.hasRightEyePosition){
                
                UIImageOrientation imageOrient = [[MotionOrientation sharedInstance] currentImageOrientationWithFrontCamera:isUsingFrontFacingCamera MirrorFlip:NO];
                BOOL isLandScape = [[MotionOrientation sharedInstance] deviceIsLandscape];
                cv::Mat cvImage = [FaceLib getFaceImage:ciImage feature:feature orient:imageOrient landscape:isLandScape];
                
                if(cvImage.data != NULL){
                    [self parseFace:cvImage
                              forId:feature.trackingID];
                    
                }

            }
        }
    }
}

- (NSString *)getPrefix:(NSString*)str divider:(NSString*)div
{
    NSRange range = [str rangeOfString:div];
    NSInteger start = 0;
    NSInteger size = range.location ;
    NSRange searchRange = NSMakeRange(start,size);
    NSString *string = [str substringWithRange:searchRange];
    return string;
}

- (NSString *)getSuffix:(NSString*)str divider:(NSString*)div
{
    NSRange range = [str rangeOfString:div];
    NSInteger start = range.location + 1;
    NSInteger size = [str length] - start;
    NSRange searchRange = NSMakeRange(start,size);
    NSString *string = [str substringWithRange:searchRange];
    return string;
}



- (void)parseFace:(cv::Mat &)image forId:(int)trackingID
{
    
    NSDictionary *match =[FaceLib recognizeFace:image];

//    int pValue = 80;
//    int mValue = -80;
//    cv::Mat brightImage = image + cv::Scalar(pValue, pValue, pValue);
//    cv::Mat darkImage = image + cv::Scalar(mValue, mValue, mValue);
//    
//    NSDictionary *match1 = [FaceLib recognizeFace:brightImage];
//    NSDictionary *match2 = [FaceLib recognizeFace:darkImage];
//
//    for(int i = 0; i < 3; i++){
//        match = ([match[@"confidence"] doubleValue] < [match1[@"confidence"] doubleValue])?match : match1 ;
//        match = ([match[@"confidence"] doubleValue] < [match2[@"confidence"] doubleValue])?match : match2 ;
//    }
    
    if(IsEmpty(match)) return;
    
    BOOL isFindFace = NO;
    int UserID = [match[@"UserID"] intValue];
    
    if(GlobalValue.testMode){
        UIImage *reconstruct = match[@"reconstruct"];
        
        UIImage *faceImage = [FaceLib MatToUIImage:image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(!IsEmpty(faceImage)) [faceImageView setImage:faceImage];
            if(!IsEmpty(reconstruct)) [reconstImageView setImage:reconstruct];
            
        });
        
        NSLog(@"trackingID : %d / match: %@", trackingID, match);

    }
    
    // Match found
    if (UserID != -1)
    {
        PBFaceRecognizer currentRecognizerType = (PBFaceRecognizer)[match[@"currentRecognizerType"] intValue];
        double confidence = [match[@"confidence"] doubleValue];
    
        NSString *dbUserName = [SQLManager getUserName:UserID];
        //NSString *score;
        NSString *name;
        
        if(currentRecognizerType == LBPHFaceRecognizer)
        {
           
            if(confidence < 50.f){ // For LBPH
//                if(GlobalValue.testMode)
                    name = [NSString stringWithFormat:@"%@:%.2f", dbUserName, confidence];
//                else
//                    name = [NSString stringWithFormat:@"%@ ", tmpUserName];
                isFindFace = YES;
            }
            //else if(confidence > 50.f && confidence < 60.f){ // For LBPH
            else if(confidence > 50.f && confidence < 80.f){ // For LBPH
//                if(GlobalValue.testMode)
                    name = [NSString stringWithFormat:@"? %@:%.2f", dbUserName, confidence];
//                else
//                    name = [NSString stringWithFormat:@"? %@ ", tmpUserName];
                isFindFace = YES;
            }
            else {
//                if(GlobalValue.testMode)
                    name = [NSString stringWithFormat:@"Unknown[%d:%.2f]", UserID, confidence];
//                else
//                    name = [NSString stringWithFormat:@"Unknown"];
                isFindFace = NO;
            }
            
            
        }
        else if(currentRecognizerType == EigenFaceRecognizer || currentRecognizerType == FisherFaceRecognizer)
        {
            //NSString *name;
            if(confidence >= 0.8f){ // For EigenFace
//                if(GlobalValue.testMode)
                    name = [NSString stringWithFormat:@"%@:%.2f", dbUserName, confidence];
//                else
//                    name = [NSString stringWithFormat:@"%@ ", tmpUserName];
                
                isFindFace = YES;
            }
            else if(confidence > 0.7f && confidence < 0.8f){ // For EigenFace
//                if(GlobalValue.testMode)
                    name = [NSString stringWithFormat:@"? %@:%.2f", dbUserName, confidence];
//                else
//                    name = [NSString stringWithFormat:@"? %@ ", tmpUserName];
                
                isFindFace = YES;
            }
            else {
//                if(GlobalValue.testMode)
                    name = [NSString stringWithFormat:@"Unknown[%d:%.2f]", UserID, confidence];
//                else
//                    name = [NSString stringWithFormat:@"Unknown"];
                isFindFace = NO;
            }
            //recognisedFaces[@(trackingID)] = name;
        }
        
        recognisedFaces[@(trackingID)] = name;
        NSLog(@"BEFORE :: recognisedFaces = %@",recognisedFaces);
        
        NSArray *allkeys = recognisedFaces.allKeys;
        if(allkeys.count > 1){
            for(NSNumber *key in allkeys)
            {
                //rint cTrackingID = [key intValue];
                NSString *value = recognisedFaces[key];
                
                
                //if(cTrackingID == trackingID) continue;
                
                
                if(([value rangeOfString:dbUserName].location != NSNotFound) ||
                   ([value rangeOfString:[NSString stringWithFormat:@"? %@",dbUserName]].location != NSNotFound))
                    //if([value hasPrefix:tmpUserName] || [value hasPrefix:[NSString stringWithFormat:@"? %@",tmpUserName]])
                {
                    //NSString *vName = [self getPrefix:value divider:@":"];
                    double vConfidence = [[self getSuffix:value divider:@":"] doubleValue];
                    if(confidence > vConfidence){
                        recognisedFaces[@(trackingID)] = @"Unknown";
                    }
                    else {
                        recognisedFaces[key] = @"Unknown";
                    }
                    
                    isFindFace = NO;
                    break;
                }
            }
        }

        
        
        NSLog(@"AFTER :: recognisedFaces = %@",recognisedFaces);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(isFindFace)
                //[self addNewFaceIcon:UserID];
                [self addNewFaceButton:UserID];
            
        });
    }

    //if([processing[@(trackingID)] intValue] > 2);
    //[processing removeObjectForKey:[NSNumber numberWithInt:trackingID]];
}

//this comes from http://code.opencv.org/svn/gsoc2012/ios/trunk/HelloWorld_iOS/HelloWorld_iOS/VideoCameraController.m
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
    // Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
}

- (UIButton *)tagButtonWithTag:(NSString *)tag point:(CGPoint)position
{
    UIFont *_font = [UIFont systemFontOfSize:14.0f];
    UIColor *_tagBackgroundColor = [UIColor greenColor];
    UIColor *_tagForegroundColor = [UIColor purpleColor];
    float backgroundAlpha = 1.0f;

//    NSString *searchChar = @"?";
//    NSRange rang =[tag rangeOfString:searchChar options:NSCaseInsensitiveSearch];
//
//    if (rang.length == [searchChar length]) {
//        _tagBackgroundColor = [UIColor darkGrayColor];
//        _tagForegroundColor = [UIColor whiteColor];
//        backgroundAlpha = 0.5f;
//    }
    
    if ([tag hasPrefix:@"?"] && [tag length] > 1) {
        tag = [tag substringFromIndex:1];
        
        _tagBackgroundColor = [UIColor darkGrayColor];
        _tagForegroundColor = [UIColor whiteColor];
        backgroundAlpha = 0.7f;

    }

    else if([tag isEqualToString:@"Unknown"] || [tag hasPrefix:@"Unknown"]) {
        _tagBackgroundColor = [UIColor darkGrayColor];
        _tagForegroundColor = [UIColor whiteColor];
        backgroundAlpha = 0.5f;

    }
    
    UIButton *tagBtn = [[UIButton alloc] init];
    [tagBtn.titleLabel setFont:_font];
    [tagBtn setBackgroundColor:_tagBackgroundColor];
    [tagBtn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
//    [tagBtn addTarget:self action:@selector(tagButtonDidPushed:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateNormal];
    
    CGRect btnFrame = tagBtn.frame;
    btnFrame.origin.x = position.x;
    btnFrame.origin.y = position.y;
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_font}].width + (tagBtn.layer.cornerRadius * 2.0f) + 20.0f;
    btnFrame.size.height = 20;
    tagBtn.layer.cornerRadius = btnFrame.size.height * 0.5f;
    tagBtn.frame = CGRectIntegral(btnFrame);
    
    tagBtn.alpha = backgroundAlpha;
    //NSLog(@"btn frame [%@] = %@", tag, NSStringFromCGRect(tagBtn.frame));
    
    return tagBtn;
}



- (void)showFaceRect:(CGRect)rect withName:(NSString *)name
{
    UIButton *nameButton = [self tagButtonWithTag:name point:rect.origin];
    [faceView addSubview:nameButton];
    nameButton.transform  = CGAffineTransformMakeRotation(currentAngle);
}

@end
