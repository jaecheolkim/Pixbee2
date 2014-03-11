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

//#define FB_APP_ID           @"244663102372990"
//#define FB_APP_SECRET       @"b5061c376a8a2ee7251cb459c042f7ec"

@protocol FBHelperDelegate;

@interface FBHelper : NSObject <FBLoginViewDelegate>
@property (nonatomic,assign) id<FBHelperDelegate> delegate;
@property (nonatomic,strong) id<FBGraphUser> loggedInUser;
@property (nonatomic,strong) NSArray *friends;

+ (FBHelper *)sharedInstance;

- (void)openFBSession;
- (void)doFBLogin;
- (void)doFBLogout;
- (void)FBSessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)FBUserLoggedIn;
- (void)FBUserLoggedOut;
- (void)saveUserInfo:(void (^)(NSDictionary *userProfile))success
             failure:(void (^)(NSError *error))failure;


- (void)loadFBLoginView:(UIView *)_view ;



- (void)saveFriendList;
- (BOOL)loadFriendList;
- (void)getFBFriend;

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
