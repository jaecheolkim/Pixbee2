//
//  FBHelper.h
//  matchme
//
//  Created by jaecheol kim on 10/4/13.
//  Copyright (c) 2013 jaecheol kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

#define FBHELPER [FBHelper sharedInstance]

#define FB_APP_ID           @"206719339512526"
#define FB_APP_SECRET       @"7c2013eebeb4bb08a3e6ad0218d79616"

@protocol FBHelperDelegate;

@interface FBHelper : NSObject <FBLoginViewDelegate>
@property (nonatomic,assign) id<FBHelperDelegate> delegate;
@property (nonatomic,strong) id<FBGraphUser> loggedInUser;
@property (nonatomic,strong) NSArray *friends;

+ (FBHelper *)sharedInstance;

- (void)loadFBLoginView:(UIView *)_view ;
- (void)saveFriendList;
- (BOOL)loadFriendList;

@end

@protocol FBHelperDelegate <NSObject>

@optional
- (void)FBLogedInUser;
- (void)FBLoginFetchedUserInfo:(id<FBGraphUser>)user;
- (void)FBLoggedOutUser;
- (void)FBHandleError;

//친구 리스트를 다 받았을 때 위임되는 함수.
- (void)finishFriendLists:(NSArray*)friendList;

@end
