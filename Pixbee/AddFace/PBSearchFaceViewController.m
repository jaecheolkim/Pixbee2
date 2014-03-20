//
//  PBSearchFaceViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 2/24/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBSearchFaceViewController.h"
#import "iCarousel.h"
#import "SDImageCache.h"
#import "TWRProgressView.h"
#import "FXBlurView.h"
#import "UIImageView+UIImageView_FaceAwareFill.h"
#import "UIImage+FX.h"
#import "UIImage+Addon.h"

@interface PBSearchFaceViewController () <PBAssetsLibraryDelegate, iCarouselDataSource, iCarouselDelegate>

{
    int oldMatchV;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *searchingImageView;
@property (weak, nonatomic) IBOutlet TWRProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UILabel *guideBanner;

// iCarousel for faceCarousel
@property (weak, nonatomic) NSMutableArray *assets;

@property (weak, nonatomic) IBOutlet iCarousel *faceCarousel;
@property (weak, nonatomic) IBOutlet UILabel *faceCountLabel;
//@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, strong) id currentObject;
@property (nonatomic, assign) NSInteger *currentIndex;

- (IBAction)skipButtonHandler:(id)sender;
- (IBAction)addButtonHandler:(id)sender;

@end



@implementation PBSearchFaceViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
//        self.items = [NSMutableArray array];
//        for (int i = 0; i < 100; i++)
//        {
//            [_items addObject:@(i)];
//        }
        
    }
    return self;
}

- (void)dealloc
{
    
    _faceCarousel.delegate = nil;
    _faceCarousel.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.assets = [NSMutableArray array];
    
    self.guideBanner.hidden = YES;
    self.addButton.hidden = YES;
    
    // 제일 마지막에 저장된 사진의 Blur Image를 백그라운드 깔아 준다.
    UIImage *lastImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"LastImage"];
    [_backgroundImageView setImage:lastImage];

    // SwapImageView drop Shadow
    _searchingImageView.contentMode = UIViewContentModeScaleAspectFit;
    _searchingImageView.layer.shadowPath =
    [UIBezierPath bezierPathWithRect:_searchingImageView.layer.bounds].CGPath;
    
    
    [self initProgressView];
    
    [self initFaceCarousel];

    _faceCarousel.alpha = 0.0;
    //_faceCountLabel.alpha = 0.0;

    
    // Do any additional setup after loading the view.
    [self resetFontShape:_guideBanner];
    [self resetFontShape:_descriptionLabel];
    [self resetFontShape:_faceCountLabel];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AssetLib.faceProcessStop = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initNotification];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AssetCheckFacesEnumerationEventHandler:)
//												 name:@"AssetCheckFacesEnumerationEvent" object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AssetCheckFacesFinishedEventHandler:)
//												 name:@"AssetCheckFacesFinishedEvent" object:nil];
    
    [AssetLib checkFace:self.UserID];
    
//    //모든 Asset뒤져서 얼굴 검출하고 DB에 저장.
//    AssetLib.delegate = self;
//    AssetLib.faceProcessStop = NO;
//    
//    [AssetLib checkFacesFor:self.UserID
//      usingEnumerationBlock:^(NSDictionary *processInfo) {
//          dispatch_async(dispatch_get_main_queue(), ^{
//              NSLog(@"Processing : %@", processInfo);
//              
//              int totalV = [[processInfo objectForKey:@"totalV"] intValue];
//              int currentV = [[processInfo objectForKey:@"currentV"] intValue];
//              int matchV = [[processInfo objectForKey:@"matchV"] intValue];
//
//              NSLog(@"currentV = %d / totalV = %d / matchV = %d", currentV, totalV, matchV);
//              
//              [self.progressView setProgress:((float)currentV/(float)totalV)];// animated:YES];
//              [self.faceCountLabel setText:[NSString stringWithFormat:@"%d", matchV]];
//              
//              id faceImage = [processInfo objectForKey:@"faceImage"];
//              if(!IsEmpty(faceImage) && [faceImage isKindOfClass:[UIImage class]])
//              {
//                  [self chageFace:faceImage];
//              }
//          });
//          
//      }
//      completion:^(BOOL finished){
//          dispatch_async(dispatch_get_main_queue(), ^{
//              
//              self.assets = AssetLib.faceAssets;
//              
//              [self.faceCarousel reloadData];
//              
//              
//              [UIView animateWithDuration:0.4
//                               animations:^{
//                                   _searchingImageView.alpha = 0.0;
//                                   _progressView.alpha = 0.0;
//                                   
//                                   _faceCarousel.alpha = 1.0;
//                                   //_faceCountLabel.alpha = 1.0;
//                                   
//                               }
//                               completion:^(BOOL finished) {
//                                   self.skipButton.hidden = YES;
//                                   self.addButton.hidden = NO;
//                               }];
//
//          });
//          
//      }
//     ];
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self deleteNotification];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AssetCheckFacesEnumerationEvent" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AssetCheckFacesFinishedEvent" object:nil];
    
    //free up memory by releasing subviews
    self.faceCarousel = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AssetCheckFacesEnumerationEventHandler:)
												 name:@"AssetCheckFacesEnumerationEvent" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AssetCheckFacesFinishedEventHandler:)
												 name:@"AssetCheckFacesFinishedEvent" object:nil];
}

