//
//  AddingFaceToAlbumController.m
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "AddingFaceToAlbumController.h"
#import "DACircularProgressView.h"
#import "SBPageFlowView.h"
#import "SwapImageView.h"
#import "PBFaceLib.h"
#import "UIView+Hexagon.h"

@interface AddingFaceToAlbumController () <PBAssetsLibraryDelegate, SBPageFlowViewDelegate, SBPageFlowViewDataSource>
{
    // 만약 현재 얼굴 검출중인데 멈추고 싶으면 isActive를 No로 해주면 됨..
    BOOL isActive;
    
    // 보여지는 이미지의 인덱스
    NSInteger    _currentPage;
}
@property (strong, nonatomic) IBOutlet SBPageFlowView *flowView;
@property (strong, nonatomic) IBOutlet SwapImageView *photoView;
@property (strong, nonatomic) IBOutlet DACircularProgressView *progressView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UILabel *ProgressGauge;

@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@property (strong, nonatomic) NSMutableArray *assets;

- (IBAction)skipButtonClickHandler:(id)sender;
- (IBAction)addButtonClickHandler:(id)sender;
- (IBAction)rightButtonClickHandler:(id)sender;
- (IBAction)leftButtonClickHandler:(id)sender;

@end

@implementation AddingFaceToAlbumController

@synthesize progressView = _progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment to display a logo as the navigation bar title
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pixbee.png"]];

	// Do any additional setup after loading the view.
    isActive = YES;
    
    self.assets = [NSMutableArray array];
    
    self.progressView.roundedCorners = NO;
    self.progressView.progressTintColor = UIColorFromRGB(0xffcf0e);
    self.progressView.thicknessRatio = 1.0f;
    [self.progressView configureLayerForHexagon];
    
    [self.ProgressGauge setText:@"0"];
    
    [self.flowView initialize];
    self.flowView.alpha = 0.0;
    self.flowView.delegate = self;
    self.flowView.dataSource = self;
    self.flowView.minimumPageAlpha = 0.5;
    self.flowView.minimumPageScale = 0.5;

    
    //모든 Asset뒤져서 얼굴 검출하고 DB에 저장.
    AssetLib.delegate = self;
    AssetLib.faceProcessStop = NO;
    int UserID = [SQLManager getUserID:GlobalValue.userName];
    [AssetLib checkFacesFor:UserID
      usingEnumerationBlock:^(NSDictionary *processInfo) {
          dispatch_async(dispatch_get_main_queue(), ^{
              NSLog(@"Processing : %@", processInfo);
              
              [self.assets addObject:[processInfo objectForKey:@"Asset"]];
              
              CGImageRef iref = [[self.assets lastObject] aspectRatioThumbnail];
              if (iref) {
                  UIImage *thumbnail = [UIImage imageWithCGImage:iref];
                  if (thumbnail) {
                      [self.photoView swapImage:thumbnail];
                  }
              };
              
              int totalV = [[processInfo objectForKey:@"Total"] intValue];
              int currentV = [[processInfo objectForKey:@"Current"] intValue];
              [self.progressView setProgress:((float)currentV/(float)totalV) animated:YES];
              [self.ProgressGauge setText:[NSString stringWithFormat:@"%d", currentV]];
              
              _faceImageView.image = [processInfo objectForKey:@"Face"];
          });
      }
                 completion:^(BOOL finished){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.flowView reloadData];
                         // Wait one second and then fade in the view
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              self.photoView.alpha = 0.0;
                                              self.flowView.alpha = 1.0;
                                          }
                                          completion:nil];
                     });
                 }
     
     ];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    AssetLib.faceProcessStop = YES;
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AssetLib.faceProcessStop = YES;
}


#pragma mark ButtonAction

- (IBAction)skipButtonClickHandler:(id)sender {
    AssetLib.faceProcessStop = YES;
}

- (IBAction)addButtonClickHandler:(id)sender {
    [self performSegueWithIdentifier:SEGUE_3_TO_3A sender:self];
}

- (IBAction)rightButtonClickHandler:(id)sender {
    [self.flowView scrollToNextPage];
}

