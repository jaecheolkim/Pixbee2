//
//  PBAssetLibrary.m
//  Pixbee
//
//  Created by jaecheol kim on 11/30/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "PBAssetLibrary.h"
#import "PBFaceLib.h"


@interface PBAssetsLibrary ()
{
    //CIDetector *detector;
    CIDetector *cFaceDetector;
    BOOL isFaceRecRedy;
    BOOL isSyncPixbeeAlbum;
    
    ALAssetsGroup *PixbeeAssetGroup;
}
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation PBAssetsLibrary

@synthesize delegate;
@synthesize faceProcessStop;

+(PBAssetsLibrary*)sharedInstance
{
    static PBAssetsLibrary* assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[PBAssetsLibrary alloc] init];
    });
    return assetsLibrary;
}

-(id)init
{
    self = [super init];
    if (self){
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _faceAssets = [NSMutableArray array];
        _totalAssets = [NSMutableArray array];
        _locationArray = [NSMutableArray array];
        _geocoder = [[CLGeocoder alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAssetChangedNotifiation:) name:ALAssetsLibraryChangedNotification object:_assetsLibrary];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

#pragma mark - Notification handlers
//In iOS 6.0 and later, the user information dictionary describes what changed:
//If the user information dictionary is nil, reload all assets and asset groups.
//If the user information dictionary an empty dictionary, there is no need to reload assets and asset groups.
//If the user information dictionary is not empty, reload the effected assets and asset groups. For the keys used, see “Notification Keys.”
//NSString * const ALAssetLibraryUpdatedAssetsKey;
//NSString * const ALAssetLibraryInsertedAssetGroupsKey;
//NSString * const ALAssetLibraryUpdatedAssetGroupsKey;
//NSString * const ALAssetLibraryDeletedAssetGroupsKey;

- (void) handleAssetChangedNotifiation:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
   if(userInfo != nil && !isSyncPixbeeAlbum) {
       
#warning 어플 실행 중 혹은 실행 시 마다 새로운 카메라롤 새로운 사진이 있을 때 Pixbee 앨범에 동기화 !!!
        NSLog(@"userInfo = %@", userInfo);
       
//        NSString *insertedGroupURLs = [userInfo objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
//       if(!IsEmpty(insertedGroupURLs)){
//           NSURL *assetURL = [NSURL URLWithString:insertedGroupURLs];
//           if (assetURL) {
//               [self.assetsLibrary groupForURL:assetURL resultBlock:^(ALAssetsGroup *group) {
//                   self.currentAssetGroup = group;
//               } failureBlock:^(NSError *error) {
//                   
//               }];
//           }
//       }
//        NSSet *insertedGroupURLs = [[notification userInfo] objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
//        NSURL *assetURL = [insertedGroupURLs anyObject];
//        if (assetURL) {
//            [self.assetsLibrary groupForURL:assetURL resultBlock:^(ALAssetsGroup *group) {
//                self.currentAssetGroup = group;
//            } failureBlock:^(NSError *error) {
//                
//            }];
//        }

    }
    else if (userInfo == nil) {
        NSLog(@"userInfo == nil");
    }
}


- (void)checkPixbeeAlbum
{
    
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    BOOL isPixBeeAlbumCreated = [userDefaults boolForKey:@"CREATEDPIXBEEALBUM"];
    //
    //    if(!isPixBeeAlbumCreated){
    NSString *albumName = @"Pixbee";
    [self.assetsLibrary newAssetGroup:albumName withSuccess:^(ALAssetsGroup *group) {
        
        PixbeeAssetGroup = group;
        NSLog(@"======= Success create Pixbee Album !!!");
        //            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //            [userDefaults setBool:YES forKey:@"CREATEDPIXBEEALBUM"];
        //            [userDefaults synchronize];
    } withFailur:^(NSError *error) {
        //            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //            [userDefaults setBool:NO forKey:@"CREATEDPIXBEEALBUM"];
        //            [userDefaults synchronize];
        
        PixbeeAssetGroup = nil;
        NSLog(@"======= Failed create Pixbee Album = %@", error);
    }];
    //    }
    
    
}


- (void)checkNewPhoto
{
    [AssetLib checkPixbeeAlbum];
    
    //Check new photos and go main dashboard
    NSLog(@"========================= >>>>>>>>  START checkNewPhoto");
    [AssetLib syncAlbumToDB:^(NSArray *result) {
        //NSLog(@"Result = %@", result);
        if(result.count > 0  && result != nil){
            NSArray *lastDistance = [result objectAtIndex:result.count-1];
            ALAsset *lastAsset = [[lastDistance objectAtIndex:lastDistance.count-1] objectForKey:@"Asset"];
            NSURL *assetURL = [lastAsset valueForProperty:ALAssetPropertyAssetURL];
            
            //NSLog(@"Last Asset URL = %@", assetURL.absoluteString);
            
            if(![GlobalValue.lastAssetURL isEqualToString:assetURL.absoluteString]) {
                //New Asset found
                
                NSLog(@" ============== new asset found!");
                
                
            }
            //NSLog(@"Locations : %@", [AssetLib locationArray]);
            //[AssetLib checkGeocode];
            GlobalValue.lastAssetURL = assetURL.absoluteString;
        }
        
        NSLog(@"========================= >>>>>>>>  END checkNewPhoto");
        
    }];
}

- (void)syncPixbeeAlbum:(void (^)(float percent))enumerationBlock completion:(void (^)(BOOL finished))completion
{

    
    NSLog(@"Check...syncPixbeeAlbum ");
    
    isSyncPixbeeAlbum = YES;
    
    int lastTotalAssetCount = [GlobalValue lastTotalAssetCount];
    int currentTotalAssetProcess = [GlobalValue currentTotalAssetProcess];
    
    
    if(!cFaceDetector)
    {
        NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @(NO) };
        cFaceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            
            NSUInteger type = ALAssetsGroupSavedPhotos; // |  ALAssetsGroupFaces | ALAssetsGroupPhotoStream ;
            
            [self.assetsLibrary enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop)
             {
                 if(nil!=group)
                 {
                     [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                     
                     
                     __block NSInteger numberOfAssets = group.numberOfAssets;
                     
                     __block NSInteger numberOfPixbeeAssets = PixbeeAssetGroup.numberOfAssets;
                     
                     // 현재 총 어셋 갯수와 최종 저장된 총 어셋 갯수 비교해서 틀리면 동기화.
                     if(lastTotalAssetCount != numberOfAssets ||
                        currentTotalAssetProcess < numberOfAssets - 1 ||
                        numberOfPixbeeAssets < 1)
                     {
                         //아직 동기화가 안되었으니 동기화 해야 함.
                         NSLog(@"Start...syncPixbeeAlbum ");

                         
                         NSString *GroupName = [group valueForProperty:ALAssetsGroupPropertyName];
                         
                         if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos)
                         {
                             
                             if(![GroupName isEqualToString:@"Pixbee"])
                             {
                                 [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                     if(result != NULL && currentTotalAssetProcess < index) {
                                         
                                         CGImageRef cgImage = [result aspectRatioThumbnail];
                                         CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
                                         NSArray *fs = [cFaceDetector featuresInImage:ciImage];
                                         
                                         if(!IsEmpty(fs)) {
                                             // 신규 포토 저장.
                                             // Save DB. [Photos] 얼굴이 검출된 사진만 Photos Table에 저장.
                                             NSString *GroupURL = nil;
                                             if(PixbeeAssetGroup) GroupURL = [PixbeeAssetGroup valueForProperty:ALAssetsGroupPropertyURL];
                                             
                                             int PhotoID = [SQLManager newPhotoWith:result withGroupAssetURL:GroupURL];
                                             
                                             NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                                             
                                             [self.assetsLibrary addAssetURL:assetURL toAlbum:@"Pixbee" withCompletionBlock:^(NSURL *assetURL, NSError *error) {
                                                 
                                             } withFailurBlock:^(NSError *error) {
                                                 
                                             }];
                                             
                                         }
                                         
                                         [GlobalValue setCurrentTotalAssetProcess:(int)index];
                                         
                                         
                                         //dispatch_async(dispatch_get_main_queue(), ^{
                                         //NSLog(@" %d / %d", index, numberOfAssets);
                                         enumerationBlock((float)index / (float)numberOfAssets);
                                         //});
                                         
                                         if(index == numberOfAssets-1){
                                             completion(YES);
                                             NSLog(@"End...syncPixbeeAlbum = %d", (int)numberOfAssets);
                                             

                                             
                                         }
                                     }
                                     //assetCounter++;
                                 }];
                             }
                             
                         }
                         
                     }
                     
                     // 마지막 에셋 개수 저장하기
                     [GlobalValue setLastTotalAssetCount:(int)numberOfAssets];
                     
                 }
                 
                 isSyncPixbeeAlbum = NO;
             } failureBlock:^(NSError *error) {
                 
                 isSyncPixbeeAlbum = NO;
                 NSLog(@"block Failed!");
             }];
            
        }
    });
    
    
