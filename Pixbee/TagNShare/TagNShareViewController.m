//
//  TagNShareViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "TagNShareViewController.h"
#import "UIImage+Addon.h"

@interface TagNShareViewController () <UIScrollViewDelegate, UITextViewDelegate>
{

    UIView *selectedView;   // 필터 스크롤뷰안에서 이동하는 선택되어진 뷰.
    UIImage *originalImage; // 원본 이미지
    
    UIImageView *currentImageView; // 스크롤뷰 중에 현재 보여진 이미지뷰
    int currentPage; // UIPageControl의 현재 페이지
}

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView; // 이미지 스크롤뷰
@property (weak, nonatomic) IBOutlet UIPageControl *imagePageControl; // 이미지 페이지 컨트롤

@property (nonatomic, assign) NSInteger numberOfPages; // 전체 페이지 = 원본 이미지 개수

@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *instagramButton;
@property (strong, nonatomic) IBOutlet UIButton *mailButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;

- (IBAction)facebookClickHandler:(id)sender;
- (IBAction)twitterClickHandler:(id)sender;
- (IBAction)instagramClickHandler:(id)sender;
- (IBAction)mailClickHandler:(id)sender;
- (IBAction)messageClickHandler:(id)sender;
- (IBAction)shareClickHandler:(id)sender;

@end

@implementation TagNShareViewController


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

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:SEGUE_GO_FILTER]) {
////        segue.destinationViewController
////        
////        AddingFaceToAlbumController *destination = segue.destinationViewController;
////        destination.UserName = self.UserName;
////        destination.UserID = self.UserID;
//        
//    }
//}

- (IBAction)facebookClickHandler:(id)sender {
    [self.facebookButton setSelected:YES];
    [self.twitterButton setSelected:NO];
    [self.instagramButton setSelected:NO];
    [self.mailButton setSelected:NO];
    [self.messageButton setSelected:NO];
}

- (IBAction)twitterClickHandler:(id)sender {
    [self.facebookButton setSelected:NO];
    [self.twitterButton setSelected:YES];
    [self.instagramButton setSelected:NO];
    [self.mailButton setSelected:NO];
    [self.messageButton setSelected:NO];
}

- (IBAction)instagramClickHandler:(id)sender {
    [self.facebookButton setSelected:NO];
    [self.twitterButton setSelected:NO];
    [self.instagramButton setSelected:YES];
    [self.mailButton setSelected:NO];
    [self.messageButton setSelected:NO];
}

- (IBAction)mailClickHandler:(id)sender {
    [self.facebookButton setSelected:NO];
    [self.twitterButton setSelected:NO];
    [self.instagramButton setSelected:NO];
    [self.mailButton setSelected:YES];
    [self.messageButton setSelected:NO];
}

- (IBAction)messageClickHandler:(id)sender {
    [self.facebookButton setSelected:NO];
    [self.twitterButton setSelected:NO];
    [self.instagramButton setSelected:NO];
    [self.mailButton setSelected:NO];
    [self.messageButton setSelected:YES];
}

- (IBAction)shareClickHandler:(id)sender {
    [self.textView resignFirstResponder];
    
//    if ([self.textView.text length] == 0) {
//        return;
//    }
    
    if (self.facebookButton.selected) {
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
            // if we don't already have the permission, then we request it now
            [FBSession.activeSession requestNewPublishPermissions:@[@"publish_stream"]
                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                completionHandler:^(FBSession *session, NSError *error) {
                                                    if (!error) {
                                                        [self facebookPosting];
                                                    } else if (error.fberrorCategory != FBErrorCategoryUserCancelled){
                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                            message:@"Unable to get permission to post"
                                                                                                           delegate:nil
                                                                                                  cancelButtonTitle:@"OK"
                                                                                                  otherButtonTitles:nil];
                                                        [alertView show];
                                                    }
                                                }];
        } else {
            [self facebookPosting];
        }

    }
    else if (self.twitterButton.selected) {
        
    }
    else if (self.instagramButton.selected) {
        
    }
    else if (self.mailButton.selected) {
        
    }
    else if (self.messageButton.selected) {
        
    }
}

- (void)facebookPosting{
    
    for (int i=0; i<[self.images count]; i++) {
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       UIImageJPEGRepresentation([self.images objectAtIndex:i], 0.7), @"source",
                                       self.textView.text, @"message",
                                       //                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       //                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       //                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Make the request
        [FBRequestConnection startWithGraphPath:@"/me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error) {
                                      // Link posted successfully to Facebook
                                      NSLog([NSString stringWithFormat:@"result: %@", result]);
                                  } else {
                                      // An error occurred, we need to handle the error
                                      // See: https://developers.facebook.com/docs/ios/errors
                                      NSLog([NSString stringWithFormat:@"%@", error.description]);
                                  }
                              }];
    }
}


#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.topLabel.alpha = 0;
    self.bottomLabel.alpha = 0;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // 화면을 내린다.
    if ([textView.text length] == 0) {
        self.topLabel.alpha = 1;
        self.bottomLabel.alpha = 1;
    }
}
//
//- (void)textViewDidChange:(UITextView *)textView {
//    
//}
//
//- (void)textViewDidChangeSelection:(UITextView *)textView {
//    
//}

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


@end
