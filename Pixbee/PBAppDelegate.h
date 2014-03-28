//
//  PBAppDelegate.h
//  Pixbee
//
//  Created by skplanet on 2013. 11. 29..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)goLoginView;
- (void)goMainView;
- (void)createParseUser:(NSDictionary*)userProfile;
@end
