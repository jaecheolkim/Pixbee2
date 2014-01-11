//
//  PBAssetLibrary.h
//  Pixbee
//
//  Created by jaecheol kim on 11/30/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define AssetLib [PBAssetsLibrary sharedInstance]

@protocol PBAssetsLibraryDelegate;

@interface PBAssetsLibrary : NSObject

@property (nonatomic,assign) id<PBAssetsLibraryDelegate> delegate;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *totalAssets;
@property (nonatomic, strong) NSMutableArray *faceAssets;
@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic) int totalProcess;
@property (nonatomic) int currentProcess;
@property (nonatomic) int matchCount;
@property (nonatomic) BOOL faceProcessStop;

+(PBAssetsLibrary*)sharedInstance;


- (void)loadAssetGroup:(void (^)(NSArray *result))success
               failure:(void (^)(NSError *error))failure;

- (void)loadAssets:(ALAssetsGroup *)assetsGroup success:(void (^)(NSArray *result))success;


- (void)checkGeocode;

#pragma mark Album function
// 앨범사진 로컬 앨범DB로 동기화
- (void)syncAlbumToDB:(void (^)(NSArray *results))result;

// 사진 정보 분석해서 DB에 저장 [ Photos / Faces / UserPhotos ];
- (void)saveNewPhotoToDB:(ALAsset*)photoAsset user:(int)userID;

- (void)checkFacesFor:(int)UserID usingEnumerationBlock:(void (^)(NSDictionary *processInfo))enumerationBlock completion:(void (^)(BOOL finished))completion;

@end

@protocol PBAssetsLibraryDelegate <NSObject>

- (void)updateProgressUI:(NSNumber *)total currentProcess:(NSNumber *)currentprocess;
- (void)updatePhotoGallery:(ALAsset *)asset;

@end
