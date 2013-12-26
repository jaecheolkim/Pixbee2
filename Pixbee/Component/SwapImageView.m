//
//  SwapImageView.m
//  Test
//
//  Created by skplanet on 2013. 12. 13..
//  Copyright (c) 2013년 test. All rights reserved.
//

#import "SwapImageView.h"

@implementation SwapImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *inv = [[UIImageView alloc] initWithFrame:self.bounds];
        inv.backgroundColor = [UIColor clearColor];
        
        UIImageView *outv = [[UIImageView alloc] initWithFrame:self.bounds];
        outv.backgroundColor = [UIColor clearColor];
        
        [self addSubview:outv];
        [self addSubview:inv];
      
        self.inView = inv;
        self.outView = outv;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)swapImage:(UIImage *)image {
    [self swapImage:image reverse:NO];
}

- (void)swapImage:(UIImage *)image reverse:(BOOL)reverse {
    
    self.inView.contentMode = UIViewContentModeCenter;
    if (self.inView.bounds.size.width < image.size.width ||
        self.inView.bounds.size.height < image.size.height) {
        self.inView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [self.inView setImage:image];
    
    if (reverse) {
        self.inView.alpha = 0.5;
        [self.inView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.inView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.inView.transform = CGAffineTransformIdentity;
                             self.inView.alpha = 1.0;
                             
                             [self.outView setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
                             self.outView.alpha = 0.5;
                         }
                         completion:^(BOOL finished){
                             
                             self.outView.contentMode = self.inView.contentMode;
                             self.outView.alpha = self.inView.alpha;
                             [self.outView setImage:image];
                             [self.outView setFrame:self.inView.frame];
                             
                             [self.inView setImage:nil];
                             [self.inView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                        }];
    }
    else {
        self.inView.alpha = 1.0;
        [self.inView setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        [self.outView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.outView.transform = CGAffineTransformMakeScale(0.7, 0.7);
                             self.outView.alpha = 0.0;
                             
                             self.inView.alpha = 1.0;
                             [self.inView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                             self.outView.transform = CGAffineTransformIdentity;
                             self.outView.contentMode = self.inView.contentMode;
                             self.outView.alpha = self.inView.alpha;
                             [self.outView setImage:image];
                             [self.outView setFrame:self.inView.frame];
                             
                             [self.inView setImage:nil];
                             [self.inView setFrame:CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
                             
                             
                         }];

    }
}

@end
