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
    return self.assets[index];
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
