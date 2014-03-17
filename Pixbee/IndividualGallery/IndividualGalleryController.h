//
//  IndividualGalleryController.h
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface IndividualGalleryController : PBCommonViewController

@property (strong, nonatomic) NSDictionary *usersPhotos;
@property (nonatomic, assign) int UserID;
@property (nonatomic, assign) int UserColor;
@end
