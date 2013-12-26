//
//  PBSQLiteManager.h
//  Pixbee
//
//  Created by jaecheol kim on 11/30/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "sqlite3.h"
#import "FBHelper.h"

#define SQLManager [PBSQLiteManager sharedInstance]

enum errorCodes {
	kDBNotExists,
	kDBFailAtOpen,
	kDBFailAtCreate,
	kDBErrorQuery,
	kDBFailAtClose
};

@interface PBSQLiteManager : NSObject
+(PBSQLiteManager*)sharedInstance;


#pragma mark SQLite Operations
- (sqlite3 *)getDBContext;
- (void)initDataBase;
- (NSError*)doQuery:(NSString *)sql;
- (NSError*)doUpdateQuery:(NSString *)sql withParams:(NSArray *)params;
- (NSArray*)getRowsForQuery:(NSString *)sql;
- (NSString*)getDatabaseDump;

#pragma mark Users Table
// 새로운 User 추가.
- (int)newUserWithName:(NSString *)UserName;
- (int)newUserWithFBUser:(id<FBGraphUser>)user;
// 해당 User ID 가져오기.
- (int)getUserID:(NSString *)UserName;
// 해당 User Name 가져오기.
- (NSString*)getUserName:(int)UserID;
// 해당 User 정보 가져오기.
- (NSArray *)getUserInfo:(NSString *)UserName;
// 모든 등록된 User 정보 가져오기
- (NSArray*)getAllUsers;
// 해당 User의 인식용 얼굴 데이터 모두 삭제.
- (BOOL)forgetAllFacesForUserID:(int)UserID;

#pragma mark FaceData Table
// 해당 User의 인식용 얼굴 데이터 개수 조사.
- (NSInteger)numberOfFacesForUserID:(int)UserID;
- (NSArray*)getTrainModels;
- (void)setTrainModelForUserID:(int)UserID withFaceData:(NSData*)FaceData;

#pragma mark Photos Table
- (int)newPhotoWith:(ALAsset *)asset withGroupAssetURL:(NSString*)groupAssetURL;
- (NSArray*)getAllPhotos;
- (NSArray*)getPhoto:(NSString *)assetURL;
- (BOOL)deletePhoto:(int)PhotoID;

#pragma mark Faces Table
- (int)newFaceWith:(int)PhotoID withFeature:(CIFaceFeature *)face withInfo:(NSDictionary*)info;
- (NSArray*)getAllFaces;
- (NSArray*)getFace:(int)PhotoID;
- (BOOL)deleteFace:(int)FaceNo;

#pragma mark UserPhotos Table
- (int)newUserPhotosWith:(int)UserID withPhoto:(int)PhotoID withFace:(int)FaceNo;
- (NSArray*)getAllUserPhotos;
- (NSArray*)getUserPhotos:(int)UserID;
- (BOOL)deleteUserPhoto:(int)UserID withPhoto:(int)PhotoID;





@end