//    if(lastTotalAssetCount == 0 || currentTotalAssetProcess != lastTotalAssetCount - 1)
//    {
//        //아직 동기화가 안되었으니 동기화 해야 함.
    


    
//    }
//    else if(currentTotalAssetProcess == lastTotalAssetCount - 1) {
//        // 동기화가 되었음.
//
//
//
//    }
    
}





-(void) loadAssetGroup:(void (^)(NSArray *result))success
               failure:(void (^)(NSError *error))failure
{
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        NSLog(@"AssetLibrary Error : %@", errorMessage);
        
        failure(error);
        
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
        	// 카메라롤만 검색하기로 정책 변경.
        	NSString *GroupName = [group valueForProperty:ALAssetsGroupPropertyName];
        	NSLog(@"GroupName : %@", GroupName);
        	if([GroupName isEqualToString:@"Camera Roll"]){
        		[assetGroups addObject:group];
        	}
            
            //NSLog(@"group : %@", assetGroups);
        }
        else
        {
            //TODO
            // Notification Clean Action for there is some change.
            success(assetGroups);
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll;//ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
}

- (void)loadAssets:(ALAssetsGroup *)assetsGroup success:(void (^)(NSArray *result))success
{
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [assets addObject:result];
            
        } else {
            success(assets);
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [assetsGroup setAssetsFilter:onlyPhotosFilter];
    [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
}


#pragma mark Album function




//새로운 Group DB 추가.
- (int)newGroupToDBWith:(ALAssetsGroup *)assetGroup
{
    int resultVal = 1;
    NSString *GroupURL = [assetGroup valueForProperty:ALAssetsGroupPropertyURL];
    NSString *GroupName = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
    int AssetCount = (int)assetGroup.numberOfAssets;

//    NSLog(@"=== Result GroupURL %@ ", [assetGroup valueForProperty:ALAssetsGroupPropertyURL]);
//    NSLog(@"=== Result GroupName %@ ", [assetGroup valueForProperty:ALAssetsGroupPropertyName]);
//    NSLog(@"=== Result GroupType %@ ", [assetGroup valueForProperty:ALAssetsGroupPropertyType]);
//    NSLog(@"=== Result GroupCount %d ", (int)assetGroup.numberOfAssets);

    NSString *query = [NSString stringWithFormat:@"SELECT AssetCount FROM Groups WHERE GroupURL = '%@';", GroupURL];
    NSArray *result = [SQLManager getRowsForQuery:query];
    
    if([result count]){ //Delete
        
        int oldAssetCount = [[[result objectAtIndex:0] objectForKey:@"AssetCount"] intValue];
        NSLog(@"AssetCount = %d / oldAssetCount = %d ", AssetCount, oldAssetCount);

        
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM Groups WHERE GroupURL = '%@';", GroupURL];
        NSError *error = [[PBSQLiteManager sharedInstance] doQuery:sqlStr];
        if (error != nil) {
            NSLog(@"Error: %@",[error localizedDescription]);
            resultVal = 0;
        }
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO Groups (GroupURL, GroupName, AssetCount) VALUES ('%@', '%@', '%d');", GroupURL, GroupName, AssetCount];
    NSError *error = [[PBSQLiteManager sharedInstance] doQuery:sqlStr];
    if (error != nil) {
        NSLog(@"Error: %@",[error localizedDescription]);
        resultVal = 0;
    }

    return resultVal;
}

//새로운 Group DB 추가.
- (NSString *)getDate:(NSDate *)date
{
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:usLocale];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];//@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    
    return [formatter stringFromDate:date];
}



