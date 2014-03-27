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
// 새로운 Unknown User 생성.
- (NSArray *)newUser;
// FB로그인 사용자용 newUser
- (int)newUserWithFBUser:(id<FBGraphUser>)user;
// Parse FB로그인 사용자용 newUser
- (int)newUserWithPFUser:(NSDictionary*)profile;

// Users 테이블 업데이트
// Param must inclue belows
// NSDictionary *params = @{ @"UserID" : @(UserID), ... };
// 'UserName' TEXT, 'GUID' TEXT, 'UserNick' TEXT, 'UserProfile' TEXT, 'fbID' TEXT, 'fbName' TEXT, 'fbProfile' TEXT,
// Ex) NSDictionary *params = @{ @"UserID" : @(UserID), @"UserName" : @"Test User" };
//[SQLManager updateUser:@{ @"UserID" : @(1), @"UserName" : @"Test User", @"UserProfile" : @"http://graph.facebook.com/100004326285149/picture?type=large" }];
- (NSArray *)updateUser:(NSDictionary*)params;

// 해당 UserID의 Users 데이터 모두 삭제.
// 해당 UserID의 FaceData 데이터 모두 삭제.
// 해당 UserID의 UserPhotos 데이터 모두 삭제.
- (BOOL)deleteUser:(int)UserID;

// 해당 User의 profile 이미지 저장하기
- (void)setUserProfileImage:(UIImage*)profileImage UserID:(int)UserID;
// 해당 User의 Profile 이미지 가져오기
- (UIImage *)getUserProfileImage:(int)UserID;

// 해당 User ID 가져오기.
- (int)getUserID:(NSString *)UserName;
// 해당 User Name 가져오기.
- (NSString*)getUserName:(int)UserID;
// 해당 User 정보 가져오기.
- (NSArray *)getUserInfo:(int)UserID;
// 모든 등록된 User 정보 가져오기
- (NSArray*)getAllUsers;
// 해당 User의 인식용 얼굴 데이터 모두 삭제.
- (BOOL)deleteAllFacesForUserID:(int)UserID;
// User의 칼라 정보 가져오기
- (UIColor*)getUserColor:(int)colorID alpha:(float)alpha;

#pragma mark FaceData Table
// 해당 User의 인식용 얼굴 데이터 개수 조사.

- (NSInteger)numberOfFacesForUserID:(int)UserID;
- (NSArray*)getTrainModels;
- (NSArray*)getTrainModelsForID:(int)UserID;
- (void)addTrainModelForUserID:(int)UserID withFaceData:(NSData*)FaceData;
//테스트용 사용자별 얼굴 리스트
- (NSArray*)getUsersFaces;

#pragma mark Photos Table
- (int)newPhotoWith:(ALAsset *)asset withGroupAssetURL:(NSString*)groupAssetURL;
- (NSArray*)getGroupPhotos:(NSString*)GroupURL filter:(BOOL)all;
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
- (NSMutableArray*)getAllUserPhotos;
- (NSDictionary*)getUserPhotos:(int)UserID;
- (BOOL)deleteUserPhoto:(int)UserID withPhoto:(int)PhotoID;

// 사진 촬영 후 해당 사진을 UserPhotos에 저장.
// 사진 정보 분석해서 DB에 저장 [ Photos / Faces / UserPhotos ];
- (void)saveNewUserPhotoToDB:(ALAsset*)photoAsset users:(NSArray*)users;



@end
