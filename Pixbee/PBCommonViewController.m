//
//  PBCommonViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 1/29/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBCommonViewController.h"
#import "SDImageCache.h"
#import "UIImage+ImageEffects.h"

@interface PBCommonViewController ()

@end

@implementation PBCommonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        


    }
    return self;
}

- (void)refreshNavigationBarColor:(UIColor*)color
{
    if(color != nil){
//        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//        [[UINavigationBar appearance] setShadowImage:nil];

        [[UINavigationBar appearance] setBarTintColor:color];
    } else {
        //Clear Navigationbar
        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];

    }
}

- (void)refreshBGImage:(UIImage*)image
{

    if(IsEmpty(_bgImageView))
        _bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIImage *lastImage;
    
    if(image != nil) {
        lastImage = image;
    } else {
        lastImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"LastImage"];
        if(IsEmpty(lastImage)) {
            lastImage = [UIImage imageNamed:@"bg.png"];
        }
    }
    
    
    lastImage = [lastImage applyLightEffect];
    _bgImageView.image = lastImage;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor grayColor];// [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           NAVIGATION_TITLE_COLOR, NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"GillSans-Medium" size:21.0], NSFontAttributeName, nil]];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setTitle:(NSString *)title
//{
//
//    [self.navigationController setTitle:title];
//    
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