- (void)assetGroupsToDB:(NSArray *)resultGropus
{
	for(ALAssetsGroup *assetGroup in resultGropus){
		[[PBAssetsLibrary sharedInstance] newGroupToDBWith:assetGroup];
	}
}

- (void)loadAssets2:(ALAssetsGroup *)assetsGroup success:(void (^)(NSMutableArray *result))success
{
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    __block NSMutableArray *subAssets = nil;
    
    __block int locationGroup = 0;
    __block CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    __block NSDate *oldDate;
    __block BOOL addLocation = NO;
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result)
        {
            
            
            //ALAssetPropertyLocation : CLLocation
            //ALAssetPropertyDate : NSDate
            
            NSString *filter = [[NSUserDefaults standardUserDefaults] objectForKey:@"ALLPHOTO_FILTER"];
            //if (filter == nil || [filter isEqualToString:@""] || [filter isEqualToString:@"DISTANCE"]) {
            
            if (IsEmpty(filter) || [filter isEqualToString:@"DISTANCE"])
            {
                CLLocation *newLocation = [result valueForProperty:ALAssetPropertyLocation];
                if(newLocation != nil){
                    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
                    
                    NSNumber *distanceN = [[NSUserDefaults standardUserDefaults] objectForKey:@"DISTANCE"];
                    int dis = 1000;
                    if (distanceN) {
                        if ([distanceN intValue] > 0){
                            dis = [distanceN intValue];
                        }
                    }
                    
                    if(distance > dis){ //1km 반경이 넘으면 주소 refresh
                        
                        if (subAssets != nil) {
                            [assets addObject:subAssets];
                        }
                        
                        oldLocation = newLocation;
                        subAssets = [[NSMutableArray alloc] init];
                        [_locationArray addObject:newLocation];
                        locationGroup++;
                        
                        //[self reverseGeocode:newLocation group:locationGroup];
                    }
                    else {
                        
                    }
                    
                    NSLog(@"LocationGroup : %d || Distance : %f || NEW Longitude = %f / Latitude = %f || OLD Longitude = %f / Latitude = %f ",
                          locationGroup, distance, newLocation.coordinate.longitude, newLocation.coordinate.latitude, oldLocation.coordinate.longitude, oldLocation.coordinate.latitude );
                }
                [subAssets addObject:@{@"Asset":result, @"GroupURL":[assetsGroup valueForProperty:ALAssetsGroupPropertyURL]} ];
            }
            else {
                NSDate *date = [result valueForProperty:ALAssetPropertyDate];
                CLLocation *newLocation = [result valueForProperty:ALAssetPropertyLocation];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *weekdayComponent = [calendar components:(NSDayCalendarUnit | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
                
                NSInteger year = [weekdayComponent year];
                NSInteger month = [weekdayComponent month];
                NSInteger weekOfYear = [weekdayComponent weekOfYear];
                NSInteger day = [weekdayComponent day];
                
                if(date != nil){
                    
                    NSInteger oday = -1;
                    NSInteger oweekOfYear = -1;
                    NSInteger omonth = -1;
                    NSInteger oyear = -1;


                    if (oldDate) {
                        NSDateComponents *weekdayComponent1 = [calendar components:(NSDayCalendarUnit | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:oldDate];
                        
                        oyear = [weekdayComponent1 year];
                        omonth = [weekdayComponent1 month];
                        oweekOfYear = [weekdayComponent1 weekOfYear];
                        oday = [weekdayComponent1 day];
                    }
                    
                    if ([filter isEqualToString:@"DAY"]) {
                        if(day != oday || month != omonth || year != oyear){
                            
                            if (subAssets != nil) {
                                [assets addObject:subAssets];
                            }
                            
                            oldDate = date;
                            subAssets = [[NSMutableArray alloc] init];
                            if (addLocation) {
                                [_locationArray addObject:@""];
                            }
                            addLocation = YES;
                            locationGroup++;
                        }
                    }
                    else if ([filter isEqualToString:@"WEEK"]) {
                        if(weekOfYear != oweekOfYear){
                            
                            if (subAssets != nil) {
                                [assets addObject:subAssets];
                            }
                            
                            oldDate = date;
                            subAssets = [[NSMutableArray alloc] init];
                            if (addLocation) {
                                [_locationArray addObject:@""];
                            }
                            addLocation = YES;
                            locationGroup++;
                        }
                    }
                    else if ([filter isEqualToString:@"MONTH"]) {
                        if(month != omonth || year != oyear){
                            
                            if (subAssets != nil) {
                                [assets addObject:subAssets];
                            }
                            
                            oldDate = date;
                            subAssets = [[NSMutableArray alloc] init];
                            if (addLocation) {
                                [_locationArray addObject:@""];
                            }
                            addLocation = YES;
                            locationGroup++;
                        }
                    }
                    else if ([filter isEqualToString:@"YEAR"]) {
                        if(year != oyear){
                            
                            if (subAssets != nil) {
                                [assets addObject:subAssets];
                            }
                            
                            oldDate = date;
                            subAssets = [[NSMutableArray alloc] init];
                            if (addLocation) {
                                [_locationArray addObject:@""];
                            }
                            addLocation = YES;
                            locationGroup++;
                        }
                    }

                                        
                    if (addLocation) {
                        if (newLocation != nil) {
                            [_locationArray addObject:newLocation];
                            addLocation = NO;
                        }
                    }
                }
                [subAssets addObject:@{@"Asset":result, @"GroupURL":[assetsGroup valueForProperty:ALAssetsGroupPropertyURL]} ];

            }
            
        }
        else {
            if (![assets containsObject:subAssets]) {
                [assets addObject:subAssets];
                
                if (addLocation) {
                    [_locationArray addObject:@""];
                }

            }
            success(assets);
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [assetsGroup setAssetsFilter:onlyPhotosFilter];
    [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
}


- (void)loadAssets3:(NSArray*)assetsGroups success:(void (^)(NSMutableArray *result))success
{
    __block int count = 0;
    __block int groupCont = (int)[assetsGroups count];
    __block NSMutableArray *_tmpAssets = [NSMutableArray array];
    
    for(ALAssetsGroup *assetGroup in assetsGroups){
        [[PBAssetsLibrary sharedInstance] loadAssets2:assetGroup success:^(NSMutableArray *resultAssets) { //각 그룹별 Assets  뽑아냄.
            [_tmpAssets addObjectsFromArray:resultAssets];
            count++;
            if(count == groupCont){
                success(_tmpAssets);
            }
        }];
        
    }
}

// 앨범사진 로컬 앨범DB로 동기화
- (void)syncAlbumToDB:(void (^)(NSArray *results))result
{
    [[PBAssetsLibrary sharedInstance] loadAssetGroup: ^(NSArray *resultGropus)
     {
         NSLog(@"=== Result Groups : %@", resultGropus);
         [[PBAssetsLibrary sharedInstance] assetGroupsToDB:resultGropus]; //그룹 리스트 DB로 저장/

         [[PBAssetsLibrary sharedInstance] loadAssets3:resultGropus success:^(NSMutableArray *resultAssets) { //각 그룹별 Assets  뽑아냄.
 
             [_totalAssets addObjectsFromArray:resultAssets];
             
             int count = 0;
             for (NSArray *array in _totalAssets) {
                 count = count + [array count];
             }
             
             result(resultAssets);

         }];

     }
     failure: ^(NSError *err)
     {
     }];
}

- (NSArray*)getFaceData:(ALAsset*)photoAsset
{
    CGImageRef cgImage = [photoAsset aspectRatioThumbnail];
    CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
    
    NSArray *fs = [FaceLib detectFace:ciImage options:nil];

    NSMutableArray *result = [NSMutableArray array];
    for(CIFaceFeature *face in fs){
        NSDictionary *faceDic = [FaceLib getFaceData:ciImage feature:face];
        [result addObject:faceDic];
    }

    return result;
}
 



- (void)checkFace:(int)UserID
{
    AssetLib.faceProcessStop = NO;
    
    [AssetLib checkFacesFor:UserID
      usingEnumerationBlock:^(NSDictionary *processInfo) {
          dispatch_async(dispatch_get_main_queue(), ^{
              [[NSNotificationCenter defaultCenter] postNotificationName:@"AssetCheckFacesEnumerationEvent"
                                                                  object:self
                                                                userInfo:processInfo];
          });
          
      }
     
                 completion:^(BOOL finished){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"AssetCheckFacesFinishedEvent"
                                                                             object:self
                                                                           userInfo:nil];
                         
                     });
                     
                 }
     ];
}

- (void)checkFacesFor:(int)UserID usingEnumerationBlock:(void (^)(NSDictionary *processInfo))enumerationBlock completion:(void (^)(BOOL finished))completion {
    NSLog(@"Start...");
    
    if(IsEmpty(_totalAssets)) return;
    
    //_totalProcess = (int)[_totalAssets count];
    
    int count = 0;
    for (NSArray *array in _totalAssets) {
        count = count + (int)[array count];
    }
    _totalProcess = count;
    
    
    _currentProcess = 0;
    _matchCount = 0;
    
    if(!isFaceRecRedy){
        //[FaceLib initDetector:CIDetectorAccuracyLow Tacking:NO];
        
        NSArray *trainModel = [SQLManager getTrainModelsForID:UserID];
        
        if(!IsEmpty(trainModel)){
            isFaceRecRedy = [FaceLib initRecognizer:LBPHFaceRecognizer models:trainModel];
        }
        
        NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : @(NO) };
        cFaceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];

    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            double max_confidence = -1.0;
            
            NSString *GroupURL = _totalAssets[0][0][@"GroupURL"];
            NSDictionary *match = nil;
            
            int i = 0;
            
            for (NSArray *array in _totalAssets)
            {
                for(NSDictionary *AssetInfo in array)
                {
                    
                    if(self.faceProcessStop) break ;
                    
                    ALAsset *photoAsset = AssetInfo[@"Asset"];

                    //if(self.faceProcessStop) break ;
                    
                    //ALAsset *photoAsset = [_totalAssets[i] objectForKey:@"Asset"];
                    
                    //                CGImageRef cgImage = [photoAsset aspectRatioThumbnail];
                    //                UIImage *scaledImage = [FaceLib scaleImage:cgImage scale:1.2f];
                    //                CIImage *ciImage = [CIImage imageWithCGImage:scaledImage.CGImage];
                    
                    CGImageRef cgImage = [photoAsset aspectRatioThumbnail];
                    UIImage *scaledImage = nil;
                    CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
                    
                    
                    NSArray *fs = [cFaceDetector featuresInImage:ciImage];
                    
                    UIImage *faceImage = nil;
                    //UIImage *profileImage = nil;
                    NSString *faceBound;
                    
                    if(!IsEmpty(fs)) {
                        // 신규 포토 저장.
                        // Save DB. [Photos] 얼굴이 검출된 사진만 Photos Table에 저장.
                        int PhotoID = [SQLManager newPhotoWith:photoAsset withGroupAssetURL:GroupURL];
                        
                        NSURL *assetURL = [photoAsset valueForProperty:ALAssetPropertyAssetURL];
                        
                        [self.assetsLibrary addAssetURL:assetURL toAlbum:@"Pixbee" withCompletionBlock:^(NSURL *assetURL, NSError *error) {
                            
                        } withFailurBlock:^(NSError *error) {
                            
                        }];
                        
                        for(CIFaceFeature *face in fs)
                        {
                            if(PhotoID >= 0)
                            {
                                if(face.bounds.size.width < 50.f) { // 얼굴이 작은 이미지는 스킵하자...
                                    continue;
                                }

//                                //눈 코 입 모두 있을 때만 얼굴 인식.
//                                if(!(face.hasLeftEyePosition && face.hasRightEyePosition && face.hasMouthPosition)) {
//                                    continue;
//                                }
                                
                                // Save DB. [Faces]
                                cv::Mat cvImage =  [FaceLib getFaceCVData:ciImage feature:face];
                                
                                NSData *serialized = [FaceLib serializeCvMat:cvImage];
                                NSString *PhotoBound = NSStringFromCGRect(ciImage.extent);
                                faceBound = NSStringFromCGRect(face.bounds);
                                NSDictionary *faceDic = @{@"PhotoBound": PhotoBound, @"faceBound":faceBound,
                                                          @"image": serialized};
                               
                                
                                faceImage = [FaceLib getFaceUIImage:ciImage bound:face.bounds];// [FaceLib MatToUIImage:cvImage];
                                
                                if(faceDic)
                                {
                                    // Asset 사진의 face 정보 DB에 저장.
                                    int FaceNo = [SQLManager newFaceWith:PhotoID withFeature:face withInfo:faceDic];
                                    
                                    if(isFaceRecRedy)
                                    {
                                        match = [FaceLib recognizeFace:cvImage];
                                        
                                        if(match != nil){
                                            NSLog(@"Match : %@", match);
                                            PBFaceRecognizer currentRecognizerType = (PBFaceRecognizer)[match[@"currentRecognizerType"] intValue];
                                            double currentConfidence = [match[@"confidence"] doubleValue];
                                            
                                            
                                            if(currentRecognizerType == LBPHFaceRecognizer)
                                            {
                                                if([match[@"UserID"] intValue] == UserID && currentConfidence < 150.f) //for LBPH
                                                //if([match[@"UserID"] intValue] == UserID && currentConfidence < 60.f) //for LBPH
                                                {
                                                    int PhotoNo = [SQLManager newUserPhotosWith:[match[@"UserID"] intValue]
                                                                                      withPhoto:PhotoID
                                                                                       withFace:FaceNo];
                                                    if(PhotoNo) {
                                                        if(currentConfidence > max_confidence){
                                                            max_confidence = currentConfidence;
                                                        }
                                                        NSLog(@"UserID => %d Added confidence = %f",[match[@"UserID"] intValue], [match[@"confidence"] doubleValue]);
                                                        
                                                        scaledImage = [UIImage imageWithCGImage:cgImage];
                                                        [_faceAssets addObject:@{@"Asset": photoAsset, @"UserID" : @(UserID), @"PhotoID" : @(PhotoID), @"faceBound": faceBound }];
                                                        
                                                        _matchCount++;
                                                    }
                                                }
                                                
                                            }
                                            else if(currentRecognizerType == EigenFaceRecognizer || currentRecognizerType == FisherFaceRecognizer)
                                            {
                                                if([match[@"UserID"] intValue] == UserID && currentConfidence >= 0.7f) //for EigenFace
                                                {
                                                    int PhotoNo = [SQLManager newUserPhotosWith:[match[@"UserID"] intValue]
                                                                                      withPhoto:PhotoID
                                                                                       withFace:FaceNo];
                                                    if(PhotoNo) {
                                                        if(currentConfidence > max_confidence){
                                                            max_confidence = currentConfidence;
                                                         }
                                                        NSLog(@"UserID => %d Added confidence = %f",[match[@"UserID"] intValue], [match[@"confidence"] doubleValue]);
                                                        
                                                        scaledImage = [UIImage imageWithCGImage:cgImage];
                                                        [_faceAssets addObject:@{@"Asset": photoAsset, @"UserID" : @(UserID), @"PhotoID" : @(PhotoID), @"faceBound": faceBound }];
                                                        
                                                        _matchCount++;
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                        }
                    }

                    _currentProcess++;
                    
                    NSDictionary *processInfo = @{ @"totalV" : @(_totalProcess), @"currentV": @(_currentProcess),
                                                   @"matchV": @(_matchCount), @"scaledImage" : ObjectOrNull(scaledImage),
                                                   @"faceImage" : ObjectOrNull(faceImage),  @"match" : ObjectOrNull(match)};
                    
                    enumerationBlock(processInfo);
                    
                    i++;
                }
            }
            
            completion(YES);
        }
    });

    

}






- (void)loadThumbImage:(void (^)(UIImage *thumbImage))completion
{
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
    {
        NSLog(@"This debug string was logged after this function was done");
        UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
        
        completion(image);
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
    };
    
    [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:GlobalValue.lastAssetURL]
                            resultBlock:resultBlock
                           failureBlock:failureBlock];
}



- (NSString *)languegeCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *languege = languages[0];
    
    if ([languege isEqualToString:@"ko"] ||
        [languege isEqualToString:@"en"] ||
        [languege isEqualToString:@"ja"] ||
        [languege isEqualToString:@"es"] ||
        [languege isEqualToString:@"de"]) {
        
        return languege;
    }
    else if ([languege isEqualToString:@"zh-Hans"]) {
        return @"zh-CN";
    }
    else if ([languege isEqualToString:@"zh-Hant"]) {
        return @"zh-TW";
    }
    else {
        return @"en";
    }
}

- (void)checkGeocode
{
    NSString *filter = [[NSUserDefaults standardUserDefaults] objectForKey:@"ALLPHOTO_FILTER"];
    if (filter == nil || [filter isEqualToString:@""] || [filter isEqualToString:@"DISTANCE"]) {
        if(!IsEmpty(_locationArray)){
            for(int i = 0; i < _locationArray.count; i++)
            {
                int locationGroup = i;
                CLLocation *location = [_locationArray objectAtIndex:i];
                [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (! error) {
                        NSLog(@"Places: %@", placemarks);
                        for (CLPlacemark *placemark in placemarks) {
                            NSLog(@"country: %@", [placemark country]);
                            NSLog(@"administrativeArea: %@", [placemark administrativeArea]);
                            NSLog(@"subAdministrativeArea: %@", [placemark subAdministrativeArea]);
                            NSLog(@"region: %@", [placemark region]);
                            NSLog(@"Locality: %@", [placemark locality]);
                            NSLog(@"subLocality: %@", [placemark subLocality]);
                            NSLog(@"Thoroughfare: %@", [placemark thoroughfare]);
                            NSLog(@"subThoroughfare: %@", [placemark subThoroughfare]);
                            NSLog(@"Name: %@", [placemark name]);
                            NSLog(@"Desc: %@", placemark);
                            NSLog(@"addressDictionary: %@", [placemark addressDictionary]);
                            NSArray *areasOfInterest = [placemark areasOfInterest];
                            for (id area in areasOfInterest) {
                                NSLog(@"Class: %@", [area class]);
                                NSLog(@"AREA: %@", area);
                            }
                            NSString *divider = @"";
                            NSString *descriptiveString = @"";
                            if (! IsEmpty([placemark subThoroughfare])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@", [placemark subThoroughfare]];
                                divider = @", ";
                            }
                            if (! IsEmpty([placemark thoroughfare])) {
                                if (! IsEmpty(descriptiveString))
                                    divider = @" ";
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark thoroughfare]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark subLocality])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subLocality]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark locality]) && (IsEmpty([placemark subLocality]) || ! [[placemark subLocality] isEqualToString:[placemark locality]])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark locality]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark administrativeArea])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark administrativeArea]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark ISOcountryCode])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark ISOcountryCode]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark name])) {
                                descriptiveString = [NSString stringWithString:[placemark name]];
                            }
                            
                            NSLog(@"Location Group : %d || Smart place: %@",locationGroup, descriptiveString);
                            
                        }
                        /*
                         Place: (
                         "301 Geary St, 301 Geary St, San Francisco, CA  94102-1801, United States @ <+37.78711200,-122.40846000> +/- 100.00m"
                         )
                         */
                    }
                }];
                
            }
        }        
    }

}