- (IBAction)leftButtonClickHandler:(id)sender {
    [self.flowView scrollToPrePage];
}


#pragma mark PBAssetsLibraryDelegate

- (void)progressUpdate:(NSNumber *)percent {
    
}

- (void)updateProgressUI:(NSNumber *)total currentProcess:(NSNumber *)currentprocess {
    int totalV = [total intValue];
    int currentV = [currentprocess intValue];
    
    //    [self performSelectorOnMainThread:@selector(progressUpdate:) withObject:[NSNumber numberWithFloat:] waitUntilDone:NO];
    [self.progressView setProgress:((float)currentV/(float)totalV) animated:YES];
    [self.ProgressGauge setText:[NSString stringWithFormat:@"%d", currentV]];
}

- (void)updatePhotoGallery:(ALAsset *)asset {
    [self.assets addObject:asset];
    CGImageRef iref = [[self.assets lastObject] aspectRatioThumbnail];
    if (iref) {
        UIImage *thumbnail = [UIImage imageWithCGImage:iref];
        if (thumbnail) {
            [self.photoView swapImage:thumbnail];
        }
    };
}

#pragma mark - PagedFlowView Datasource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(SBPageFlowView *)flowView{
    return [self.assets count];
}

- (CGSize)sizeForPageInFlowView:(SBPageFlowView *)flowView;{
    return CGSizeMake(320, 320);
}

//返回给某列使用的 View
- (UIView *)flowView:(SBPageFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    
    if (index < 0 || index >= [self.assets count]) {
        return nil;
    }
    
    UIImageView *imageView = (UIImageView *)[flowView dequeueReusableCell];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.layer.masksToBounds = YES;
    }
    
    CGImageRef iref = [[self.assets objectAtIndex:index] aspectRatioThumbnail];
    if (iref) {
        UIImage *thumbnail = [UIImage imageWithCGImage:iref];
        if (thumbnail) {
            
            
            imageView.contentMode = UIViewContentModeCenter;
            if (imageView.bounds.size.width < thumbnail.size.width ||
                imageView.bounds.size.height < thumbnail.size.height) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }

            
            imageView.image = thumbnail;
        }
    };

    return imageView;
}

#pragma mark - PagedFlowView Delegate
- (void)didReloadData:(UIView *)cell cellForPageAtIndex:(NSInteger)index
{
    UIImageView *imageView = (UIImageView *)cell;
    
    if (index < 0 || index >= [self.assets count]) {
        return;
    }
    
    CGImageRef iref = [[self.assets objectAtIndex:index] aspectRatioThumbnail];
    if (iref) {
        UIImage *thumbnail = [UIImage imageWithCGImage:iref];
        if (thumbnail) {
            
            imageView.contentMode = UIViewContentModeCenter;
            if (imageView.bounds.size.width < thumbnail.size.width ||
                imageView.bounds.size.height < thumbnail.size.height) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }

            imageView.image = thumbnail;
        }
    };
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(SBPageFlowView *)flowView {
    NSLog(@"Scrolled to page # %d", pageNumber);
    _currentPage = pageNumber;
}

- (void)didSelectItemAtIndex:(NSInteger)index inFlowView:(SBPageFlowView *)flowView
{
    NSLog(@"didSelectItemAtIndex: %d", index);
    
    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:[NSString stringWithFormat:@"您当前选择的是第 %d 个图片",index]
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
    [alert show];
    
}


- (CGRect)calImageSize:(CGSize) size{
    
    CGRect rect = self.photoView.frame;
    float w = rect.size.width;
    float h = rect.size.height;
    
    // 세로형 이미지
    if (size.height > size.width) {
        // 가로를 새로 계산
        w = size.width * rect.size.height / size.height;
    }
    // 가로형 이미지
    else if (size.height < size.width) {
        // 세로를 새로 계산
        h = size.height * rect.size.width / size.width;
    }
    // 정사각형 이미지
    else {
        // 똑같으면 세로에 맞게
        w = rect.size.height;
    }
    
    float scale = rect.size.height / h;
    w = w * scale;
    h = h * scale;
    
    return CGRectMake((rect.size.width - w)/2, (rect.size.height - h)/2, w, h);
}

@end


