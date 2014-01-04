//
//  SegmentCell.h
//  Pixbee
//
//  Created by skplanet on 2014. 1. 4..
//  Copyright (c) 2014년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *segmentLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end