- (void)reverseGeocode:(CLLocation *)location group:(int)locationGroup {
//    if ([_geocoder isGeocoding])
//        return;
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (! error) {
            NSLog(@"Places: %@", placemarks);
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"country: %@", [placemark country]);
                NSLog(@"administrativeArea: %@", [placemark administrativeArea]);
                NSLog(@"subAdministrativeArea: %@", [placemark subAdministrativeArea]);
                NSLog(@"region: %@", [placemark region]);
                NSLog(@"Locality: %@", [placemark locality]);
                NSLog(@"subLocality: %@", [placemark subLocality]);
                NSLog(@"Thoroughfare: %@", [placemark thoroughfare]);
                NSLog(@"subThoroughfare: %@", [placemark subThoroughfare]);
                NSLog(@"Name: %@", [placemark name]);
                NSLog(@"Desc: %@", placemark);
                NSLog(@"addressDictionary: %@", [placemark addressDictionary]);
                NSArray *areasOfInterest = [placemark areasOfInterest];
                for (id area in areasOfInterest) {
                    NSLog(@"Class: %@", [area class]);
                    NSLog(@"AREA: %@", area);
                }
                NSString *divider = @"";
                NSString *descriptiveString = @"";
                if (! IsEmpty([placemark subThoroughfare])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@", [placemark subThoroughfare]];
                    divider = @", ";
                }
                if (! IsEmpty([placemark thoroughfare])) {
                    if (! IsEmpty(descriptiveString))
                        divider = @" ";
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark thoroughfare]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark subLocality])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subLocality]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark locality]) && (IsEmpty([placemark subLocality]) || ! [[placemark subLocality] isEqualToString:[placemark locality]])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark locality]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark administrativeArea])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark administrativeArea]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark ISOcountryCode])) {
                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark ISOcountryCode]];
                    divider = @", ";
                }
                
                if (! IsEmpty([placemark name])) {
                    descriptiveString = [NSString stringWithString:[placemark name]];
                }
                
                NSLog(@"Location Group : %d || Smart place: %@",locationGroup, descriptiveString);
                
            }
            /*
             Place: (
             "301 Geary St, 301 Geary St, San Francisco, CA  94102-1801, United States @ <+37.78711200,-122.40846000> +/- 100.00m"
             )
             */
        }
    }];
    
}



