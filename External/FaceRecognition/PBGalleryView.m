//
//  PBGalleryView.m
//  Pixbee
//
//  Created by jaecheol kim on 4/11/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBGalleryView.h"

@implementation PBGalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.5;
        
        
        _photoAssets = [NSMutableArray array];
        
        
//        self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 56, 320, 400)];
        self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        self.carousel.backgroundColor = [UIColor greenColor];
        
        for (int i = 0; i < 100; i++)
        {
            [_photoAssets addObject:@(i)];
        }
        
        _carousel.type = iCarouselTypeLinear;
        _carousel.dataSource = self;
        _carousel.delegate = self;
        _carousel.pagingEnabled = YES;
        
        [self addSubview:self.carousel];

    }
    return self;
}

- (void)dealloc
{
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
}


#pragma mark -
#pragma mark iCarousel methods

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
    NSLog(@"carouselWillBeginScrollingAnimation");
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    // 여기가 맨 마지막 이벤트 임..
    NSLog(@"carouselDidEndScrollingAnimation / CurrentIndex = %d", (int)carousel.currentItemIndex);
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"didSelectItemAtIndex = %d", (int)index);
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    NSLog(@"currentItemIndex = %d", (int)carousel.currentItemIndex);
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [_photoAssets count];// [self.asset count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 400.0f)];
        view.backgroundColor = [UIColor yellowColor];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [_photoAssets[index] stringValue];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap: // Circle wrap
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.1f;
        }

        case iCarouselOptionFadeMin:
        {
            return -0.2;
        }
            
        case iCarouselOptionFadeMax:
        {
            return 0.2;
        }
            
        case iCarouselOptionFadeRange:
        {
            return 1.0;
        }
            
            
            
        default:
        {
            return value;
        }
    }
}

@end
