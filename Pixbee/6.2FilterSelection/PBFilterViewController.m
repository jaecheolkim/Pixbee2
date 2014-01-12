//
//  PBFilterViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "PBFilterViewController.h"

@interface PBFilterViewController ()
{
    UIView *selectedView;
    UIImage *originalImage; // 원본 이미지
    UIImage *postImage;     // 필터 처리된 이미지.
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *filters;
@end

@implementation PBFilterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPageControl *pageControl;
    
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
        
        CGFloat scale  = 1;
        originalImage = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                             scale:scale orientation:orientation];
        
        originalImage = [self fixrotation:originalImage] ;
        [_imageView setImage:originalImage];
    }
    
    
    self.navigationController.navigationItem.title = @"Filter";
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.98 green:0.96 blue:0.92 alpha:1.0]];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    //originalImage = [self fixrotation:[[UIImage alloc] initWithData:_imageData]] ;
    [_imageView setImage:originalImage];

    self.filters = @[@"Original",
                   @"CILinearToSRGBToneCurve",
                   @"CIPhotoEffectChrome",
                   @"CIPhotoEffectFade",
                   @"CIPhotoEffectInstant",
                   @"CIBloom",
                   @"CIPhotoEffectMono",
                   @"CIPhotoEffectNoir",
                   @"CIPhotoEffectProcess",
                   @"CIPhotoEffectTonal",
                   @"CIPhotoEffectTransfer",
                   @"CISRGBToneCurveToLinear",
                   ];
    
    [self loadFilterImages];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) loadFilterImages {
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

-(void) filterSelected:(UIButton*)sender {
    for(UIView *view in _scrollView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton *)view setSelected:NO];
            if(view.tag  == sender.tag) [(UIButton *)view setSelected:YES];
        }
        if([view isKindOfClass:[UILabel class]]){
            [(UILabel *)view setTextColor:[UIColor colorWithWhite:0.97f alpha:1.0f]];
            if(view.tag == sender.tag * 100) [(UILabel *)view setTextColor:[UIColor yellowColor]];
        }
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         selectedView.center = CGPointMake(sender.center.x, 108/2);
                     }
                     completion:nil];



    //[sender setSelected:YES];

    NSLog(@"selectedFilter = %d",(int)sender.tag);
    
    // Process Filter
    if ((int)sender.tag == 0) {
        
        [_imageView setImage:originalImage];
        
        return;
    }
    CIImage *ciImage = [CIImage imageWithCGImage:originalImage.CGImage];
    //CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
    
    CIFilter *filter = [CIFilter filterWithName:self.filters[(int)sender.tag]
                                  keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    postImage = [UIImage imageWithCGImage:cgImage];
    
    [_imageView setImage:[UIImage imageWithCGImage:cgImage]];
    
    CGImageRelease(cgImage);

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
@end
