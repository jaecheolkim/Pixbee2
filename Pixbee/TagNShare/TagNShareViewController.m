//
//  TagNShareViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "TagNShareViewController.h"
#import "UIImage+Addon.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

@interface TagNShareViewController () <UIScrollViewDelegate, UITextViewDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate>
{

    UIView *selectedView;   // 필터 스크롤뷰안에서 이동하는 선택되어진 뷰.
    UIImage *originalImage; // 원본 이미지
    
    UIImageView *currentImageView; // 스크롤뷰 중에 현재 보여진 이미지뷰
    int currentPage; // UIPageControl의 현재 페이지
}

@property (nonatomic, strong)     UIDocumentInteractionController* docController;
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
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];

    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
   
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler = ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
            //Lets access the first Twitter Account, but in real time you have to provide a list for the User to select
            if ([accounts count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.facebookButton setSelected:NO];
                    [self.twitterButton setSelected:YES];
                    [self.instagramButton setSelected:NO];
                    [self.mailButton setSelected:NO];
                    [self.messageButton setSelected:NO];
                });
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Account" message:@"There are no Twitter Accounts present on the device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Account" message:@"There are no Twitter Accounts present on the device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    };
    
    [accountStore requestAccessToAccountsWithType:twitterType
                                          options:NULL
                                       completion:accountStoreHandler];
}

- (IBAction)instagramClickHandler:(id)sender {
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        if ([self.images count] == 1) {
            [self.facebookButton setSelected:NO];
            [self.twitterButton setSelected:NO];
            [self.instagramButton setSelected:YES];
            [self.mailButton setSelected:NO];
            [self.messageButton setSelected:NO];
        }
        else {
            
        }
        
    }
    else {
        
    }
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
        for (int i=0; i<[self.images count]; i++) {
            [self postImage:[self.images objectAtIndex:i] withStatus:self.textView.text];
        }
    }
    else if (self.instagramButton.selected) {
        
        UIImage* instaImage = [self.images objectAtIndex:0];
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        _docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _docController.delegate=self;
        _docController.UTI = @"com.instagram.exclusivegram";
        [_docController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
        
    }
    else if (self.mailButton.selected) {
        [self createEmail];
    }
    else if (self.messageButton.selected) {
        
    }
}

- (void)facebookPosting{
    
    for (int i=0; i<[self.images count]; i++) {
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       UIImagePNGRepresentation([self.images objectAtIndex:i]), @"source",
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
                                      NSString *msg = [NSString stringWithFormat:@"result: %@", result];
                                      NSLog(@"%@", msg);
                                  } else {
                                      // An error occurred, we need to handle the error
                                      // See: https://developers.facebook.com/docs/ios/errors
 
                                      NSString *msg = [NSString stringWithFormat:@"%@", error.description];
                                      NSLog(@"%@", msg);
                                  }
                              }];
    }
}

- (void)postImage:(UIImage *)image withStatus:(NSString *)status
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler = ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
        }
    };
    
    [accountStore requestAccessToAccountsWithType:twitterType
                                          options:NULL
                                       completion:accountStoreHandler];
}

- (void)createEmail {
    //Create a string with HTML formatting for the email body
    NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
    //Add some text to it however you want
    
    NSString *bodymessage = [NSString stringWithFormat:@"<p>%@</p>", self.textView.text];
    
    [emailBody appendString:bodymessage];
    //Pick an image to insert
    //This example would come from the main bundle, but your source can be elsewhere
    
    for (int i=0; i<[self.images count]; i++) {
        //Convert the image into data
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([self.images objectAtIndex:i])];
        //Create a base64 string representation of the data using NSData+Base64
        NSString *base64String = [imageData base64Encoding];
        //Add the encoded string to the emailBody string
        //Don't forget the "<b>" tags are required, the "<p>" tags are optional
        [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='data:image/png;base64,%@'></b></p>",base64String]];
        //You could repeat here with more text or images, otherwise
    }

    //close the HTML formatting
    [emailBody appendString:@"</body></html>"];
//    NSLog(@"%@",emailBody);
    
    //Create the mail composer window
    MFMailComposeViewController *emailDialog = [[MFMailComposeViewController alloc] init];
    emailDialog.mailComposeDelegate = self;
    [emailDialog setSubject:@"Title 적으면 됨."];
    [emailDialog setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:emailDialog animated:YES completion:^(void){
        
    }];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0) {
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
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
