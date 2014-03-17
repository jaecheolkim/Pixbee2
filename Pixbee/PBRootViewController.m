//
//  DEMOViewController.m
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//


#import "PBRootViewController.h"
#import "PBMenuViewController.h"
#import "PBNavigationBar.h"

#import "FaceDetectionViewController.h"



@interface PBRootViewController ()

@end

@implementation PBRootViewController


- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.delegate = (PBMenuViewController *)self.menuViewController;
    
    self.panGestureEnabled = YES;
    self.backgroundImage =  [UIImage imageNamed:@"bg"]; //[UIImage imageNamed:@"MenuBackground"];
    self.panFromEdge = YES; //왼쪽 가장자리에서만 스와이핑시 메뉴 열리게
    self.scaleContentView = YES; // 메뉴 열릴때 오른쪽 뷰 사이즈 변경하게
    self.animationDuration = 0.2;

    
    [AssetLib checkNewPhoto];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RootViewControllerEventHandler:)
												 name:@"RootViewControllerEventHandler" object:nil];
    
}

- (BOOL)prefersStatusBarHidden
{
#warning :: 사이드 메뉴바로 이동할 때 statusBar 숨기고 싶을 때는 아래의 주석 해제.
//    PBMenuViewController *menuController = (PBMenuViewController *)self.menuViewController;
//    if(menuController.willViewed) return YES;
    
    UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
    NSArray *viewControllers = navigationController.viewControllers;
    NSString *viewControllerName =  NSStringFromClass([viewControllers[0] class]);
    NSLog(@"Contents ViewController Class = %@",viewControllerName);
    // NSStringFromClass([navigationController viewControllers]));
    
    if([viewControllerName isEqualToString:@"PBMainDashBoardViewController"]) return NO;
    if([viewControllerName isEqualToString:@"AllPhotosController"]) return NO;
    if([viewControllerName isEqualToString:@"FaceDetectionViewController"]) return YES;
    
    if([viewControllerName isEqualToString:@"PBSettingTableViewController"]) return NO;
    
    return YES;

}

- (UIStatusBarStyle)preferredStatusBarStyle
{

    UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
    NSArray *viewControllers = navigationController.viewControllers;
    NSString *viewControllerName =  NSStringFromClass([viewControllers[0] class]);
    NSLog(@"Contents ViewController Class = %@",viewControllerName);
    // NSStringFromClass([navigationController viewControllers]));
    
    if([viewControllerName isEqualToString:@"PBMainDashBoardViewController"]) return UIStatusBarStyleLightContent;
    if([viewControllerName isEqualToString:@"AllPhotosController"]) return UIStatusBarStyleLightContent;
    if([viewControllerName isEqualToString:@"FaceDetectionViewController"]) return UIStatusBarStyleLightContent;
    if([viewControllerName isEqualToString:@"PBSettingTableViewController"]) return UIStatusBarStyleLightContent;
    
    return UIStatusBarStyleDefault;

}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    PBMenuViewController *menuController = (PBMenuViewController *)self.menuViewController;
    if(!menuController.willViewed)
    {
    
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        
        NSString *navBarClassName = NSStringFromClass([navigationController.navigationBar class]);
        
        NSArray *viewControllers = navigationController.viewControllers;
        UIViewController *viewContorller = viewControllers[0];
        
        NSString *viewControllerName =  NSStringFromClass([viewContorller class]);
        NSLog(@"ViewController Class = %@",viewControllerName);
        NSLog(@"NavigationBar Class = %@", NSStringFromClass([navigationController.navigationBar class]));
        
        if([navBarClassName isEqualToString:@"PBNavigationBar"]){
            
            PBNavigationBar *navigationBar = (PBNavigationBar *)navigationController.navigationBar;

            UIColor *color = [UIColor colorWithRed:0.0f green:0.0f blue:90.0f/255.0f alpha:1];
            
            if([viewControllerName isEqualToString:@"PBMainDashBoardViewController"]) {
                color = nil;
                //color = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.7];
            }
            if([viewControllerName isEqualToString:@"AllPhotosController"]) {
                color = nil;
                // color = [UIColor colorWithRed:90.0f/255.0f green:0.0f blue:90.0f/255.0f alpha:1];
            }
            if([viewControllerName isEqualToString:@"FaceDetectionViewController"]) {
                color = nil;
                // color = [UIColor colorWithRed:0.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1];
                
                FaceDetectionViewController *cameraContorller = (FaceDetectionViewController *)viewControllers[0];
                cameraContorller.segueid = @"FromMenu";
                
            }
            if([viewControllerName isEqualToString:@"PBSettingTableViewController"]) {
                color = nil;
                // color = [UIColor colorWithRed:90.0f/255.0f green:0.0f blue:0.0f alpha:1];
            }
            
            [navigationBar setBarTintColor:color];

            
#warning :: 만약에 메인데쉬보드만 투명 네비 가지고 싶을 때 아래 주석 해제.
//            if([viewControllerName isEqualToString:@"PBMainDashBoardViewController"]) {
//                [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//                navigationBar.shadowImage = [UIImage new];
//                navigationBar.translucent = YES;
//            } else {
//                navigationBar.translucent = YES;
//            }



        }
    }
}



- (void)RootViewControllerEventHandler:(NSNotification *)notification
{
    if([[[notification userInfo] objectForKey:@"panGestureEnabled"] isEqualToString:@"NO"]) {
        
        self.panGestureEnabled = NO;
        
	}
    
    if([[[notification userInfo] objectForKey:@"panGestureEnabled"] isEqualToString:@"YES"]) {
        
        self.panGestureEnabled = YES;
        
	}
 }

@end
