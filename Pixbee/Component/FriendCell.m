//
//  FriendCell.m
//  Pixbee
//
//  Created by skplanet on 2013. 12. 3..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "FriendCell.h"

@interface FriendCell () {

}

// 기본상태
@property (strong, nonatomic) IBOutlet UIImageView *friendImage;
@property (strong, nonatomic) IBOutlet UILabel *friendName;

@end

@implementation FriendCell

@synthesize friendImage;
@synthesize friendName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateFriendCell:(NSDictionary *)friend {
    
    NSString *picurl = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];

    [self.friendImage setImageWithURL:[NSURL URLWithString:picurl]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // 사용자 이름
    [self.friendName setText:[friend objectForKey:@"name"]];
}

@end
