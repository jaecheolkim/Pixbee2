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

// 객체
@property (strong, nonatomic) IBOutlet UIView *viewFBLoginViewArea;
@property (strong, nonatomic) IBOutlet UIImageView *PixbeeLogo;

@end

@implementation PBViewController

@synthesize PixbeeLogo = _PixbeeLogo;

- (void)viewDidLoad
{
    [super viewDidLoad];
//	// Do any additional setup after loading the view, typically from a nib.
//    
//    // Create Login View so that the app will be granted "status_update" permission.
//    FBLoginView *loginview = [[FBLoginView alloc] init];
//    loginview.readPermissions = @[@"basic_info", @"read_stream"];
//    
//    CGRect lvFrame = loginview.frame;
//    CGSize lvSize = lvFrame.size;
//    CGRect viewFrame = self.view.frame;
//    
//    float position_x = (viewFrame.size.width - lvSize.width) / 2;
//    float position_y = (viewFrame.size.height - lvSize.height) / 2 + 130; //25;
//    
//    lvFrame = CGRectMake(position_x, position_y, lvSize.width, lvSize.height);
//    loginview.frame = lvFrame;
//    
//#ifdef __IPHONE_7_0
//#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
//    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
//        loginview.frame = lvFrame;
//    }
//#endif
//#endif
//#endif
//    loginview.delegate = [FBHelper sharedInstance];
//    [FBHelper sharedInstance].delegate = self;
//    
//    [self.view addSubview:loginview];
//    
//    [loginview sizeToFit];
    
    // Do any additional setup after loading the view.

    FBHELPER.delegate = self;
    [FBHELPER loadFBLoginView:self.viewFBLoginViewArea];
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

#pragma mark FBHelperDelegate
- (void)FBLoginFetchedUserInfo:(id<FBGraphUser>)user
{
    NSLog(@"====== FB Loged in... user :%@", user );
    

    NSLog(@"========================FB Loged user : %@", user.name );
    GlobalValue.userName = user.name;
    
    int UserID = [SQLManager newUserWithFBUser:user];
 
    NSLog(@"Default user name = %@ / id = %d", GlobalValue.userName, UserID);

    NSLog(@"========================GLOBAL_VALUE user : %@", [GlobalValues sharedInstance].userName );
    
    NSLog(@"====> loginViewShowingLoggedInUser:");
}

- (void)FBLogedInUser
{
    [self getFBFriend];
}

- (void)FBHandleError {
    [self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
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
                                  [self performSegueWithIdentifier:SEGUE_FACEANALYZE sender:self];
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
    }
}


@end
