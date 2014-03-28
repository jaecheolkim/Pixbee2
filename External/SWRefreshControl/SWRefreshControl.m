//
//  SWRefreshControl.m
//  refresh test
//
//  Created by Simon Westerlund on 9/10/13.
//  Copyright (c) 2013 Simon Westerlund. All rights reserved.
//

#import "SWRefreshControl.h"

@implementation SWRefreshControl

- (void)beginRefreshing {
    // Only do this specific "hack" if super view is a collection view
    if ([[self superview] isKindOfClass:[UICollectionView class]]) {
        UICollectionView *superCollectionView = (UICollectionView *)[self superview];
        
        // If the user did change the content offset we do not want to animate a new one
        if (CGPointEqualToPoint([superCollectionView contentOffset], CGPointZero)) {
            
            // Set the new content offset based on UIRefreshControl height
            [superCollectionView setContentOffset:CGPointMake(0, -CGRectGetHeight([self frame])) animated:YES];
            
            // Call super after the animation is finished, all apple animations is .3 sec
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (0.3 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [super beginRefreshing];
            });
        } else {
            [super beginRefreshing];
        }
    } else {
        [super beginRefreshing];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    NSLog(@"Warning: setting background color on a UIRefreshControl is causing unexpected behavior");
}

@end
