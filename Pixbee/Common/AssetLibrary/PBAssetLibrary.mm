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
    CIDetector *detector;
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
        
    }
    return self;
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




//for(ALAssetsGroup *assetGroup in resultGropus){
//    [[PBAssetsLibrary sharedInstance] loadAssets2:assetGroup success:^(NSArray *resultAssets) { //각 그룹별 Assets  뽑아냄.
//        [_totalAssets addObjectsFromArray:resultAssets];
//        [[PBAssetsLibrary sharedInstance] calcFaces:resultAssets withAssetGroup:assetGroup
//                                            success:^(NSArray *result)
//         {
//             //                      NSLog(@"==>CalcFaces : %d / %@",(int)[_faceAssets count], _faceAssets);
//         }];
//        
//    }];
//}



- (void)calcFaces:(NSArray *)asset
   withAssetGroup:(ALAssetsGroup*)assetGroup
          success:(void (^)(NSArray *result))success
{
    NSLog(@"Start...");
    //[self setAssets:asset];
    
    __block CGImageRef cgImage;
    __block CIImage *ciImage;
    __block CIDetector *detector;
    __block NSMutableArray *facesCount = [NSMutableArray array];
    __block NSInteger counter = 0;
    __block double workTime;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyLow };
    detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
    
    NSDate *date0 = [NSDate date];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            for(int i = 0; i < (int)[asset count]; i++){
                
                
                
                NSDate *date = [NSDate date];
                ALAsset *photoAsset = asset[i];
                cgImage = [photoAsset aspectRatioThumbnail];
                ciImage = [CIImage imageWithCGImage:cgImage];

                NSArray *fs = [detector featuresInImage:ciImage options:nil];
                counter = [fs count];
                
                [facesCount addObject:[NSString stringWithFormat:@"%d", (int)counter]];
                
                [self addAssetToDBWith:asset[i] withAssetGroup:assetGroup withFaceArray:fs];
                
                workTime = 0 - [date timeIntervalSinceNow];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Find : %d, 걸린시간 : %f초 || size = %@",
                          (int)counter, workTime, NSStringFromCGRect(ciImage.extent) );
                });
            }
            
            success(facesCount);
            
            NSLog(@"===> Find : %d, 걸린시간 : %f초 || size = %@",
                  (int)[_faceAssets count], workTime = 0 - [date0 timeIntervalSinceNow], NSStringFromCGRect(ciImage.extent) );
            
        }
    });
    
    
}

//- (void)calcFace:(ALAsset *)asset success:(void (^)(int count))success
//{
//    NSLog(@"Start...");
//    
//    __block CGImageRef cgImage;
//    __block CIImage *ciImage;
//    __block CIDetector *detector;
//    __block NSMutableArray *facesCount = [NSMutableArray array];
//    __block NSInteger counter = 0;
//    __block double workTime;
//    
//    CIContext *context = [CIContext contextWithOptions:nil];
//    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyLow };
//    detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @autoreleasepool {
//            NSDate *date = [NSDate date];
//            cgImage = [asset aspectRatioThumbnail];
//            ciImage = [CIImage imageWithCGImage:cgImage];
//            
//            NSArray *fs = [detector featuresInImage:ciImage options:nil];
//            
//            counter = [fs count];
//            
//            [facesCount addObject:[NSString stringWithFormat:@"%d", (int)counter]];
//            
//            workTime = 0 - [date timeIntervalSinceNow];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"Find : %d, 걸린시간 : %f초", (int)counter, workTime);
//            });
//            
//            success((int)counter);
//            
//            
//        }
//    });
//}

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


