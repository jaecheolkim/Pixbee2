//
//  PBAppDelegate.m
//  Pixbee
//
//  Created by skplanet on 2013. 11. 29..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "PBAppDelegate.h"
#import "FBHelper.h"
//#import "TestFlight.h"
#import "PBViewController.h"
#import "IntroViewController.h"

#import <Parse/Parse.h>


@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    
    [Flurry startSession:@"88CQSKXDCHXHGMP376SM"];
    [Flurry logEvent:@"APP_START" timed:YES];
    
    //[TestFlight takeOff:@"c65316d7-3ac6-4cbf-be5d-97d643b00047"];
    
    [SQLManager initDataBase];

    [FBHELPER openFBSession];
    
    [self initParse:launchOptions];
    
    [self setGalleryFilter];
    
    [self checkIntroShown];
    
    [self checkBundle];

    [self.window makeKeyAndVisible];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//// FBSample logic
//// It is possible for the user to switch back to your application, from the native Facebook application,
//// when the user is part-way through a login; You can check for the FBSessionStateCreatedOpenening
//// state in applicationDidBecomeActive, to identify this situation and close the session; a more sophisticated
//// application may choose to notify the user that they switched away from the Facebook application without
//// completely logging in
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    // FBSample logic
//    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
//    [FBAppEvents activateApp];
//    
//    // FBSample logic
//    // We need to properly handle activation of the application with regards to SSO
//    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
//    [FBAppCall handleDidBecomeActive];
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    // FBSample logic
//    // if the app is going away, we close the session object
//    [FBSession.activeSession close];
//}
//
//// FBSample logic
//// The native facebook application transitions back to an authenticating application when the user
//// chooses to either log in, or cancel. The url passed to this method contains the token in the
//// case of a successful login. By passing the url to the handleOpenURL method of FBAppCall the provided
//// session object can parse the URL, and capture the token for use by the rest of the authenticating
//// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
//// session object, and does not reflect whether or not the login was successful; the session object's
//// state, as well as its arguments passed to the state completion handler indicate whether the login
//// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
//// will be boolean NO, meaning the URL was not handled by the authenticating application
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    // attempt to extract a token from the url
//    // attempt to extract a token from the url
//    return [FBAppCall handleOpenURL:url
//                  sourceApplication:sourceApplication
//                    fallbackHandler:^(FBAppCall *call) {
//                        NSLog(@"In fallback handler");
//                    }];
//}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
//    return [FBAppCall handleOpenURL:url
//                  sourceApplication:sourceApplication
//                        withSession:[PFFacebookUtils session]];
    
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [FBHELPER FBSessionStateChanged:session state:state error:error];
     }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    //[[PFFacebookUtils session] close];
    
    [Flurry endTimedEvent:@"APP_START" withParameters:nil];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}


- (void)initParse:(NSDictionary *)launchOptions
{
    // ****************************************************************************
    // Fill in with your Parse credentials:
    // ****************************************************************************
    // [Parse setApplicationId:@"your_application_id" clientKey:@"your_client_key"];

    [Parse setApplicationId:@"PwDAx6ZjgQkYKJzpQOEQcaxRobO66Wvv4flbwlbx"
                  clientKey:@"HbgGBotzsPaiCvRCB8IarBJ3aWpqrOXZVCmuPDM1"];
    
    // ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    //[PFFacebookUtils initializeFacebook];
    
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar0";
//    [testObject saveInBackground];
 
}

- (void)createParseUser:(NSDictionary*)userProfile
{
    PFUser *user = [PFUser user];
    user.username = userProfile[@"name"];
    user.password = @"";
    user.email = @"";
    
    
    // other fields can be set just like with PFObject
    user[@"phone"] = @"";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            NSLog(@"[FBLogedInUser] :: PFUser success signUpInBackground");
            // Hooray! Let them use the app now.
            
            [PFUser logInWithUsernameInBackground:@"myname" password:@"mypass"
                                            block:^(PFUser *user, NSError *error) {
                                                if (user) {
                                                    // Do stuff after successful login.
                                                    NSLog(@"[FBLogedInUser] :: userProfile = %@ ", userProfile);
                                                    //Make a new Parse User
                                                    [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                                                    [[PFUser currentUser] saveInBackground];
                                                    
                                                } else {
                                                    // The login failed. Check error to see why.
                                                }
                                            }];
            
            
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
        }
    }];

}

- (void)setGalleryFilter
{
    // filter test
    //DISTANCE, DAY, WEEK, MONTH, YEAR 에 따라서 필터되게 했구요..
    //DISTANCE일 경우는 [[NSUserDefaults standardUserDefaults] objectForKey:@"DISTANCE”]으로 반경 가져와서 처리하게 했습니다.
    //    [[NSUserDefaults standardUserDefaults] setObject:@"DISTANCE" forKey:@"ALLPHOTO_FILTER"];
    //    [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"DISTANCE"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:@"DAY" forKey:@"ALLPHOTO_FILTER"];
    [[NSUserDefaults standardUserDefaults] setInteger:500 forKey:@"DISTANCE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkIntroShown
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:SHOW_INFO_VIEW]) {
        self.window.rootViewController = [[IntroViewController alloc] init];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOW_INFO_VIEW];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [self goMainView];
    }
}

- (void)checkBundle
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    NSLog(@" App build = %@ / bundleName = %@", build, bundleName);
    
    GlobalValue.appVersion = build;
 }

- (void)goMainView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    self.window.rootViewController = rootViewController;
}

@end