- (void)deleteNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AssetCheckFacesEnumerationEvent" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AssetCheckFacesFinishedEvent" object:nil];
}

#pragma mark - For UI

- (void)AssetCheckFacesEnumerationEventHandler:(NSNotification *)notification
{
    NSDictionary *processInfo = [notification userInfo];
    
    NSLog(@"Processing : %@", processInfo);
    
    int totalV = [[processInfo objectForKey:@"totalV"] intValue];
    int currentV = [[processInfo objectForKey:@"currentV"] intValue];
    int matchV = [[processInfo objectForKey:@"matchV"] intValue];
    
    NSLog(@"currentV = %d / totalV = %d / matchV = %d", currentV, totalV, matchV);
    
//    [self.progressView setProgress:((float)currentV/(float)totalV)];// animated:YES];
//    [self.faceCountLabel setText:[NSString stringWithFormat:@"%d", matchV]];
//    
//    id faceImage = [processInfo objectForKey:@"faceImage"];
//    if(!IsEmpty(faceImage) && [faceImage isKindOfClass:[UIImage class]])
//    {
//        [self chageFace:faceImage];
//    }
    
    
    [self.progressView setProgress:((float)currentV/(float)totalV)];// animated:YES];
    [self.faceCountLabel setText:[NSString stringWithFormat:@"%d", matchV]];

    
    id faceImage = [processInfo objectForKey:@"faceImage"];
    if(!IsEmpty(faceImage) && [faceImage isKindOfClass:[UIImage class]])
    {
        [self chageFace:faceImage];
    }
    
    if(matchV == 2) {
        self.assets = AssetLib.faceAssets;
        
        [self.faceCarousel reloadData];
        
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _searchingImageView.frame = CGRectMake(135, 56, 50, 50);
                             _faceCarousel.alpha = 1.0;
                             self.guideBanner.hidden = NO;
                         }
                         completion:^(BOOL finished){
                             self.skipButton.hidden = YES;
                             self.addButton.hidden = NO;
                         }];
        
        


        oldMatchV = matchV;
        
//        [UIView animateWithDuration:0.1
//                         animations:^{
//                             _searchingImageView.alpha = 0.0;
//                             _progressView.alpha = 0.0;
//                             
//                             _faceCarousel.alpha = 1.0;
//                             //_faceCountLabel.alpha = 1.0;
//                             
//                         }
//                         completion:^(BOOL finished) {
//                             self.skipButton.hidden = YES;
//                             self.addButton.hidden = NO;
//                         }];

    }
    else if(matchV > 2) {

        if(matchV > oldMatchV){
            //NSUInteger index = [self.assets count];
            //id lastObject = [AssetLib.faceAssets lastObject];
            //[self.assets addObject:lastObject];
            
            [_faceCarousel reloadData];
            
            //[self.assets insertObject:lastObject atIndex:index];
            //[_faceCarousel insertItemAtIndex:index animated:YES];
            
            [self refreshFaceCount];
            oldMatchV = matchV;
        }

    }
