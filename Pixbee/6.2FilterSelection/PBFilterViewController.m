//
//  PBFilterViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "PBFilterViewController.h"
#import "UIImage+Addon.h"
#import "CIFilter+ColorLUT.h"
#import "TagNShareViewController.h"

@interface PBFilterViewController () <UIScrollViewDelegate>
{

    UIView *selectedView;   // 필터 스크롤뷰안에서 이동하는 선택되어진 뷰.
    UIImage *originalImage; // 원본 이미지
    UIImage *postImage;     // 필터 처리된 이미지.
    
    UIImageView *currentImageView; // 스크롤뷰 중에 현재 보여진 이미지뷰
    int currentPage; // UIPageControl의 현재 페이지
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // 필터 스크롤뷰
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView; // 이미지 스크롤뷰
@property (weak, nonatomic) IBOutlet UIPageControl *imagePageControl; // 이미지 페이지 컨트롤
@property (nonatomic, strong) NSArray *filters; // 필터 리스트
@property (nonatomic, strong) NSMutableArray *images; // 원본 이미지들.

@property (nonatomic, assign) NSInteger numberOfPages; // 전체 페이지 = 원본 이미지 개수

- (IBAction)NextClickedHandler:(id)sender;

@end

@implementation PBFilterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationItem.title = @"Filter";
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.98 green:0.96 blue:0.92 alpha:1.0]];

    [self setUpFilters];
    
    [self setUpImages];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setupContentViews];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark return method

#warning TO : 호석과장님 => 필터 처리된 모든 이미지 호출하는 함수.
- (NSMutableArray*)getResultImages
{
    NSMutableArray *results = [NSMutableArray array];
    for(UIImageView *imageView in _imageScrollView.subviews){
        [results addObject:imageView.image];
    }
    return results;
}

#pragma mark -
#pragma mark SETUP UI

- (void)setUpFilters
{
    self.filters = @[@"Original",
                     @"CITemperatureAndTint",
                     @"CIDotScreen",
                     @"CIPhotoEffectChrome",
                     
                     @"CIPhotoEffectFade",
                     @"CIPhotoEffectInstant",
                     @"CIGloom",
                     
                     @"CIPhotoEffectNoir",
                     @"CIPhotoEffectProcess",
                     @"CIPhotoEffectMono",
                     @"CILinearToSRGBToneCurve",
                     @"CIPhotoEffectTonal",
                     @"CIPhotoEffectTransfer",
                     @"CISRGBToneCurveToLinear",
                     ];
    
    _scrollView.backgroundColor = [UIColor blackColor];
    
    selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 108)];
    [selectedView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.7]];
    [_scrollView addSubview:selectedView];
    
    for(int i = 0; i < 6; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"filter%d", i + 1]] forState:UIControlStateNormal];
        button.frame = CGRectMake(10+i*(76+10), 7.0f, 76.0f, 76.0f);
        button.layer.cornerRadius = 7.0f;
        
        //use bezier path instead of maskToBounds on button.layer
        UIBezierPath *bi = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(7.0,7.0)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = button.bounds;
        maskLayer.path = bi.CGPath;
        button.layer.mask = maskLayer;
        
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [button addTarget:self
                   action:@selector(filterSelected:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [button setTitle:@"*" forState:UIControlStateSelected];
        if(i == 0){
            [button setSelected:YES];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10+i*(76+10), 83.0f, 76.0f, 21.0f)];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:12.0f];
		label.textColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.text = @"filter";
        label.tag = i*100;
        if(i == 0){
            label.textColor = [UIColor yellowColor];
        }
        
		[_scrollView addSubview:button];
        [_scrollView addSubview:label];
	}
	[_scrollView setContentSize:CGSizeMake(10 + 6*(76+10), 108.0)];


}

