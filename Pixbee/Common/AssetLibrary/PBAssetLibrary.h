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
@property (nonatomic, strong) ALAssetsGroup *currentAssetGroup;
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

// 앨범 Asset 전부 뒤져서 얼굴 정보 찾아줌..
- (void)checkFacesFor:(int)UserID usingEnumerationBlock:(void (^)(NSDictionary *processInfo))enumerationBlock completion:(void (^)(BOOL finished))completion;

// 하나의 Asset에서 얼굴정보 찾아줌.
- (NSArray*)getFaceData:(ALAsset*)photoAsset;


@end

@protocol PBAssetsLibraryDelegate <NSObject>

- (void)updateProgressUI:(NSNumber *)total currentProcess:(NSNumber *)currentprocess;
- (void)updatePhotoGallery:(ALAsset *)asset;

@end
