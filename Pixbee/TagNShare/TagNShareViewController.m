//
//  TagNShareViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "TagNShareViewController.h"
#import "UIImage+Addon.h"

@interface TagNShareViewController () <UIScrollViewDelegate>
{

    UIView *selectedView;   // 필터 스크롤뷰안에서 이동하는 선택되어진 뷰.
    UIImage *originalImage; // 원본 이미지
    
    UIImageView *currentImageView; // 스크롤뷰 중에 현재 보여진 이미지뷰
    int currentPage; // UIPageControl의 현재 페이지
}

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView; // 이미지 스크롤뷰
@property (weak, nonatomic) IBOutlet UIPageControl *imagePageControl; // 이미지 페이지 컨트롤

@property (nonatomic, assign) NSInteger numberOfPages; // 전체 페이지 = 원본 이미지 개수

- (IBAction)DoneClickedHandler:(id)sender;

@end

@implementation TagNShareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor colorWithRed:0.98 green:0.96 blue:0.92 alpha:1.0]];
    self.navigationController.navigationItem.leftBarButtonItem.title = @"";
    
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

- (void)setUpImages
{
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
    NSLog(@"---scrollViewDidEndDecelerating page : %d", currentPage);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:SEGUE_GO_FILTER]) {
//        segue.destinationViewController
//        
//        AddingFaceToAlbumController *destination = segue.destinationViewController;
//        destination.UserName = self.UserName;
//        destination.UserID = self.UserID;
        
    }
}


- (IBAction)DoneClickedHandler:(id)sender {
    [self performSegueWithIdentifier:SEGUE_GO_FILTER sender:self];
}
@end
