//
//  FullScreenPhotoController.m
//  Pixbee
//
//  Created by JCKIM on 2013. 12. 3..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "FullScreenPhotoController.h"

@interface FullScreenPhotoController () <ASGalleryViewControllerDelegate>

@end

@implementation FullScreenPhotoController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setWantsFullScreenLayout:YES];
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popVC)];
//    self.navigationItem.leftBarButtonItem =  backButton; //[[UIBarButtonItem alloc] initWithCustomView:backButton];
//    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    
    // Create a containing view to position the button
    UIImage *barButtonImage = [UIImage imageNamed:@"back.png"];
    UIView *containingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barButtonImage.size.width + 40, barButtonImage.size.height)];
    //containingView.backgroundColor = [UIColor redColor];

    // Create a custom button with the image
    UIButton *barUIButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barUIButton setImage:barButtonImage forState:UIControlStateNormal];
    barUIButton.frame = CGRectMake(-14, 0, barButtonImage.size.width + 14, barButtonImage.size.height);
    barUIButton.contentEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 0);
    [barUIButton addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
     //barUIButton.backgroundColor = [UIColor yellowColor];
    
    [containingView addSubview:barUIButton];
    
    // Create a container bar button
    UIBarButtonItem *containingBarButton = [[UIBarButtonItem alloc] initWithCustomView:containingView];
    
    // Add the container bar button
    self.navigationItem.leftBarButtonItem = containingBarButton;

}

- (void) popVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTitle];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                        object:self
                                                      userInfo:@{@"panGestureEnabled":@"NO"}];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                        object:self
                                                      userInfo:@{@"panGestureEnabled":@"YES"}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSUInteger)numberOfAssetsInGalleryController:(ASGalleryViewController *)controller
{
    return [self.assets count];
}

-(id<ASGalleryAsset>)galleryController:(ASGalleryViewController *)controller assetAtIndex:(NSUInteger)index
{
    NSInteger count = [self.assets count] - 1;
    
    return self.assets[count - index];
    
    // return self.assets[index];
}

-(void)updateTitle
{
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%u of %u", nil),self.selectedIndex + 1,[self numberOfAssetsInGalleryController:self]];
}


-(void)selectedIndexDidChangedInGalleryController:(ASGalleryViewController*)controller;
{
    [self updateTitle];
}


@end