//    else {
//        
//        id faceImage = [processInfo objectForKey:@"faceImage"];
//        if(!IsEmpty(faceImage) && [faceImage isKindOfClass:[UIImage class]])
//        {
//            [self chageFace:faceImage];
//        }
//    }

    
}

- (void)AssetCheckFacesFinishedEventHandler:(NSNotification *)notification
{

    self.assets = AssetLib.faceAssets;
    
    [self.faceCarousel reloadData];
    
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         _searchingImageView.alpha = 0.0;
                         _progressView.alpha = 0.0;
                         
                         _faceCarousel.alpha = 1.0;
                         //_faceCountLabel.alpha = 1.0;
                         
                         _descriptionLabel.text = @"Photo Found";
                     }
                     completion:^(BOOL finished) {
                         self.skipButton.hidden = YES;
                         self.addButton.hidden = NO;
                     }];

}

- (void)refreshFaceCount
{
    NSInteger count = [self.assets count];
    [self.faceCountLabel setText:[NSString stringWithFormat:@"%d", (int)count]];
}

- (void)resetFontShape:(UILabel*)label
{
    [label setTextColor:[UIColor whiteColor]];
    [label setShadowColor:[UIColor grayColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];
    [label setNumberOfLines:1];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];

}


#pragma mark - ProgressView

- (void)initProgressView
{
    //Progress View 설정 ( 추후 마스크 이미지 만들어서 이미지 형태의 프로그래스도 가능함.
    UIImage *lineImage = [UIImage imageWithColor:[UIColor blackColor] size:_progressView.frame.size];
    [_progressView setMaskingImage:lineImage];
    [_progressView setFrontColor:[UIColor whiteColor]];
    _progressView.horizontal = YES;
    [_progressView setProgress:0.0];
}

- (void)updateProgress:(CGFloat)progress {

    progress = MIN(MAX(0, progress), 1);
    [_progressView setProgress:progress];
}

//- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
//    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}




#pragma mark - Swaping face image View
- (void)chageFace:(UIImage*)image
{
    [UIView transitionWithView:_searchingImageView
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _searchingImageView.image = image;
                    }
                    completion:^(BOOL finished) {
                        
                    }];
}

#pragma mark - For FaceCarousel

- (void)initFaceCarousel
{
    //configure carousel
    _faceCarousel.type = iCarouselTypeCoverFlow2;
    _faceCarousel.delegate = self;
    
    //add pan gesture recogniser
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    panGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:panGesture];
}

- (void)copyItem:(CGPoint)currentlocation
{
    
    _currentIndex = _faceCarousel.currentItemIndex;
    
    NSData *tempArchiveView = [NSKeyedArchiver archivedDataWithRootObject:_faceCarousel.currentItemView];
    UIView *view = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchiveView];
    
    [self setCurrentView:view];
    [self.view addSubview:_currentView];
    _currentView.center = currentlocation;
    NSLog(@"copyItem = %@", NSStringFromCGPoint(_currentView.center));
}

- (void)moveItem:(CGPoint)currentlocation
{
    if(_currentView){
        _currentView.center = currentlocation;
        NSLog(@"moveItem = %@", NSStringFromCGPoint(_currentView.center));
    }
}

- (void)insertItem
{
    if(!IsEmpty(_currentObject)){
        NSInteger index =  MAX(0, (int)_currentIndex);//self.carousel.currentItemIndex);
        //[self.items insertObject:@(self.carousel.numberOfItems) atIndex:index];
        [self.assets insertObject:_currentObject atIndex:index];
        [_faceCarousel insertItemAtIndex:index animated:YES];
        _currentObject = nil;
        [self refreshFaceCount];
    }

}


- (void)removeItem
{
    if (_faceCarousel.numberOfItems > 0)
    {
        if(!IsEmpty(self.assets)){
            NSInteger index = _faceCarousel.currentItemIndex;
            
            NSDictionary *PhotoInfo = [self.assets objectAtIndex:index];
            int userID = [PhotoInfo[@"UserID"] intValue];
            int photoID = [PhotoInfo[@"PhotoID"] intValue];
            [SQLManager deleteUserPhoto:userID  withPhoto:photoID];
            
            _currentObject = [self.assets objectAtIndex:index];
            [self.assets removeObjectAtIndex:index];
            [_faceCarousel removeItemAtIndex:index animated:YES];
            [self refreshFaceCount];
        }
        

    }
}

