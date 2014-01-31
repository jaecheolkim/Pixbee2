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



@end
