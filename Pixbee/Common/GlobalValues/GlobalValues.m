//
//  SharedValues.m
//  PuddingCamera
//
//  Created by JCKIM154 on 11. 3. 22..
//  Copyright 2011 private. All rights reserved.
//

#import <objc/runtime.h>
#import "GlobalValues.h"

#define  KEY_USERID                     @"userID"
#define  KEY_USERNAME                   @"userName"
#define  KEY_LASTASSETURL               @"lastAssetURL"
#define  KEY_AUTOALBUMSCANSETTING       @"autoAlbumScanSetting"
#define  KEY_PUSHNOTIFICATIONSETTING    @"pushNotificationSetting"
#define  KEY_TESTMODESETTING            @"testModeSetting"
#define  KEY_APPVERSION                 @"appVersion"
#define  KEY_CURRENT_TOTAL_PROCESS      @"keyCurrnetTotalProcess"
#define  KEY_LAST_TOTAL_ASSET           @"keyLastTotalAsset"

@interface GlobalValues ()
@end

@implementation GlobalValues

#pragma mark
#pragma mark -- Singleton Unit

// 초기화.
- (id)init {
	if ((self = [super init])) {
        
	}
	return self;
}

+ (GlobalValues *)sharedInstance {
    static dispatch_once_t pred;
    static GlobalValues *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GlobalValues alloc] init];
    });
    return sharedInstance;
}

#pragma mark -
#pragma mark  Public Support Methods

- (void)setUserName:(NSString *)userName
{
    [self writeObjectToDefault:userName withKey:KEY_USERNAME];
}


- (NSString *)userName
{
    
    return [self readObjectFromDefault:KEY_USERNAME];
}

- (void)setUserID:(int)UserID
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",UserID] withKey:KEY_USERID];
}

- (int)UserID
{
    return [[self readObjectFromDefault:KEY_USERID] intValue];
}

- (void)setLastAssetURL:(NSString *)lastAssetURL
{
    [self writeObjectToDefault:lastAssetURL withKey:KEY_LASTASSETURL];
}


- (NSString *)lastAssetURL
{
    
    return [self readObjectFromDefault:KEY_LASTASSETURL];
}

- (void)setCurrentTotalAssetProcess:(int)currentTotalAssetProcess
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",currentTotalAssetProcess] withKey:KEY_CURRENT_TOTAL_PROCESS];
}

- (int)currentTotalAssetProcess
{
    return [[self readObjectFromDefault:KEY_CURRENT_TOTAL_PROCESS] intValue];
}

- (void)setLastTotalAssetCount:(int)lastTotalAssetCount
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",lastTotalAssetCount] withKey:KEY_LAST_TOTAL_ASSET];
}

- (int)lastTotalAssetCount
{
    return [[self readObjectFromDefault:KEY_LAST_TOTAL_ASSET] intValue];
}



//@property (nonatomic, strong) NSString* appVersion;

- (void)setAppVersion:(NSString *)appVersion
{
    [self writeObjectToDefault:appVersion withKey:KEY_APPVERSION];
}


- (NSString *)appVersion
{
    
    return [self readObjectFromDefault:KEY_APPVERSION];
}


- (void)writeObjectToDefault:(id)idValue withKey:(NSString *)strKey
{
	[[NSUserDefaults standardUserDefaults] setObject:idValue forKey:strKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)readObjectFromDefault:(NSString *)strKey
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
}

- (void)setAutoAlbumScanSetting:(int)autoAlbumScanSetting
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",autoAlbumScanSetting] withKey:KEY_AUTOALBUMSCANSETTING];
}

- (int)autoAlbumScanSetting
{
    return [[self readObjectFromDefault:KEY_AUTOALBUMSCANSETTING] intValue];
}

- (void)setPushNotificationSetting:(int)pushNotificationSetting
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",pushNotificationSetting] withKey:KEY_PUSHNOTIFICATIONSETTING];
}

- (int)pushNotificationSetting
{
    return [[self readObjectFromDefault:KEY_PUSHNOTIFICATIONSETTING] intValue];
}


- (void)setTestMode:(int)testMode
{
    [self writeObjectToDefault:[NSString stringWithFormat:@"%d",testMode] withKey:KEY_TESTMODESETTING];
}

- (int)testMode
{
    return [[self readObjectFromDefault:KEY_TESTMODESETTING] intValue];
}


@end
