//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSURL *assetURL, NSError* error);
typedef void(^FailurBlock)(NSError* error);

@interface ALAssetsLibrary(CustomPhotoAlbum)

// Add new Album group
-(void)newAssetGroup:(NSString*)albumName withSuccess:(void (^)(BOOL success))success withFailur:(FailurBlock)failur;

// Add new Photo to custom album
-(void)saveImageData:(NSData *)imageData metadata:(NSDictionary *)metadata toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailurBlock:(FailurBlock)failurBlock;

@end