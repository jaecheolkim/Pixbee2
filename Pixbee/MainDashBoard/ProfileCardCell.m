//
//  PlayingCardCell.m
//  LXRCVFL Example using Storyboard
//
//  Created by Stan Chang Khin Boon on 3/10/12.
//  Copyright (c) 2012 d--buzz. All rights reserved.
//

#import "ProfileCardCell.h"
#import "ProfileCard.h"

@implementation ProfileCardCell
//@synthesize profileCard;

- (void)setPlayingCard:(ProfileCard *)profileCard
{
    _profileCard = profileCard;
    _profileImageView.image = [UIImage imageNamed:@"AlbumButton"];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
   _profileImageView.alpha = highlighted ? 0.75f : 1.0f;
}

- (void)setSelected:(BOOL)selected
{
}

@end
