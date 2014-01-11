//
//  PBAppDelegate.m
//  Pixbee
//
//  Created by skplanet on 2013. 11. 29..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "PBAppDelegate.h"
#import "FBHelper.h"
#import "TestFlight.h"
#import "PBViewController.h"
#import "IntroViewController.h"

@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"0d73a652-a45f-4b76-9fec-026bd931c1f7"];
    [SQLManager initDataBase];

//    // Uncomment to change the background color of navigation bar
//////    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xffcf0e)];
////    
////    // Uncomment to change the color of back button
////    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
////    
////    // Uncomment to assign a custom backgroung image
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar@2x.png"] forBarMetrics:UIBarMetricsDefault];
//    
//    // Uncomment to change the back indicator image
//    
//    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back_btn.png"]];
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back_btn.png"]];
//    
    

//    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:SHOW_INFO_VIEW]) {
        self.window.rootViewController = [[IntroViewController alloc] init];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOW_INFO_VIEW];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [self goMainView];
    }
    
    [self.window makeKeyAndVisible];

    
//    [SQLManager updateUser:@{ @"UserID" : @(1), @"UserName" : @"Test User", @"UserProfile" : @"http://graph.facebook.com/100004326285149/picture?type=large" }];
    // Override point for customization after application launch.
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

// FBSample logic
// It is possible for the user to switch back to your application, from the native Facebook application,
// when the user is part-way through a login; You can check for the FBSessionStateCreatedOpenening
// state in applicationDidBecomeActive, to identify this situation and close the session; a more sophisticated
// application may choose to notify the user that they switched away from the Facebook application without
// completely logging in
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // FBSample logic
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of FBAppCall the provided
// session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
}

- (void)goMainView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    self.window.rootViewController = rootViewController;
}

@end
