//
//  PBViewController.m
//  Pixbee
//
//  Created by skplanet on 2013. 11. 29..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <Social/Social.h>
#import "PBViewController.h"
#import "FBHelper.h"
#import "FaceDetectionViewController.h"
#import <Parse/Parse.h>
#import "PBAppDelegate.h"

@interface PBViewController () <FBHelperDelegate>
{
    BOOL isFirstVisit;
    BOOL isCalledCheckNewPhotos;
    BOOL isCalledGoNext;
}
// 객체
@property (strong, nonatomic) IBOutlet UIView *viewFBLoginViewArea;
@property (strong, nonatomic) IBOutlet UIImageView *PixbeeLogo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *FBLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PBViewController

@synthesize PixbeeLogo = _PixbeeLogo;

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FBHELPER.delegate = self;
 
    UIColor *strokeColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.15];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:@"Join with Facebook"
                                                                         attributes:@{
                                                                                      //NSFontAttributeName : font,
                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                      NSStrokeWidthAttributeName : @-3,
                                                                                      NSStrokeColorAttributeName : strokeColor,
                                                                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }];
    
    
    [self.FBLoginButton setAttributedTitle:attributedText forState:UIControlStateNormal];

    _FBLoginButton.alpha = 0.0;
    _FBLoginButton.enabled = NO;
    if(IsEmpty(GlobalValue.userName)) isFirstVisit = YES;
    else isFirstVisit = NO;
    

}

- (void)viewDidUnload
{
    self.PixbeeLogo = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        
    } else {
        
        [UIView transitionWithView:_PixbeeLogo
                          duration:0.7
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _PixbeeLogo.image = [UIImage imageNamed:@"logo_2"];
                            _titleLabel.alpha = 0.0;
                            _FBLoginButton.alpha = 1.0;
                        }
                        completion:^(BOOL finished) {

                            _FBLoginButton.enabled = YES;
                        }];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Template generated code

- (void)checkNexProcess
{
    [FBHELPER getFBFriend];
    
    [self checkNewPhotos];
}


- (void)checkNewPhotos
{
    if(isCalledCheckNewPhotos) return;
    isCalledCheckNewPhotos = YES;

    [self goNext];
}

- (void)goNext
{
    if(isCalledGoNext) return;
    isCalledGoNext = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicator stopAnimating];
        [self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
    });
    
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender
{
    [Flurry logEvent:@"Facebook_Login"];
    
    _FBLoginButton.enabled = NO;
    
    [_indicator startAnimating];
    
    
    [FBHELPER doFBLogin];
}


#pragma mark FBHelperDelegate

- (void)FBLogedInUser
{
    _FBLoginButton.enabled = YES;
    [_indicator stopAnimating];
    
    
    [FBHELPER saveUserInfo:^(NSDictionary *userProfile) {
        
        if(IsEmpty(GlobalValue.userName)) {
            int UserID = [SQLManager newUserWithPFUser:userProfile];
            
            GlobalValue.userName = userProfile[@"name"]; // user.name;
            GlobalValue.UserID = UserID;
            NSLog(@"[FBLogedInUser] :: Default user name = %@ / id = %d", GlobalValue.userName, UserID);
            
            PBAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            
            [appDelegate createParseUser:userProfile];
 
            isFirstVisit = YES;
            
        } else {
            
            isFirstVisit = NO;
        }

        [self checkNexProcess];
        

    } failure:^(NSError *error) {
        if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
             isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

- (void)FBLoggedOutUser
{
    _FBLoginButton.enabled = YES;
    [_indicator stopAnimating];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue id = %@", segue.identifier);
    if ([segue.identifier isEqualToString:SEGUE_FACEANALYZE]) {
        
        int UserID = [SQLManager getUserID:GlobalValue.userName];
        
        if(UserID) {
//            UINavigationController *navi = segue.destinationViewController;
//            FaceDetectionViewController *destination = [navi.viewControllers objectAtIndex:0];
            
            FaceDetectionViewController *destination = segue.destinationViewController;
            destination.UserID = UserID;
            destination.UserName = GlobalValue.userName;
            destination.faceMode = FaceModeCollect;
            destination.segueid = SEGUE_FACEANALYZE;
        }
    }

}


@end
