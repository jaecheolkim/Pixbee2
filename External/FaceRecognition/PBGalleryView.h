//
//  PBGalleryView.h
//  Pixbee
//
//  Created by jaecheol kim on 4/11/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface PBGalleryView : UIView <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) NSMutableArray *photoAssets;
@property (nonatomic, assign) BOOL isShown;
@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UIImage *currentImage;


- (void)reloadData;

@end
