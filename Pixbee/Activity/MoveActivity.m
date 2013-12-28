//
//  MoveActivity.m
//  Pixbee
//
//  Created by skplanet on 2013. 12. 28..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "MoveActivity.h"

@implementation MoveActivity

// Return the name that should be displayed below the icon in the sharing menu
- (NSString *)activityTitle {
    return @"Move";
}

// Return the string that uniquely identifies this activity type
- (NSString *)activityType {
    return @"com.pixbee.moveSharing";
}

// Return the image that will be displayed  as an icon in the sharing menu
- (UIImage *)activityImage {
    return [UIImage imageNamed:@"move.png"];
}

// allow this activity to be performed with any activity items
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {

}

// initiate the sharing process. First we will need to login
- (void)performActivity {
    NSLog(@"Move performActivity");
}

// activity must call this when activity is finished. can be called on any thread
- (void)activityDidFinish:(BOOL)completed {
    NSLog(@"Move activityDidFinish");
}


@end