- (NSString *)getAddressFrom:(CLPlacemark*)place
{
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
//    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
//    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *err){
//
//     }];
    
//    if( nil == placemarks ) return;
//    CLPlacemark *place = placemarks[0];
    NSString * stringPlace = @"";
    
    NSString * currentLanguage = [self languegeCode];
    NSLog(@"[[[[[ language code : %@", currentLanguage);
    if ([currentLanguage isEqualToString:@"ko"])
    {
        if (place.country)
        {
            stringPlace = [NSString stringWithFormat:@"%@", place.country];
        }
        
        if(place.subAdministrativeArea)
        {
            stringPlace = [NSString stringWithFormat:@"%@ %@", stringPlace, place.subAdministrativeArea];
        }
        
        if(place.administrativeArea)
        {
            stringPlace = [NSString stringWithFormat:@"%@ %@", stringPlace, place.administrativeArea];
        }
        
        if(place.subLocality)
        {
            stringPlace = [NSString stringWithFormat:@"%@ %@", stringPlace, place.subLocality];
        }
        
        if(place.locality)
        {
            stringPlace = [NSString stringWithFormat:@"%@ %@", stringPlace, place.locality];
        }
        
        if(place.thoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@ %@", stringPlace, place.thoroughfare];
        }
        
        if(place.subThoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@ %@", stringPlace, place.subThoroughfare];
        }
        
    }
    else if ([currentLanguage isEqualToString:@"ja"])
    {
        if (place.country)
        {
            stringPlace = [NSString stringWithFormat:@"%@", place.country];
        }
        
        if(place.subAdministrativeArea)
        {
            stringPlace = [NSString stringWithFormat:@"%@%@", stringPlace, place.subAdministrativeArea];
        }
        
        if(place.administrativeArea)
        {
            stringPlace = [NSString stringWithFormat:@"%@%@", stringPlace, place.administrativeArea];
        }
        
        if(place.subLocality)
        {
            stringPlace = [NSString stringWithFormat:@"%@%@", stringPlace, place.subLocality];
        }
        
        if(place.locality)
        {
            stringPlace = [NSString stringWithFormat:@"%@%@", stringPlace, place.locality];
        }
        
        if(place.thoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@%@", stringPlace, place.thoroughfare];
        }
        
        if(place.subThoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@%@", stringPlace, place.subThoroughfare];
        }
    }
    else if ([currentLanguage isEqualToString:@"zh"])
    {
        if (place.country)
        {
            stringPlace = [NSString stringWithFormat:@"%@", place.country];
        }
        
        if(place.subAdministrativeArea)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.subAdministrativeArea];
        }
        
        if(place.administrativeArea)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.administrativeArea];
        }
        
        if(place.subLocality)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.subLocality];
        }
        
        if(place.locality)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.locality];
        }
        
        if(place.thoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.thoroughfare];
        }
        
        if(place.subThoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.subThoroughfare];
        }
    }
    else if ([currentLanguage isEqualToString:@"en"] || [currentLanguage isEqualToString:@"de"] || [currentLanguage isEqualToString:@"es"])
    {
        if(place.subThoroughfare)
        {
            stringPlace = [NSString stringWithFormat:@"%@", place.subThoroughfare];
        }
        
        if(place.thoroughfare)
        {
            if(stringPlace && [stringPlace length] > 0)
            {
                stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.thoroughfare];
            } else {
                stringPlace = [NSString stringWithFormat:@"%@", place.thoroughfare];
            }
        }
        
        if(place.locality)
        {
            if(stringPlace && [stringPlace length] > 0)
            {
                stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.locality];
            } else {
                stringPlace = [NSString stringWithFormat:@"%@", place.locality];
            }
        }
        
        if(place.subLocality)
        {
            if(stringPlace && [stringPlace length] > 0)
            {
                stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.subLocality];
            }
            else
            {
                stringPlace = [NSString stringWithFormat:@"%@", place.subLocality];
            }
        }
        
        if(place.administrativeArea)
        {
            if(stringPlace && [stringPlace length] > 0)
            {
                stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.administrativeArea];
            }
            else
            {
                stringPlace = [NSString stringWithFormat:@"%@", place.administrativeArea];
            }
        }
        
        if(place.subAdministrativeArea)
        {
            if(stringPlace && [stringPlace length] > 0)
            {
                stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.subAdministrativeArea];
            }
            else
            {
                stringPlace = [NSString stringWithFormat:@"%@", place.subAdministrativeArea];
            }
        }
        
        if(place.country)
        {
            stringPlace = [NSString stringWithFormat:@"%@, %@", stringPlace, place.country];
        }
    }
 
    return stringPlace;

}


@end