- (void)didPan:(UIPanGestureRecognizer *)panGesture
{
    CGPoint currentlocation = [panGesture locationInView:self.view];
    
    
        
    if (YES) //_scrollEnabled)
    {
        switch (panGesture.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                if(!CGRectContainsPoint (_faceCarousel.frame, currentlocation)) return;
                
                [self copyItem:currentlocation];
                [self removeItem];
                
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                [self moveItem:currentlocation];
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                
                if(!CGRectContainsPoint (_faceCarousel.frame, currentlocation)){
                    NSLog(@"---------------Drag End Outside");
                }
                else {
                    NSLog(@"---------------Drag End Inside");
                    [self insertItem];
                }
                
                NSLog(@"UIGestureRecognizerStateEnded | Index = %d / point = %@", (int)_faceCarousel.currentItemIndex, NSStringFromCGPoint(CGPointMake([panGesture translationInView:self.view].x, [panGesture translationInView:self.view].y)));
                
                [_currentView removeFromSuperview];
                _currentView = nil;
                break;
            }
            default:
            {
                
            }
        }
    }
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [self.assets count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160.0f, 160.0f)];
        //((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        
        view.backgroundColor = [UIColor lightGrayColor];
//        label = [[UILabel alloc] initWithFrame:view.bounds];
//        label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [label.font fontWithSize:50];
//        label.tag = 1;
//        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        //label = (UILabel *)[view viewWithTag:1];
        
        
    }
    
    ALAsset *photoAsset = [self.assets objectAtIndex:index][@"Asset"];
    NSString *rectString = [self.assets objectAtIndex:index][@"faceBound"];
    CGRect faceRect = CGRectFromString(rectString);
    
    CGImageRef iref = [photoAsset aspectRatioThumbnail];
    CIImage *ciImage = [CIImage imageWithCGImage:iref];

    CIContext* ctx = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [ctx createCGImage:ciImage fromRect:faceRect];
	UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
    
//
//    CGImageRef img = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:faceRect];
//    UIImage *faceImage = [UIImage imageWithCGImage:img];
//    if(img) CGImageRelease(img);
    
    //UIImage *thumbnail = [UIImage imageWithCGImage:iref];
    //thumbnail = [thumbnail imageCroppedToRect:faceRect];
    
    view.contentMode = UIViewContentModeScaleAspectFit;
    
    if (!IsEmpty(thumbnail)) {
        ((UIImageView *)view).image = thumbnail;
        //[(UIImageView *)view faceAwareFill];
    };

    

    //((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
    
    //label.text = [_items[index] stringValue];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.1f;
        }
            //        case iCarouselOptionFadeMax:
            //        {
            //            if (carousel.type == iCarouselTypeCustom)
            //            {
            //                //set opacity based on distance from camera
            //                return 0.0f;
            //            }
            //            return value;
            //        }
            
        case iCarouselOptionFadeMin:
        {
            return -0.2;
        }
            
        case iCarouselOptionFadeMax:
        {
            return 0.2;
        }
            
        case iCarouselOptionFadeRange:
        {
            return 2.0;
        }
            
            
            
        default:
        {
            return value;
        }
    }
}

#pragma mark ButtonHandler
- (IBAction)skipButtonHandler:(id)sender {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"MeunViewControllerEventHandler"
//                                                        object:self
//                                                      userInfo:@{@"moveTo":@"MainDashBoard"}];
    
    [self performSegueWithIdentifier:@"Segue2_2to3_1" sender:self];
    
//    UINavigationController * navigationController = self.navigationController;
//    [navigationController popToRootViewControllerAnimated:NO];
    //[navigationController pushViewController:someOtherViewController animated:YES];
}

- (IBAction)addButtonHandler:(id)sender {
    [self performSegueWithIdentifier:@"Segue2_2to3_1" sender:self];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"MeunViewControllerEventHandler"
//                                                        object:self
//                                                      userInfo:@{@"moveTo":@"MainDashBoard"}];
    
//    UINavigationController * navigationController = self.navigationController;
//    [navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AssetLib.faceProcessStop = YES;
}
@end
