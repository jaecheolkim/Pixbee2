//
//  GlobalValues.h
//  PuddingCamera
//
//  Created by JCKIM154 on 11. 3. 22..
//  Copyright 2011 private. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GlobalValue [GlobalValues sharedInstance]

@interface GlobalValues : NSObject
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* lastAssetURL;

+ (GlobalValues*) sharedInstance;


@end

