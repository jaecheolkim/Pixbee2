//
//  GlobalValues.h
//  PuddingCamera
//
//  Created by JCKIM154 on 11. 3. 22..
//  Copyright 2011 private. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GlobalValue [GlobalValues sharedInstance]

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline id ObjectOrNull(id object)
{
    return object ?: [NSNull null];
}


@interface GlobalValues : NSObject
@property (nonatomic, strong) NSString* userName;
@property (nonatomic) int UserID;
@property (nonatomic, strong) NSString* lastAssetURL;

+ (GlobalValues*) sharedInstance;


@end