- (int)addAssetToDBWith:(ALAsset *)asset
         withAssetGroup:(ALAssetsGroup *)assetGroup
          withFaceArray:(NSArray*)faces
{
    int resultVal = 1;

//    NSLog(@"===========================================");
//    NSLog(@"Asset Info = %@", asset);
//    NSLog(@"AssetURL = %@", [asset valueForProperty:ALAssetPropertyAssetURL]);
//    NSLog(@"GroupURL = %@", [assetGroup valueForProperty:ALAssetsGroupPropertyURL]);
//    NSLog(@"Date = %@", [asset valueForProperty:ALAssetPropertyDate]);
//    NSLog(@"AssetType = %@", [asset valueForProperty:ALAssetPropertyType]);
//    NSLog(@"AssetLocation = %@", [asset valueForProperty:ALAssetPropertyLocation]);
//    NSLog(@"Duration = %@", [asset valueForProperty:ALAssetPropertyDuration]);
    NSString *AssetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    NSString *GroupURL = [assetGroup valueForProperty:ALAssetsGroupPropertyURL];
//    NSString *FilePath = @"";
//    NSString *Date = [self getDate:[asset valueForProperty:ALAssetPropertyDate]];
//    NSString *AssetType = [asset valueForProperty:ALAssetPropertyType];
//    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
//    
//    double Duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
//    int CheckType = -1;
 
//    int faceCount = 0;
//    if(faces != nil && [faces count]){
//        faceCount = (int)[faces count];
        [_faceAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":faces}];
//    }
    
  
    
    
//    NSString *query = [NSString stringWithFormat:@"SELECT PhotoID FROM Photos WHERE AssetURL = '%@';", AssetURL];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//
//    if(![result count]){ //Delete
//        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO Photos (AssetURL, GroupURL, CheckType) VALUES ('%@', '%@', %d);", AssetURL, GroupURL, faceCount];
//        NSError *error = [[PBSQLiteManager sharedInstance] doQuery:sqlStr];
//        if (error != nil) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//            resultVal = 0;
//        }
//    }
    
//    query = [NSString stringWithFormat:@"SELECT * FROM Photos WHERE AssetURL = '%@';", AssetURL];
//    result = [SQLManager getRowsForQuery:query];
//    NSLog(@"Asset Result = %@", result);
    
    return resultVal;
}

// 앨범사진 로컬 앨범DB로 동기화
//- (void)syncAlbumToDB
//{
//    [[PBAssetsLibrary sharedInstance] loadAssetGroup: ^(NSArray *resultGropus)
//     {
//         NSLog(@"=== Result Groups : %@", resultGropus);
//         
//         for(ALAssetsGroup *assetGroup in resultGropus){
////             NSLog(@"=== Result GroupURL %@ ", [assetGroup valueForProperty:ALAssetsGroupPropertyURL]);
////             NSLog(@"=== Result GroupName %@ ", [assetGroup valueForProperty:ALAssetsGroupPropertyName]);
////             NSLog(@"=== Result GroupType %@ ", [assetGroup valueForProperty:ALAssetsGroupPropertyType]);
////             NSLog(@"=== Result GroupCount %d ", (int)assetGroup.numberOfAssets);
//             [[PBAssetsLibrary sharedInstance] newGroupToDBWith:assetGroup];
//             
//             [[PBAssetsLibrary sharedInstance] loadAssets:assetGroup success:^(NSArray *resultAssets) {
//                 //                 for(ALAsset *asset in resultAssets) {
//                 //                     NSLog(@"%@", asset);
//                 //                 }
//                 // NSLog(@"Assets count = %d ", [resultAssets count]);
//                 [[PBAssetsLibrary sharedInstance] calcFaces:resultAssets withAssetGroup:assetGroup success:^(NSArray *result)
//                  {
//                      NSLog(@"CalcFaces : %@", _faceAssets);
//                  }];
//                 
//             }];
//         }
//         
//         NSString *query = @"SELECT * FROM Groups;";
//         NSArray *result = [[PBSQLiteManager sharedInstance] getRowsForQuery:query];
//         
//         NSLog(@"===> result : %@", result);
//         
//         
//     }
//     failure: ^(NSError *err)
//     {
//     }];
//}

- (void)assetGroupsToDB:(NSArray *)resultGropus
{
	for(ALAssetsGroup *assetGroup in resultGropus){
		[[PBAssetsLibrary sharedInstance] newGroupToDBWith:assetGroup];
	}
}


//- (CIImage *) featherEdgeFaceAt:(CIVector *)faceRect fromImage:(CIImage *)ciimage
//{
//    // Crop image to face
//    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
//    [cropFilter setValue:ciimage forKey:@"inputImage"];
//    [cropFilter setValue:faceRect forKey:@"inputRectangle"];
//    
//    // Blur edges
//    CIFilter *featherEdge = [CIFilter filterWithName:@"FeatherEdgeFilter"];
//    [featherEdge setValue:[cropFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
//    [featherEdge setValue:[NSNumber numberWithFloat:[faceRect W]/3.5] forKey:@"inputRadius"];
//    
//    return [featherEdge valueForKey:@"outputImage"];
//}

//- (void)checkFaces:(NSArray *)assets
//          success:(void (^)(NSArray *result))success
//{
//    NSLog(@"Start...");
//    __block NSInteger counter = 0;
//    __block double workTime;
//    _totalProcess = (int)[assets count];
//    _currentProcess = 0;
//
//    __block int PhotoID;
//    __block int FaceNo;
//    
////    CIContext *context = [CIContext contextWithOptions:nil];
////    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyLow };
////    detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:opts];
//    
//    //NSDate *date0 = [NSDate date];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @autoreleasepool {
//            for(int i = 0; i < (int)[assets count]; i++){
// 
//                NSDate *date = [NSDate date];
//                
//                ALAsset *photoAsset = [assets[i] objectForKey:@"Asset"];
//                
//                CGImageRef cgImage = [photoAsset aspectRatioThumbnail];
//                //CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
//                CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
//                
////                NSArray *fs = [detector featuresInImage:ciImage options:@{CIDetectorSmile: @(YES),
////                                                                          CIDetectorEyeBlink: @(YES),
////                                                                          }];
//                
//                NSArray *fs = [FaceLib detectFace:ciImage options:@{CIDetectorSmile: @(YES),
//                                                                    CIDetectorEyeBlink: @(YES),
//                                                                    }];
//                counter = [fs count];
//                
//                //[facesCount addObject:[NSString stringWithFormat:@"%d", (int)counter]];
//                
////                [self addAssetToDBWith:asset[i] withAssetGroup:assetGroup withFaceArray:fs];
//                
//                NSString *AssetURL = [photoAsset valueForProperty:ALAssetPropertyAssetURL];
//                NSString *GroupURL = [assets[i] objectForKey:@"GroupURL"];
//                
//                
//                //[_totalAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":fs}];
//                if(counter) {
//                    [_faceAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":fs}];
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if ([[self delegate] respondsToSelector:@selector(updatePhotoGallery:)]) {
//                            [[self delegate] updatePhotoGallery:photoAsset];
//                        }
//                    });
//                    
//                    // 신규 포토 저장.
//                    // Save DB. [Photos]
//                    PhotoID = [SQLManager newPhotoWith:photoAsset withGroupAssetURL:GroupURL];
//                    
//                    for(CIFaceFeature *face in fs){
//                        if(PhotoID >= 0){
//                            // Save DB. [Faces]
//                            NSDictionary *faceDic = [FaceLib getFaceData:ciImage bound:face.bounds];
//                            if(faceDic){
//                                FaceNo = [SQLManager newFaceWith:PhotoID withFeature:face withInfo:faceDic];
//                                
//                                UIImage *faceImage = [faceDic objectForKey:@"faceImage"];
//                                NSDictionary *match = [FaceLib recognizeFaceFromUIImage:faceImage];
//                                NSLog(@"Match : %@", match);
//                                
//                            }
//                            
//                            //NSDictionary *match = [faceRecognizer recognizeFace:image];
//                        }
//
//                     }
//                }
//
//                workTime = 0 - [date timeIntervalSinceNow];
//                _currentProcess++;
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                	NSLog(@"time : %f초 || Current = %d / %d Total ....", workTime, _currentProcess, _totalProcess);
////                    NSLog(@"Find : %d, 걸린시간 : %f초 || size = %@",
////                          (int)counter, workTime, NSStringFromCGRect(ciImage.extent) );
//                    
//                    if ([[self delegate] respondsToSelector:@selector(updateProgressUI:currentProcess:)]) {
//                        [[self delegate] updateProgressUI:[NSNumber numberWithInt:_totalProcess] currentProcess:[NSNumber numberWithInt:_currentProcess]];
//                    }
//                });
//            }
//            
//            success(_faceAssets);
//            
////            NSLog(@"===> Find : %d, 걸린시간 : %f초 || size = %@",
////                  (int)[_faceAssets count], workTime = 0 - [date0 timeIntervalSinceNow], NSStringFromCGRect(ciImage.extent) );
//            
//        }
//    });
//    
//    
//}

- (void)loadAssets2:(ALAssetsGroup *)assetsGroup success:(void (^)(NSArray *result))success
{
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    __block int locationGroup = 0;
    __block CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    //__block NSDate *oldDate;
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            //ALAssetPropertyLocation : CLLocation
            //ALAssetPropertyDate : NSDate
            
            CLLocation *newLocation = [result valueForProperty:ALAssetPropertyLocation];
            if(newLocation != nil){
                CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];

                if(distance > 1000){ //1km 반경이 넘으면 주소 refresh
                    oldLocation = newLocation;
                    [_locationArray addObject:newLocation];
                    
                    locationGroup++;
                    //[self reverseGeocode:newLocation group:locationGroup];
                }
                
                NSLog(@"LocationGroup : %d || Distance : %f || NEW Longitude = %f / Latitude = %f || OLD Longitude = %f / Latitude = %f ",
                      locationGroup, distance, newLocation.coordinate.longitude, newLocation.coordinate.latitude, oldLocation.coordinate.longitude, oldLocation.coordinate.latitude );
            


            }


            
            [assets addObject:@{@"Asset":result, @"GroupURL":[assetsGroup valueForProperty:ALAssetsGroupPropertyURL]} ];
            
        } else {
            success(assets);
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [assetsGroup setAssetsFilter:onlyPhotosFilter];
    [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
}


- (void)loadAssets3:(NSArray*)assetsGroups success:(void (^)(NSArray *result))success
{
    __block int count = 0;
    __block int groupCont = (int)[assetsGroups count];
    __block NSMutableArray *_tmpAssets = [NSMutableArray array];
    
    for(ALAssetsGroup *assetGroup in assetsGroups){
        [[PBAssetsLibrary sharedInstance] loadAssets2:assetGroup success:^(NSArray *resultAssets) { //각 그룹별 Assets  뽑아냄.
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
//         NSString *query = @"SELECT * FROM Groups;";
//         NSArray *result = [SQLManager getRowsForQuery:query];
//         
//         NSLog(@"===> result : %@", result);
         
         [[PBAssetsLibrary sharedInstance] loadAssets3:resultGropus success:^(NSArray *resultAssets) { //각 그룹별 Assets  뽑아냄.
 
             [_totalAssets addObjectsFromArray:resultAssets];
             
             result(resultAssets);
             //NSLog(@"Total Assets = %d / %@", (int)[_totalAssets count], _totalAssets);


             
         }];

     }
     failure: ^(NSError *err)
     {
     }];
}


//- (void)checkFacesNSave
//{
//    [[PBAssetsLibrary sharedInstance] checkFaces:_totalAssets success:^(NSArray *allAssets) {
//        
//        NSLog(@"==>CalcFaces : %d / %@",(int)[allAssets count], allAssets);
//    } ];
//}


- (void)checkFacesFor:(int)UserID usingEnumerationBlock:(void (^)(NSDictionary *processInfo))enumerationBlock completion:(void (^)(BOOL finished))completion {
    NSLog(@"Start...");
    __block NSInteger counter = 0;
    __block double workTime;
    _totalProcess = (int)[_totalAssets count];
    _currentProcess = 0;
    _matchCount = 0;
    
    __block int PhotoID;
    __block int FaceNo;
    __block UIImage *faceImage;
    
    [FaceLib initDetector:CIDetectorAccuracyLow Tacking:NO];
    __block BOOL isFaceRecRedy = [FaceLib initRecognizer:LBPHFaceRecognizer models:[SQLManager getTrainModels]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            for(int i = 0; i < (int)[_totalAssets count]; i++){
                
                if(self.faceProcessStop) break ;
                
                NSDate *date = [NSDate date];
                
                ALAsset *photoAsset = [_totalAssets[i] objectForKey:@"Asset"];
                
                CGImageRef cgImage = [photoAsset aspectRatioThumbnail];
                CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
                
                NSArray *fs = [FaceLib detectFace:ciImage options:@{CIDetectorSmile: @(YES),
                                                                    CIDetectorEyeBlink: @(YES),
                                                                    }];
                counter = [fs count];
                
                NSString *AssetURL = [photoAsset valueForProperty:ALAssetPropertyAssetURL];
                NSString *GroupURL = [_totalAssets[i] objectForKey:@"GroupURL"];
                
                if(counter) {
                    [_faceAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":fs}];
                    
                    // 신규 포토 저장.
                    // Save DB. [Photos]
                    PhotoID = [SQLManager newPhotoWith:photoAsset withGroupAssetURL:GroupURL];
                    
                    for(CIFaceFeature *face in fs){
                        if(PhotoID >= 0){
                            // Save DB. [Faces]
                            NSDictionary *faceDic = [FaceLib getFaceData:ciImage bound:face.bounds];
                            if(faceDic){
                                FaceNo = [SQLManager newFaceWith:PhotoID withFeature:face withInfo:faceDic];
                                
                                faceImage = [faceDic objectForKey:@"faceImage"];
                                if(isFaceRecRedy){
                                    NSDictionary *match = [FaceLib recognizeFaceFromUIImage:faceImage];
                                    if(match != nil){
                                    
                                        
                                        NSLog(@"Match : %@", match);
                                        if([[match objectForKey:@"UserID"] intValue] == UserID && [[match objectForKey:@"confidence"] doubleValue] < 70.f){
                                            int PhotoNo = [SQLManager newUserPhotosWith:[[match objectForKey:@"UserID"] intValue]
                                                                              withPhoto:PhotoID
                                                                               withFace:FaceNo];
                                            if(PhotoNo) _matchCount++;
                                            
                                        }
                                    }

                                }
                            }
                            
                        }
                        
                    }
                }
                
                workTime = 0 - [date timeIntervalSinceNow];
                _currentProcess++;
                
                if (faceImage) {
                    NSDictionary *processInfo = @{ @"Total" : @(_totalProcess), @"Current":@(_currentProcess), @"Match":@(_matchCount),
                                                   @"Asset" : photoAsset, @"Face" : faceImage};
                    
                    enumerationBlock(processInfo);
                }
            }
            
            completion(YES);
            
        }
    });

}


//- (void)checkFacesFor:(int)UserID usingEnumerationBlock:(void (^)(NSDictionary *processInfo, BOOL *stop))enumerationBlock
//{
//    NSLog(@"Start...");
//    __block NSInteger counter = 0;
//    __block double workTime;
//    _totalProcess = (int)[_totalAssets count];
//    _currentProcess = 0;
//    
//    __block int PhotoID;
//    __block int FaceNo;
//    __block BOOL stop = NO;
//    __block UIImage *faceImage;
//
//    [FaceLib initDetector:CIDetectorAccuracyLow Tacking:NO];
//    __block BOOL isFaceRecRedy = [FaceLib initRecognizer:LBPHFaceRecognizer models:[SQLManager getTrainModels]];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @autoreleasepool {
//            for(int i = 0; i < (int)[_totalAssets count]; i++){
//                
//                if(stop) return ;
//                
//                NSDate *date = [NSDate date];
//                
//                ALAsset *photoAsset = [_totalAssets[i] objectForKey:@"Asset"];
//                
//                CGImageRef cgImage = [photoAsset aspectRatioThumbnail];
//                CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
//                
//                NSArray *fs = [FaceLib detectFace:ciImage options:@{CIDetectorSmile: @(YES),
//                                                                    CIDetectorEyeBlink: @(YES),
//                                                                    }];
//                counter = [fs count];
//                
//                NSString *AssetURL = [photoAsset valueForProperty:ALAssetPropertyAssetURL];
//                NSString *GroupURL = [_totalAssets[i] objectForKey:@"GroupURL"];
// 
//                if(counter) {
//                    [_faceAssets addObject:@{@"AssetURL":AssetURL , @"GroupURL":GroupURL, @"faces":fs}];
//                    
//                    // 신규 포토 저장.
//                    // Save DB. [Photos]
//                    PhotoID = [SQLManager newPhotoWith:photoAsset withGroupAssetURL:GroupURL];
//                    
//                    for(CIFaceFeature *face in fs){
//                        if(PhotoID >= 0){
//                            // Save DB. [Faces]
//                            NSDictionary *faceDic = [FaceLib getFaceData:ciImage bound:face.bounds];
//                            if(faceDic){
//                                FaceNo = [SQLManager newFaceWith:PhotoID withFeature:face withInfo:faceDic];
//                                
//                                faceImage = [faceDic objectForKey:@"faceImage"];
//                                if(isFaceRecRedy){
//                                    NSDictionary *match = [FaceLib recognizeFaceFromUIImage:faceImage];
//                                    NSLog(@"Match : %@", match);
//                                    if([[match objectForKey:@"confidence"] floatValue] < 200.f && match != nil){
//                                        int PhotoNo = [SQLManager newUserPhotosWith:UserID withPhoto:PhotoID withFace:FaceNo];
//                                    }
//                                 }
//                           }
//
//                        }
//                        
//                    }
//                }
//                
//                workTime = 0 - [date timeIntervalSinceNow];
//                _currentProcess++;
//                
//                NSDictionary *processInfo = @{ @"Total" : @(_totalProcess), @"Current":@(_currentProcess),
//                                               @"Asset" : photoAsset, @"Face" : faceImage};
//                
//                enumerationBlock(processInfo, &stop);
//                
////                dispatch_async(dispatch_get_main_queue(), ^{
//// 
////                	NSLog(@"time : %f초 || Current = %d / %d Total ....", workTime, _currentProcess, _totalProcess);
////                    //                    NSLog(@"Find : %d, 걸린시간 : %f초 || size = %@",
////                    //                          (int)counter, workTime, NSStringFromCGRect(ciImage.extent) );
////                    
////                    if ([[self delegate] respondsToSelector:@selector(updateProgressUI:currentProcess:)]) {
////                        [[self delegate] updateProgressUI:[NSNumber numberWithInt:_totalProcess] currentProcess:[NSNumber numberWithInt:_currentProcess]];
////                    }
////                });
//                
//                
//            }
//            
////            resultBlock(_faceAssets, &stop);
//            
//            //            NSLog(@"===> Find : %d, 걸린시간 : %f초 || size = %@",
//            //                  (int)[_faceAssets count], workTime = 0 - [date0 timeIntervalSinceNow], NSStringFromCGRect(ciImage.extent) );
//            
//        }
//    });
//    
//    
//}

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