- (void)setUpImages
{
    _images = [NSMutableArray array];
    NSLog(@"photos = %@", _photos);
    
    for(NSDictionary *photo in _photos) {
        ALAsset *asset= [photo objectForKey:@"Asset"];
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        
        // Retrieve the image orientation from the ALAsset
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
//        UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:1.0 orientation:orientation];
//        image = [image fixRotation] ;
        
        //fullResolutionImage 은 이미 로테이션 UIImageOrientationUp 되서 나옴.
        UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage] scale:1.0 orientation:UIImageOrientationUp];
        
        [_images addObject:image];
    }
    
    
    _numberOfPages = _images.count;
    _imagePageControl.numberOfPages = _numberOfPages;
    [_imagePageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupContentViews
{
    _imageScrollView.delegate=self;
    _imageScrollView.contentSize = CGSizeMake( _numberOfPages *  _imageScrollView.frame.size.width, _imageScrollView.frame.size.height) ;
    
    for( int i = 0; i < _numberOfPages; i++ )
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[_images objectAtIndex:i]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake( i * _imageScrollView.frame.size.width , 0, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
        imageView.tag = 0;
        [_imageScrollView addSubview:imageView];
    }
    
    _imagePageControl.currentPage = 0;
    currentPage = (int)_imagePageControl.currentPage;
    currentImageView = [_imageScrollView.subviews objectAtIndex:currentPage];
    originalImage = [_images objectAtIndex:currentPage];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void) pageChangeValue:(id)sender {
    UIPageControl *pControl = (UIPageControl *) sender;
    [_imageScrollView setContentOffset:CGPointMake(pControl.currentPage*_imageScrollView.frame.size.width, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = _imageScrollView.frame.size.width;
    _imagePageControl.currentPage = floor((_imageScrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    currentPage = (int)_imagePageControl.currentPage;
    currentImageView = [_imageScrollView.subviews objectAtIndex:currentPage];
    originalImage = [_images objectAtIndex:currentPage];
    
    [self moveFilter:(int)currentImageView.tag];
    NSLog(@"---scrollViewDidEndDecelerating page : %d", currentPage);
}


#pragma mark -
#pragma mark UI HANDLER

- (void)moveFilter:(int)index
{
    UIButton *selectedButton;
    
    for(UIView *view in _scrollView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton *)view setSelected:NO];
            if(view.tag  == index) {
                selectedButton = (UIButton *)view;
                [selectedButton setSelected:YES];
            }
        }
        if([view isKindOfClass:[UILabel class]]){
            [(UILabel *)view setTextColor:[UIColor colorWithWhite:0.97f alpha:1.0f]];
            if(view.tag == index * 100) [(UILabel *)view setTextColor:[UIColor yellowColor]];
        }
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         selectedView.center = CGPointMake(selectedButton.center.x, 108/2);
                     }
                     completion:nil];
    
}

- (void)applyFilter:(int)index
{
    // Process Filter
    currentImageView.tag = index;
    
    if (index == 0) {
        [currentImageView setImage:originalImage];
        return;
    }
    CIImage *ciImage = [CIImage imageWithCGImage:originalImage.CGImage];
    
//    //    //// add auto enhance
//    NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustRedEye]];
//    
//	for (CIFilter* filter in adjustments)
//	{
//		[filter setValue:ciImage forKey:kCIInputImageKey];
//		ciImage = filter.outputImage;
//	}
//    //    //// add auto enhance
    
    
    CIFilter *filter = [CIFilter filterWithName:self.filters[index]
                                  keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
  
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    postImage = [UIImage imageWithCGImage:cgImage];
    
    [currentImageView setImage:postImage];
    
    CGImageRelease(cgImage);
}


-(void) filterSelected:(UIButton*)sender {
    [self moveFilter:(int)sender.tag];
    [self applyFilter:(int)sender.tag];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:SEGUE_6_2_TO_7_1]) {
        TagNShareViewController *destination = segue.destinationViewController;
        destination.images = [self getResultImages];
    }
}


- (IBAction)NextClickedHandler:(id)sender {
    [self performSegueWithIdentifier:SEGUE_6_2_TO_7_1 sender:self];
}
@end
