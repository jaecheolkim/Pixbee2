//
//  main.m
//  Pixbee
//
//  Created by skplanet on 2013. 11. 29..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBAppDelegate.h"

#import <PulseSDK/PulseSDK.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        [PulseSDK monitor:@"mvHc2b5kNXtraC0V8dRYEuqSaukemU8L"];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PBAppDelegate class]));
    }
}
