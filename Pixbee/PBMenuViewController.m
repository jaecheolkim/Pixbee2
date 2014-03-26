//
//  DEMOMenuViewController.m
//  RESideMenuStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "PBMenuViewController.h"
#import "UIViewController+RESideMenu.h"
#import "PBMenuTableViewCell.h"

#define CELL_ID @"MENU_CELL_ID"
#define cellHeight 56
#define cellWidth 235

@interface PBMenuViewController ()
{
    //NSInteger selectedMenu;
    
    UIImageView *syncAnimaionView;

}
@property (strong, nonatomic) NSArray *menus;
@property (strong, nonatomic) NSArray *viewContorllers;

@end

@implementation PBMenuViewController
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MeunViewControllerEventHandler:)
												 name:@"MeunViewControllerEventHandler" object:nil];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _menus = @[@"FaceTab", @"UnFaceTab", @"Camera", @"Setting"];
    _viewContorllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"MainDashBoard"],
                        [self.storyboard instantiateViewControllerWithIdentifier:@"AllPhotos"],
                        [self.storyboard instantiateViewControllerWithIdentifier:@"camera"],
                        [self.storyboard instantiateViewControllerWithIdentifier:@"setting"] ];
    
    
    NSArray *imageNames1 = @[@"logo_01", @"logo_02", @"logo_03", @"logo_04",
                             @"logo_05", @"logo_06"];
    
 
    NSMutableArray *images1 = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames1.count; i++) {
        [images1 addObject:[UIImage imageNamed:[imageNames1 objectAtIndex:i]]];
    }

    // Slow motion animation
    syncAnimaionView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 241, 28, 32)];
    syncAnimaionView.animationImages = images1;
    syncAnimaionView.animationDuration = 1;
    
    [self.view addSubview:syncAnimaionView];
    syncAnimaionView.hidden = YES;
    //[syncAnimaionView startAnimating];

    
    
    
    self.tableView = ({
//        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        CGRect tableViewFrame = CGRectMake(0, (self.view.frame.size.height - cellHeight * [_menus count]) / 2.0f, self.view.frame.size.width, cellHeight * [_menus count]);
        
        NSLog(@"Menu Table frame = %@", NSStringFromCGRect(tableViewFrame));
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
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
    
    [self.tableView registerClass:[PBMenuTableViewCell class] forCellReuseIdentifier:CELL_ID];
    
    [self.view addSubview:self.tableView];
    
    //selectedMenu = 0;
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    
    [self.view bringSubviewToFront:syncAnimaionView];
    

}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //selectedMenu = indexPath.row;

    UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
 
    dispatch_async(dispatch_get_main_queue(), ^{
        navigationController.viewControllers = @[_viewContorllers[indexPath.row]];
        [self.sideMenuViewController hideMenuViewController];
    });
    
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        switch (indexPath.row) {
//            case 0:
//                
//                navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"MainDashBoard"]];
//                [self.sideMenuViewController hideMenuViewController];
//                break;
//            case 1:
//                navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"AllPhotos"]];
//                [self.sideMenuViewController hideMenuViewController];
//                break;
//                
//            case 2:
//                navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"camera"]];
//                [self.sideMenuViewController hideMenuViewController];
//                break;
//            case 3:
//                navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:@"setting"]];
//                [self.sideMenuViewController hideMenuViewController];
//                break;
//                
//            default:
//                
//                break;
//        }
//    });

}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
    //return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [_menus count];
    
    //return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = CELL_ID;
    PBMenuTableViewCell *cell = (PBMenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.index = indexPath.row;

    return cell;
}


#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController");
    self.willViewed = YES;

#warning :: 사이드 메뉴 진입시 컨턴츠 네비게이션 바 숨기고 싶을 때는 아래의 주석 해제.
//    UINavigationController *navigationController = (UINavigationController *)sideMenu.contentViewController;
//    //[UIView animateWithDuration:0.2 animations:^{
//        [navigationController setNavigationBarHidden:YES animated:YES];
//    //}];
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
    
//    UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
 
    UINavigationController *navigationController = (UINavigationController *)sideMenu.contentViewController;
    
    NSArray *viewControllers = navigationController.viewControllers;
    NSString *viewControllerName =  NSStringFromClass([viewControllers[0] class]);
    //NSLog(@"Contents ViewController Class = %@",viewControllerName);
    
    //[UIView animateWithDuration:0.2 animations:^{
        if([viewControllerName isEqualToString:@"PBMainDashBoardViewController"]) {
            [navigationController setNavigationBarHidden:NO  animated:YES];
            
        }
        if([viewControllerName isEqualToString:@"AllPhotosController"]) {
            [navigationController setNavigationBarHidden:NO  animated:YES];
            
            
        }
        if([viewControllerName isEqualToString:@"FaceDetectionViewController"]){
            [navigationController setNavigationBarHidden:YES  animated:YES];
        }
        
        if([viewControllerName isEqualToString:@"PBSettingTableViewController"]){
            [navigationController setNavigationBarHidden:NO  animated:YES];
        }
        
        if([viewControllerName isEqualToString:@"PBMenuViewController"]){
            [navigationController setNavigationBarHidden:YES  animated:YES];
        }

    //}];

}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    self.willViewed = NO;
    NSLog(@"didHideMenuViewController");
    
    

    //[self.navigationController setNavigationBarHidden:YES];
}


- (void)MeunViewControllerEventHandler:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    
    if([userInfo[@"moveTo"] isEqualToString:@"MainDashBoard"]) {
        
        UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
        
        //[navigationController popToRootViewControllerAnimated:NO];
        //[self.sideMenuViewController showMenuViewController];
        navigationController.viewControllers = @[_viewContorllers[0]];
        [self.sideMenuViewController hideMenuViewController];
        
	}
    


    
    if([userInfo[@"moveTo"] isEqualToString:@"Camera"]) {

        UINavigationController *navigationController = (UINavigationController *)self.sideMenuViewController.contentViewController;
        
        navigationController.viewControllers = @[_viewContorllers[2]];
        [self.sideMenuViewController hideMenuViewController];
        
	}
    

    if([[userInfo objectForKey:@"SyncPixbee"] floatValue] < 1.0 ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(syncAnimaionView.hidden){
                syncAnimaionView.hidden = NO;
            }
            
            if(!syncAnimaionView.isAnimating){
                [syncAnimaionView startAnimating];
            }
            
            NSLog(@"Sync = %f", [[userInfo objectForKey:@"SyncPixbee"] floatValue]);

        });
        
 	}
    
    if([[userInfo objectForKey:@"SyncPixbee"] floatValue] >= 1.0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [syncAnimaionView stopAnimating];
            syncAnimaionView.hidden = YES;
        });
        

        
	}
    
    

}


@end
