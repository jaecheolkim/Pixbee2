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
#import "FBFriendController.h"

@interface AddingFaceToAlbumController () <PBAssetsLibraryDelegate, SBPageFlowViewDelegate, SBPageFlowViewDataSource, FBFriendControllerDelegate, UITextFieldDelegate>
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
@property (strong, nonatomic) FBFriendController *friendPopup;

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
    
    //KEYBOARD OBSERVERS
    /************************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    /************************/
    
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

    self.nameField.text = self.UserName;
    [self.nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //모든 Asset뒤져서 얼굴 검출하고 DB에 저장.
    AssetLib.delegate = self;
    AssetLib.faceProcessStop = NO;

    [AssetLib checkFacesFor:self.UserID
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
              int matchV = [[processInfo objectForKey:@"Match"] intValue];
              [self.progressView setProgress:((float)currentV/(float)totalV) animated:YES];
              [self.ProgressGauge setText:[NSString stringWithFormat:@"%d", matchV]];
              
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
    [self performSegueWithIdentifier:SEGUE_2_2_TO_1_4 sender:self];
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


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.friendPopup == nil) {
        [self popover:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.friendPopup disAppearPopup];
    self.friendPopup = nil;
}

-(void)textFieldDidChange:(id)sender {
    // whatever you wanted to do
    [self.friendPopup handleSearchForTerm:self.nameField.text];
}

#pragma mark FBFriendControllerDelegate

- (void)selectedFBFriend:(NSDictionary *)friendinfo {
    self.nameField.text = [friendinfo objectForKey:@"name"];
    // DB에 저장하는 부분 추가
    [self.nameField resignFirstResponder];
}


-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
    CGRect keyboardRect = [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    int keyboardHeight = keyboardRect.size.height;
    float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect rect = self.view.frame;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.view setFrame:CGRectMake(rect.origin.x, -keyboardHeight, rect.size.width, rect.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)keyboardWillHide:(NSNotification*)notification {
    int keyboardHeight = 0.0;
    NSDictionary *info = notification.userInfo;
    float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect rect = self.view.frame;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.view setFrame:CGRectMake(rect.origin.x, keyboardHeight, rect.size.width, rect.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)popover:(id)sender
{
    FBFriendController *controller = (FBFriendController *)[self.storyboard instantiateViewControllerWithIdentifier:@"FBFriendController"];
    
    controller.delegate = self;
    CGPoint convertedPoint = CGPointMake(15, 473);
    [controller appearPopup:convertedPoint reverse:NO];
    
    self.friendPopup = controller;
}

@end

