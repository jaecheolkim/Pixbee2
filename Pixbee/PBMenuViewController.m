//
//  DEMOMenuViewController.m
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "PBMenuViewController.h"
#import "UIViewController+RESideMenu.h"

@interface PBMenuViewController ()
{
    NSInteger memu;
}
@end

@implementation PBMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
    memu = indexPath.row;
    
    switch (indexPath.row) {
        case 0:
            
            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"firstController"]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"secondController"]];
            [self.sideMenuViewController hideMenuViewController];
            break;
            
        case 2:
            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"camera"]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"setting"]];
            [self.sideMenuViewController hideMenuViewController];
            break;
            
        default:
            
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"Home", @"UnFaceTab", @"Camera", @"Settings", @"Log Out"];
    NSArray *images = @[@"IconHome", @"IconCalendar", @"IconProfile", @"IconSettings", @"IconEmpty"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController");
    self.willViewed = YES;
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController");
    self.willViewed = YES;
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    self.willViewed = NO;
    
    NSLog(@"willHideMenuViewController");
    
    UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
    //UINavigationBar *navigationBar = navigationController.navigationBar;
    
    NSArray *viewControllers = navigationController.viewControllers;
    NSString *viewControllerName =  NSStringFromClass([viewControllers[0] class]);
    NSLog(@"Contents ViewController Class = %@",viewControllerName);
    
    
    if([viewControllerName isEqualToString:@"PBMainDashBoardViewController"]) {
        [navigationController setNavigationBarHidden:NO];

    }
    if([viewControllerName isEqualToString:@"AllPhotosController"]) {
        [navigationController setNavigationBarHidden:NO];


    }
    if([viewControllerName isEqualToString:@"FaceDetectionViewController"]){
        [navigationController setNavigationBarHidden:YES];
    }
    
    if([viewControllerName isEqualToString:@"PBSettingTableViewController"]){
        [navigationController setNavigationBarHidden:NO];
    }


}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    self.willViewed = NO;
    NSLog(@"didHideMenuViewController");
    
    

    //[self.navigationController setNavigationBarHidden:YES];
}

@end
