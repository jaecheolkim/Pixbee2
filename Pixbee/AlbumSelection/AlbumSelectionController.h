//
//  AlbumSelectionController.h
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumSelectionController : PBCommonViewController
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSString *segueIdentifier;
@property (strong, nonatomic) NSString *operateIdentifier;
@property (strong, nonatomic) NSDictionary *selectedUserInfo;

@end