////
////  AddingFaceToAlbumController.m
////  Pixbee
////
////  Created by 호석 이 on 2013. 11. 30..
////  Copyright (c) 2013년 Pixbee. All rights reserved.
////
//
//#import "AddingFaceToAlbumController.h"
//#import "DACircularProgressView.h"
//#import "iCarousel.h"
//
//@interface AddingFaceToAlbumController () <PBAssetsLibraryDelegate, iCarouselDataSource, iCarouselDelegate>
//{
//    int _totalProcess;
//    int _currentProcess;
//    NSMutableDictionary *progress;
//    THObserver *observer;
//}
//@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
//@property (strong, nonatomic) IBOutlet DACircularProgressView *progressView;
//@property (strong, nonatomic) IBOutlet UITextField *nameField;
//@property (strong, nonatomic) IBOutlet UILabel *ProgressGauge;
//@property (strong, nonatomic) IBOutlet UIImageView *faceImageView;
//
//- (IBAction)skipButtonClickHandler:(id)sender;
//- (IBAction)addButtonClickHandler:(id)sender;
//
//@end
//
//@implementation AddingFaceToAlbumController
//
//@synthesize progressView = _progressView;
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//    
////    self.progressView.trackTintColor = [UIColor blackColor];
////    self.progressView.progressTintColor = [UIColor yellowColor];
////    self.progressView.thicknessRatio = 1.0f;
////    
////    progress = [NSMutableDictionary dictionaryWithObject:@"0.0" forKey:@"progressKey"];
////    
////    observer = [THObserver observerForObject:progress
////                                     keyPath:@"progressKey"
////                                      target:self
////                                      action:@selector(progressCallback:keyPath:oldValue:newValue:)];
////
////    
////    
////    //모든 Asset뒤져서 얼굴 검출하고 DB에 저장.
////    //[AssetLib checkFacesNSave];
////    
////    [self checkFaces:AssetLib.totalAssets success:^(NSArray *result) {
////        
////    }];
//    
//    self.progressView.roundedCorners = NO;
//    self.progressView.progressTintColor = [UIColor redColor];
//    
//    [self.ProgressGauge setText:@"0"];
//    
//    //모든 Asset뒤져서 얼굴 검출하고 DB에 저장.
//    AssetLib.delegate = self;
//    [AssetLib checkFacesNSave];
//}
//
////- (void)progressCallback:(id)object keyPath:(NSString *)keyPath oldValue:(id)oldValue newValue:(id)newValue
////{
////    if([keyPath isEqualToString:@"progressKey"]){
////        
////        float pVal = [[object objectForKey:@"progressKey"] floatValue];
////        [self.progressView setProgress:pVal animated:YES];
////
////
////        NSLog(@"===========================");
////        NSLog(@"object : %@", object);
////        NSLog(@"oldValue : %@", oldValue);
////        NSLog(@"newValue : %@", newValue);
////        
////    }
////}
//
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark PBAssetsLibraryDelegate
//
//- (void)progressUpdate:(NSNumber *)percent {
//    
//}
//
//- (void)updateProgressUI:(NSNumber *)total currentProcess:(NSNumber *)currentprocess {
//    int totalV = [total intValue];
//    int currentV = [currentprocess intValue];
//    
//    //    [self performSelectorOnMainThread:@selector(progressUpdate:) withObject:[NSNumber numberWithFloat:] waitUntilDone:NO];
//    [self.progressView setProgress:((float)currentV/(float)totalV) animated:YES];
//    [self.ProgressGauge setText:[NSString stringWithFormat:@"%d", currentV]];
//}
//
//- (void)updatePhotoGallery:(ALAsset *)asset {
//    NSInteger index = MAX(0, self.photoView.currentItemIndex);
//    [self.assets insertObject:asset atIndex:index];
//    [self.photoView insertItemAtIndex:index animated:YES];
//}
//
//
//#pragma mark Check face
//
//- (void)checkFaces:(NSArray *)assets
//           success:(void (^)(NSArray *result))success
//{
//    NSLog(@"Start...");
//    
//    __block CGImageRef cgImage;
//    __block CIImage *ciImage;
//    __block CIDetector *detector;
//    //__block NSMutableArray *totalAssets = [NSMutableArray array];
//    __block NSInteger counter = 0;
//    __block double workTime;
//    _totalProcess = (int)[assets count];
//    _currentProcess = 0;
//    __block int findFaces = 0;
//    
//    
//    CIContext *context = [CIContext contextWithOptions:nil];
//    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyLow };
//    detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
//    
//    NSDate *date0 = [NSDate date];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @autoreleasepool {
//            for(int i = 0; i < (int)[assets count]; i++){
//                
//                NSDate *date = [NSDate date];
//                
//                ALAsset *photoAsset = [assets[i] objectForKey:@"Asset"];
//                
//                cgImage = [photoAsset aspectRatioThumbnail];
//                ciImage = [CIImage imageWithCGImage:cgImage];
//                
//                NSArray *fs = [detector featuresInImage:ciImage options:@{CIDetectorSmile: @(YES),
//                                                                          CIDetectorEyeBlink: @(YES),
//                                                                          }];
//                counter = [fs count];
//                
//                
//                
//                //[facesCount addObject:[NSString stringWithFormat:@"%d", (int)counter]];
//                
//                //                [self addAssetToDBWith:asset[i] withAssetGroup:assetGroup withFaceArray:fs];
//                
//                NSString *AssetURL = [photoAsset valueForProperty:ALAssetPropertyAssetURL];
//                NSString *GroupURL = [assets[i] objectForKey:@"GroupURL"];
//                
//                //[_totalAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":fs}];
//                if(counter)
//                	
//                
//                if(counter){
//                    
//                    [AssetLib.faceAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":fs}];
//                    
//                    for(CIFaceFeature *face in fs){
//                        
//                        // Crop result image to face
//                        //CIFaceFeature *firstFace = [features objectAtIndex:0];
//                        CIImage *result = [ciImage imageByCroppingToRect:face.bounds];
//                        
////                        CGRect pic_bound = ciImage.extent;
////                        CGRect bounds = face.bounds;
////                        
////                        CGPoint leftEyePosition = face.leftEyePosition;
////                        CGPoint rightEyePosition = face.rightEyePosition;
////                        CGPoint mouthPosition = face.mouthPosition;
////                        float faceAngle = face.faceAngle;
////                        
////                        BOOL hasSmile = face.hasSmile;
////                        BOOL leftEyeClosed = face.leftEyeClosed;
////                        BOOL rightEyeClosed = face.rightEyeClosed;
//                        
//                        // Save DB. [Photos] & [Faces]
//                        
//                        findFaces += counter;
//                        UIImage *faceImg = [UIImage imageWithCIImage:result];
//                        if(faceImg) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [_faceImageView setImage:faceImg];
//                                [_ProgressGauge setText:[NSString stringWithFormat:@"%d",findFaces ]];
//                                [_titleLabel setText:[NSString stringWithFormat:@"Face detected: %d || (%d / %d)",findFaces,  _currentProcess, _totalProcess]];
//                            });
//                        }
//
//                        
//                    }
//                }
//                
//                workTime = 0 - [date timeIntervalSinceNow];
//                _currentProcess++;
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                	NSLog(@"time : %f초 || Current = %d / %d Total : %f ", workTime, _currentProcess, _totalProcess, (float)_currentProcess /(float)_totalProcess);
//                    progress[@"progressKey"] = [NSString stringWithFormat:@"%f", (float)_currentProcess /(float)_totalProcess ];
//                });
//            }
//            
//            success(AssetLib.faceAssets);
//            
//            NSLog(@"===> Find : %d, 걸린시간 : %f초 || size = %@",
//                  (int)[AssetLib.faceAssets count], workTime = 0 - [date0 timeIntervalSinceNow], NSStringFromCGRect(ciImage.extent) );
//            
//        }
//    });
//    
//    
//}
//
//
//#pragma mark ButtonAction
//
//- (IBAction)skipButtonClickHandler:(id)sender {
//    
//}
//
//- (IBAction)addButtonClickHandler:(id)sender {
//    [self performSegueWithIdentifier:SEGUE_3_TO_3A sender:self];
//}
//
//
//@end
