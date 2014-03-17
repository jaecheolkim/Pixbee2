//
//  PBMenuTableViewCell.m
//  Pixbee
//
//  Created by jaecheol kim on 3/17/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBMenuTableViewCell.h"

@interface PBMenuTableViewCell () {
    
}
@property (strong, nonatomic) UIImageView *menuImageView;
@end


@implementation PBMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 235, 56)];
        [self.contentView addSubview:_menuImageView];
        
        _menuImageView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] init];
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    NSLog(@"Index %d is %@", (int) _index, selected?@"selected":@"not selected");

    double duration = 0.7f;
    if(selected){
        [UIView animateWithDuration:duration animations:^{
            [_menuImageView setImage:[self SelectedMenuImage:_index]];
        }];
    }
    else {
        [UIView animateWithDuration:duration animations:^{
            [_menuImageView setImage:[self UnSelectedMenuImage:_index]];
        }];
    }
}

- (void)refreshSelected
{
    [_menuImageView setImage:[self SelectedMenuImage:_index]];
}

- (void)refreshUnSelected
{
    [_menuImageView setImage:[self UnSelectedMenuImage:_index]];
 
}


- (void)setIndex:(NSInteger)index
{
    _index = index;
    [_menuImageView setImage:[self UnSelectedMenuImage:index]];
}


- (UIImage*)SelectedMenuImage:(NSInteger)index
{
    UIImage *menuImage = nil;
    
    switch (index) {
        case 0: menuImage = [UIImage imageNamed:@"menu_facetab_selected"]; break;
        case 1: menuImage = [UIImage imageNamed:@"menu_unfacetab_selected"]; break;
        case 2: menuImage = [UIImage imageNamed:@"menu_camera_selected"]; break;
        case 3: menuImage = [UIImage imageNamed:@"menu_setting_selected"]; break;
        default: break;
    }
    
    return menuImage;
  
}

- (UIImage*)UnSelectedMenuImage:(NSInteger)index
{
    UIImage *menuImage = nil;
    
    switch (index) {
        case 0: menuImage = [UIImage imageNamed:@"menu_facetab"]; break;
        case 1: menuImage = [UIImage imageNamed:@"menu_unfacetab"]; break;
        case 2: menuImage = [UIImage imageNamed:@"menu_camera"]; break;
        case 3: menuImage = [UIImage imageNamed:@"menu_setting"]; break;
        default: break;
    }
    
    return menuImage;
}


@end
