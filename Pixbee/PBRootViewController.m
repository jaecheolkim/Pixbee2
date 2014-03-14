//
//  DEMOViewController.m
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//


#import "PBRootViewController.h"
#import "PBMenuViewController.h"

@interface PBRootViewController ()

@end

@implementation PBRootViewController

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.backgroundImage = [UIImage imageNamed:@"MenuBackground"];
    self.delegate = (PBMenuViewController *)self.menuViewController;
    
    [AssetLib checkNewPhoto];
    
}

- (BOOL)prefersStatusBarHidden
{
    PBMenuViewController *menuController = (PBMenuViewController *)self.menuViewController;
    
    if(menuController.willViewed) return YES;
        
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



@end
