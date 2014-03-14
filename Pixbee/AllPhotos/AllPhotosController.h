//
//  AllPhotosController.h
//  Pixbee
//
//  Created by skplanet on 2013. 12. 5..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface AllPhotosController : PBCommonViewController

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSString *segueIdentifier;
@property (strong, nonatomic) NSString *operateIdentifier;
@end
