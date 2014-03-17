//
//  PBMenuTableViewCell.h
//  Pixbee
//
//  Created by jaecheol kim on 3/17/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBMenuTableViewCell : UITableViewCell
@property (nonatomic, assign) NSInteger index;

- (void)refreshSelected;
- (void)refreshUnSelected;
@end
