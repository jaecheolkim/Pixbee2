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

@interface PBViewController () <FBHelperDelegate>
{
    BOOL alreadyChecked;
    BOOL alreadyPushed;
}
// 객체
@property (strong, nonatomic) IBOutlet UIView *viewFBLoginViewArea;
@property (strong, nonatomic) IBOutlet UIImageView *PixbeeLogo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation PBViewController

@synthesize PixbeeLogo = _PixbeeLogo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FBHELPER.delegate = self;
    [FBHELPER loadFBLoginView:self.viewFBLoginViewArea];
    
    if(GlobalValue.userName) {
        alreadyChecked = YES;
        [_viewFBLoginViewArea setHidden:YES];
        [_indicator startAnimating];
        [self checkNewPhotos];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Template generated code

- (void)viewDidUnload
{
//    self.loginButton = nil;
    self.PixbeeLogo = nil;
    
    [super viewDidUnload];
}

- (void)checkNewPhotos
{
    //Check new photos and go main dashboard
    [AssetLib syncAlbumToDB:^(NSArray *result) {
        //NSLog(@"Result = %@", result);
        if(result.count > 0  && result != nil){
            ALAsset *lastAsset = [[result objectAtIndex:result.count-1] objectForKey:@"Asset"];
            NSURL *assetURL = [lastAsset valueForProperty:ALAssetPropertyAssetURL];
            
            NSLog(@"Last Asset URL = %@", assetURL.absoluteString);
            
            if(![GlobalValue.lastAssetURL isEqualToString:assetURL.absoluteString]) {
                //New Asset found
                
                NSLog(@" ============== new asset found!");
            }
            NSLog(@"Locations : %@", [AssetLib locationArray]);
            [AssetLib checkGeocode];
            GlobalValue.lastAssetURL = assetURL.absoluteString;
        }

        [self goNext];
    }];
    
}

- (void)goNext
{
    [_indicator stopAnimating];
    if(alreadyPushed) return;
    
    self.navigationController.navigationBarHidden = NO;
    alreadyPushed = YES;
    if(alreadyChecked)
        [self performSegueWithIdentifier:SEGUE_1_2_TO_3_1 sender:self];
    else
        [self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
}

#pragma mark FBHelperDelegate
- (void)FBLoginFetchedUserInfo:(id<FBGraphUser>)user
{
    NSLog(@"====== FB Loged in... user :%@", user );
    

    NSLog(@"========================FB Loged user : %@", user.name );
    GlobalValue.userName = user.name;
    
    int UserID = [SQLManager newUserWithFBUser:user];
 
    NSLog(@"Default user name = %@ / id = %d", GlobalValue.userName, UserID);

    NSLog(@"========================GLOBAL_VALUE user : %@", GlobalValue.userName );
    
    NSLog(@"====> loginViewShowingLoggedInUser:");
}

- (void)FBLogedInUser
{
    [self getFBFriend];
}

- (void)FBHandleError {
    
    //[self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
}

- (void)getFBFriend {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        FBHELPER.friends = nil;
        
        // 사진(small, normal, large, square
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"name,id,picture.type(normal)", @"fields",
                                nil
                                ];
        
        [FBRequestConnection startWithGraphPath:@"/me/friends"
                                     parameters:params
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  /* handle the result */
                                  NSDictionary *data = (NSDictionary *)result;
                                  NSArray *friends = [data objectForKey:@"data"];
                                  FBHELPER.friends = friends;
                                  
                                  [self goNext];
                                  //[self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
                              }];

    });
}

//
////친구 리스트를 다 받았을 때 위임되는 함수.
//- (void)finishFriendLists:(NSArray*)friendList {
//    
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_FACEANALYZE]) {
        
        NSArray *result = [SQLManager getUserInfo:GlobalValue.userName];
        NSDictionary *user = [result objectAtIndex:0];
        NSNumber *userID = [user objectForKey:@"UserID"];
        
        if(userID) {
            UINavigationController *navi = segue.destinationViewController;
            FaceDetectionViewController *destination = [navi.viewControllers objectAtIndex:0];
            //        //UINavigationController *navi = segue.destinationViewController;
            //        FaceDetectionViewController *destination = segue.destinationViewController;
            destination.userID = [userID intValue]; //[NSNumber numberWithInt:100];
            destination.userName = GlobalValue.userName;
            destination.faceMode = FaceModeCollect;
            destination.segueid = SEGUE_FACEANALYZE;
        }
    }

}


@end
