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

@end

@implementation PBViewController

@synthesize PixbeeLogo = _PixbeeLogo;

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //_indicator.hidden = YES;
    _FBLoginButton.hidden = YES;
    
    if(IsEmpty(GlobalValue.userName)) isFirstVisit = YES;
    else isFirstVisit = NO;
    

}

- (void)viewDidUnload
{
    //    self.loginButton = nil;
    self.PixbeeLogo = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    [FBHELPER loadFBLoginView:self.viewFBLoginViewArea];
//    FBHELPER.delegate = self;
//    
//    [_indicator setHidesWhenStopped:YES];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSDictionary *profile = [[PFUser currentUser] objectForKey:@"profile"];
        
        NSLog(@"Current User = %@", profile);
        
        [self checkNexProcess:profile];
        
    } else {

        [UIView transitionWithView:_PixbeeLogo
                          duration:1.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _PixbeeLogo.image = [UIImage imageNamed:@"Login_Page"];
                        }
                        completion:^(BOOL finished) {
                            _FBLoginButton.hidden = NO;
                        }];
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Template generated code

- (void)checkNexProcess:(NSDictionary*)profile
{
    [FBHELPER getFBFriend];
    
    [self checkNewPhotos];
}


- (void)checkNewPhotos
{
    if(isCalledCheckNewPhotos) return;
    isCalledCheckNewPhotos = YES;
    
    [_viewFBLoginViewArea setHidden:YES];
    //[_indicator startAnimating];
    
    //Check new photos and go main dashboard
    [AssetLib syncAlbumToDB:^(NSArray *result) {
        //NSLog(@"Result = %@", result);
        if(result.count > 0  && result != nil){
            NSArray *lastDistance = [result objectAtIndex:result.count-1];
            ALAsset *lastAsset = [[lastDistance objectAtIndex:lastDistance.count-1] objectForKey:@"Asset"];
            NSURL *assetURL = [lastAsset valueForProperty:ALAssetPropertyAssetURL];
            
            NSLog(@"Last Asset URL = %@", assetURL.absoluteString);
            
            if(![GlobalValue.lastAssetURL isEqualToString:assetURL.absoluteString]) {
                //New Asset found
                
                NSLog(@" ============== new asset found!");
            }
            NSLog(@"Locations : %@", [AssetLib locationArray]);
            //[AssetLib checkGeocode];
            GlobalValue.lastAssetURL = assetURL.absoluteString;
        }

        [self goNext];
    }];
    
}

- (void)goNext
{
    if(isCalledGoNext) return;
    isCalledGoNext = YES;

    
    [_indicator stopAnimating];
    
    self.navigationController.navigationBarHidden = NO;
 
    if(!isFirstVisit)
        [self performSegueWithIdentifier:SEGUE_1_2_TO_3_1 sender:self];
    else
        [self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
}


#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender
{
    _FBLoginButton.enabled = NO;
    
    [_indicator startAnimating];

    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];

    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else {
            NSDictionary *profile = user[@"profile"];
            NSLog(@"Current User = %@", profile);
            
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in! = %@", user);
 
                [[PFUser currentUser] setObject:profile forKey:@"profile"];
                [[PFUser currentUser] saveInBackground];
                
             } else {
                NSLog(@"User with facebook logged in! = %@", user);
 
             }
            
            if(IsEmpty(GlobalValue.userName)) {
                int UserID = [SQLManager newUserWithPFUser:profile];
                
                GlobalValue.userName = profile[@"name"]; // user.name;
                GlobalValue.UserID = UserID;
                NSLog(@"Default user name = %@ / id = %d", GlobalValue.userName, UserID);
                
                isFirstVisit = YES;
            } else {
                 isFirstVisit = NO;
            }
                
            
 
            [self checkNexProcess:profile];
            
 
        }
        
    }];
    
    //[_indicator startAnimating]; // Show loading indicator until login is finished
}



#pragma mark FBHelperDelegate

////맨 마지막에 호출 됨.
//- (void)FBLoginFetchedUserInfo:(id<FBGraphUser>)user
//{
//    NSLog(@"====== FB Loged in... user :%@", user );
//    NSLog(@"========================FB Loged user : %@", user.name );
//    
//    if(IsEmpty(GlobalValue.userName)) {
//        int UserID = [SQLManager newUserWithFBUser:user];
//
//        GlobalValue.userName = user.name;
//        GlobalValue.UserID = UserID;
//        NSLog(@"Default user name = %@ / id = %d", GlobalValue.userName, UserID);
//        isFirstVisit = YES;
//    }
//#warning 이상하게 이게 두번 호출되어서 다음 NavigationController 문제가 생겼음 (결국 Push를 두번 한 꼴.)
//    [self checkNewPhotos];
//
//}
//
//- (void)FBLogedInUser
//{
//    [self getFBFriend];
//}
//
//- (void)FBHandleError {
//    
//    //[self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
//}
//
//- (void)getFBFriend {
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        FBHELPER.friends = nil;
//        
//        // 사진(small, normal, large, square
//        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"name,id,picture.type(normal)", @"fields",
//                                nil
//                                ];
//        
//        [FBRequestConnection startWithGraphPath:@"/me/friends"
//                                     parameters:params
//                                     HTTPMethod:@"GET"
//                              completionHandler:^(
//                                                  FBRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error
//                                                  ) {
//                                  /* handle the result */
//                                  NSDictionary *data = (NSDictionary *)result;
//                                  NSArray *friends = [data objectForKey:@"data"];
//                                  FBHELPER.friends = friends;
//                                  
//                                  [FBRequestConnection startWithGraphPath:@"/me"
//                                                               parameters:nil
//                                                               HTTPMethod:@"GET"
//                                                        completionHandler:^(
//                                                                            FBRequestConnection *connection,
//                                                                            id result,
//                                                                            NSError *error
//                                                                            ) {
//                                                            NSLog(@"ME : result = %@", result);
//                                                            
//                                                            NSMutableArray *array = [NSMutableArray arrayWithArray:FBHELPER.friends];
//                                                            [array insertObject:@{@"name":result[@"name"], @"id":result[@"id"], @"picture":[NSNull null]} atIndex:0];
//
//                                                            FBHELPER.friends = (NSArray*)array;
//                                                            
//                                                            NSLog(@"Friends = %@", FBHELPER.friends);
//                                                        }];
//                                  
//                                  
//                                  
//                                  //[self goNext];
//                                  //[self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
//                              }];
//
//    });
//}

//
////친구 리스트를 다 받았을 때 위임되는 함수.
//- (void)finishFriendLists:(NSArray*)friendList {
//    
//}

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
