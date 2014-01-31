//
//  AllPhotosController.m
//  Pixbee
//
//  Created by skplanet on 2013. 12. 5..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "AllPhotosController.h"
#import "ALLPhotosView.h"
#import "TotalGalleryViewCell.h"
#import "GalleryHeaderView.h"
#import "PBAssetLibrary.h"
#import "PBFilterViewController.h"

@interface AllPhotosController () <UICollectionViewDataSource, UICollectionViewDelegate>{
        NSMutableArray *selectedPhotos;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet ALLPhotosView *allPhotosView;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *shotButton;
@property (strong, nonatomic) TotalGalleryViewCell *selectedCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)DoneClickedHandler:(id)sender;
@end

@implementation AllPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialNotification];
    
    self.doneButton.enabled = NO;
    NSLog(@"============================> Operation ID = %@", _operateIdentifier);
    
    if(([_operateIdentifier isEqualToString:@"new facetab"] || [_operateIdentifier isEqualToString:@"add Photos"])
       && !IsEmpty(_operateIdentifier))
    {
        self.doneButton.title = @"Done";
    } else {
        self.doneButton.title = @"Share";
    }

    
    selectedPhotos = [NSMutableArray array];
    [self reloadDB];
}

- (void)dealloc
{
    [self closeNotification];
}

- (void)initialNotification
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AlbumContentsViewEventHandler:)
												 name:@"AlbumContentsViewEventHandler" object:nil];
}

- (void)closeNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AlbumContentsViewEventHandler" object:nil];
}

- (void)AlbumContentsViewEventHandler:(NSNotification *)notification
{
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"changedGalleryDB"]) {
        
        [self reloadDB];
        [self goBottom];
        
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self goBottom];
}

- (void) reloadDB {
    self.photos = [PBAssetsLibrary sharedInstance].totalAssets;
    int allphotocount = 0;
    if (self.photos) {
        for (NSArray *location in self.photos) {
            allphotocount += [location count];
        }
    }
    
    self.allPhotosView.countLabel.text = [NSString stringWithFormat:@"%d", allphotocount];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView reloadData];
}

- (void)goBottom
{
    NSInteger section = [self numberOfSectionsInCollectionView:_collectionView] - 1;
    NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];

}

#pragma mark -
#pragma mark PSTCollectionViewDataSource stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if ([[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [self.photos count];
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [[self.photos objectAtIndex:section] count];
    }
    
    return [self.photos count];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GalleryHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GalleryHeaderView" forIndexPath:indexPath];
        
        NSString *filter = [[NSUserDefaults standardUserDefaults] objectForKey:@"ALLPHOTO_FILTER"];
        if (filter == nil || [filter isEqualToString:@""] || [filter isEqualToString:@"DISTANCE"]) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[PBAssetsLibrary sharedInstance].locationArray objectAtIndex:indexPath.section];
            
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
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
                        
                        if ([[placemark ISOcountryCode] isEqualToString:@"KR"]) {
                            
                            if (! IsEmpty([placemark administrativeArea])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark administrativeArea]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark locality]) && (IsEmpty([placemark subLocality]) || ! [[placemark subLocality] isEqualToString:[placemark locality]])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark locality]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark subLocality])) {
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subLocality]];
                                divider = @", ";
                            }
                            
                            if (! IsEmpty([placemark thoroughfare])) {
                                if (! IsEmpty(descriptiveString))
                                    divider = @" ";
                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark thoroughfare]];
                                divider = @", ";
                            }
                            
//                            if (! IsEmpty([placemark subThoroughfare])) {
//                                if (! IsEmpty(descriptiveString))
//                                    divider = @" ";
//                                
//                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subThoroughfare]];
//                                divider = @", ";
//                            }
                        }
                        else {
//                            if (! IsEmpty([placemark subThoroughfare])) {
//                                descriptiveString = [descriptiveString stringByAppendingFormat:@"%@", [placemark subThoroughfare]];
//                                divider = @", ";
//                            }
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
                        }
                        
                        NSString *title = descriptiveString ;//[[NSString alloc]initWithFormat:@"Photos Group #%i", indexPath.section + 1];
                        headerView.leftLabel.text = title;
                        UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
                        headerView.backgroundImage.image = headerImage;
                        
                        
                        
                        // 날짜
                        NSArray *distancePhotos = [self.photos objectAtIndex:indexPath.section];
                        NSDictionary *firstphoto = [distancePhotos firstObject];
                        ALAsset *firstasset= [firstphoto objectForKey:@"Asset"];
                        NSDate *firstDate = [firstasset valueForProperty:ALAssetPropertyDate];
                        NSString *firstdateString = [NSDateFormatter localizedStringFromDate:firstDate
                                                                                   dateStyle:NSDateFormatterLongStyle
                                                                                   timeStyle:NSDateFormatterNoStyle];
                        
                        NSDictionary *lasttphoto = [distancePhotos lastObject];
                        ALAsset *lastasset= [lasttphoto objectForKey:@"Asset"];
                        NSDate *lastDate = [lastasset valueForProperty:ALAssetPropertyDate];
                        NSString *lastdateString = [NSDateFormatter localizedStringFromDate:lastDate
                                                                                  dateStyle:NSDateFormatterLongStyle
                                                                                  timeStyle:NSDateFormatterNoStyle];
                        NSLog(@"%@ ~ %@",firstdateString, lastdateString);
                        
                        if ([firstdateString isEqualToString:lastdateString]) {
                            headerView.rightLabel.text = [NSString stringWithFormat:@"%@", firstdateString];
                        }
                        else {
                            headerView.rightLabel.text = [NSString stringWithFormat:@"%@ ~ %@", firstdateString, lastdateString];
                        }
                    }
                    /*
                     Place: (
                     "301 Geary St, 301 Geary St, San Francisco, CA  94102-1801, United States @ <+37.78711200,-122.40846000> +/- 100.00m"
                     )
                     */
                }
            }];
        }
        else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            id location = [[PBAssetsLibrary sharedInstance].locationArray objectAtIndex:indexPath.section];
            
            NSArray *distancePhotos = [self.photos objectAtIndex:indexPath.section];
            NSDictionary *firstphoto = [distancePhotos firstObject];
            ALAsset *firstasset= [firstphoto objectForKey:@"Asset"];
            NSDate *firstDate = [firstasset valueForProperty:ALAssetPropertyDate];
            NSString *firstdateString = [NSDateFormatter localizedStringFromDate:firstDate
                                                                       dateStyle:NSDateFormatterLongStyle
                                                                       timeStyle:NSDateFormatterNoStyle];
            
            
            NSDictionary *lasttphoto = [distancePhotos lastObject];
            ALAsset *lastasset= [lasttphoto objectForKey:@"Asset"];
            NSDate *lastDate = [lastasset valueForProperty:ALAssetPropertyDate];
            NSString *lastdateString = [NSDateFormatter localizedStringFromDate:lastDate
                                                                      dateStyle:NSDateFormatterLongStyle
                                                                      timeStyle:NSDateFormatterNoStyle];
            NSLog(@"%@ ~ %@",firstdateString, lastdateString);
            
            if ([filter isEqualToString:@"DAY"]) {
                NSString *title = firstdateString ;
                headerView.leftLabel.text = title;
            }
            else {
                if ([firstdateString isEqualToString:lastdateString]) {
                    headerView.leftLabel.text = [NSString stringWithFormat:@"%@", firstdateString];
                }
                else {
                    headerView.leftLabel.text = [NSString stringWithFormat:@"%@ ~ %@", firstdateString, lastdateString];
                }
            }
            
            UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
            headerView.backgroundImage.image = headerImage;
            headerView.rightLabel.alpha = 1;
            if ([location isKindOfClass:[CLLocation class]]) {
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
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
                            
                            if ([[placemark ISOcountryCode] isEqualToString:@"KR"]) {
                                
                                if (! IsEmpty([placemark administrativeArea])) {
                                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark administrativeArea]];
                                    divider = @", ";
                                }
                                
                                if (! IsEmpty([placemark locality]) && (IsEmpty([placemark subLocality]) || ! [[placemark subLocality] isEqualToString:[placemark locality]])) {
                                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark locality]];
                                    divider = @", ";
                                }
                                
                                if (! IsEmpty([placemark subLocality])) {
                                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subLocality]];
                                    divider = @", ";
                                }
                                
                                if (! IsEmpty([placemark thoroughfare])) {
                                    if (! IsEmpty(descriptiveString))
                                        divider = @" ";
                                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark thoroughfare]];
                                    divider = @", ";
                                }
                                
//                                if (! IsEmpty([placemark subThoroughfare])) {
//                                    if (! IsEmpty(descriptiveString))
//                                        divider = @" ";
//                                    
//                                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@%@", divider, [placemark subThoroughfare]];
//                                    divider = @", ";
//                                }
                            }
                            else {
//                                if (! IsEmpty([placemark subThoroughfare])) {
//                                    descriptiveString = [descriptiveString stringByAppendingFormat:@"%@", [placemark subThoroughfare]];
//                                    divider = @", ";
//                                }
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
                            }
                            
                            NSString *title = descriptiveString ;//[[NSString alloc]initWithFormat:@"Photos Group #%i", indexPath.section + 1];
                            headerView.rightLabel.text = title;
                        }
                    }
                    else {
                        headerView.rightLabel.alpha = 0;
                    }
                }];

            }
            else {
                headerView.rightLabel.alpha = 0;
            }
        }
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TotalGalleryViewCell";
    
    TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSArray *distancePhotos = [self.photos objectAtIndex:indexPath.section];
    NSDictionary *photo = [distancePhotos objectAtIndex:indexPath.row];
    
    [cell updateCell:photo];
    
    if ([selectedPhotos containsObject:indexPath]) {
        [cell showSelectIcon:YES];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos addObject:indexPath];
        
        // UI
        TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell showSelectIcon:YES];
        [cell setNeedsDisplay];
        
        int selectcount = (int)[selectedPhotos count];
        if(selectedPhotos.count) self.doneButton.enabled = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
                             if (selectcount > 0) {
                                 self.navigationItem.title = [NSString stringWithFormat:@"%d Photo Selected", selectcount];
                             }
                             else {
                                 self.navigationItem.title = @"Album";
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
//    else {
//        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        //        [self performSegueWithIdentifier:SEGUE_4_1_TO_5_1 sender:self];
//        
//        //        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
//        //        for (NSDictionary *photoinfo in self.photos) {
//        //            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//        //            [idmPhotos addObject:photo];
//        //        }
//        
//        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
//        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
//        NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//        [idmPhotos addObject:photo];
//        
//        // Create and setup browser
//        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
//        browser.delegate = self;
//        [browser setInitialPageIndex:indexPath.row];
//        browser.displayActionButton = NO;
//        browser.displayArrowButton = NO;
//        //        browser.displayArrowButton = YES;
//        browser.displayCounterLabel = YES;
//        browser.scaleImage = self.selectedCell.photoImageView.image;
//        
//        //        [self.navigationController p presentedViewController:browser];
//        
//        // Show
//        [self presentViewController:browser animated:YES completion:nil];
//        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos removeObject:indexPath];
        
        unsigned long selectcount = [selectedPhotos count];
        if(!selectcount) self.doneButton.enabled = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             if (selectcount > 0) {
                                 self.navigationItem.title = [NSString stringWithFormat:@"%lu Photo Selected", selectcount];
                             }
                             else {
                                 self.navigationItem.title = @"All Photos";
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
    // UI
    TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell showSelectIcon:NO];
    [cell setNeedsDisplay];
}


//- (IBAction)DoneClickedHandler:(id)sender {
//    // DB작업 후 화면 전환.
//    if([_operateIdentifier isEqualToString:@"new facetab"] ){
//        
//    }
//    else if([_operateIdentifier isEqualToString:@"add Photos"]) {
//        
//    } else {
//        // 필터 화면으로 이동
//        [self performSegueWithIdentifier:SEGUE_GO_FILTER sender:self];
//    }
//    
//    if([_operateIdentifier isEqualToString:@"new facetab"] || [_operateIdentifier isEqualToString:@"add Photos"]) && !IsEmpty(_operateIdentifier)  ){
//        // 새로운 Facetab 만들고 Main dashboard로 돌아가기
//        
//        if(selectedPhotos.count < 5){
//            [UIAlertView showWithTitle:@""
//                               message:@"5장 이상 등록!!"
//                     cancelButtonTitle:@"OK"
//                     otherButtonTitles:nil
//                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                  if (buttonIndex == [alertView cancelButtonIndex]) {
//                                     //[self.navigationController popViewControllerAnimated:YES];
//                                  }
//                              }];
//            
//        } else {
//            //NSMutableArray *photoDatas = [NSMutableArray array];
//#warning 추후에 얼굴 등록하는 프로세스 페이지 추가 필요.
//            NSArray *result = [SQLManager newUser];
//            NSDictionary *user = [result objectAtIndex:0];
//            //NSString *UserName = [user objectForKey:@"UserName"];
//            int UserID = [[user objectForKey:@"UserID"] intValue];
//            int photoCount = 0;
//            
//            for(NSIndexPath *indexPath in selectedPhotos)
//            {
//                photoCount++;
//                NSArray *distancePhotos = [self.photos objectAtIndex:indexPath.section];
//                NSDictionary *photo = [distancePhotos objectAtIndex:indexPath.row];
//                ALAsset *asset = photo[@"Asset"];
//                NSLog(@"photo data = %@", photo);
//                
//                NSArray *faces = [AssetLib getFaceData:asset];
//                if(faces.count == 1 && !IsEmpty(faces)){
//                    NSDictionary *face = faces[0];
//                    NSData *faceData = face[@"image"];
//                    UIImage *faceImage = face[@"faceImage"];
//                    if(faceImage != nil)
//                        [SQLManager setUserProfileImage:faceImage UserID:UserID];
//                    
//                    [SQLManager setTrainModelForUserID:UserID withFaceData:faceData];
//                }
//                else {
//                    CGImageRef cgImage = [asset aspectRatioThumbnail];
//                    UIImage *faceImage = [UIImage imageWithCGImage:cgImage];
//                    if(faceImage != nil)
//                        [SQLManager setUserProfileImage:faceImage UserID:UserID];
//                }
//
//                
//                [SQLManager saveNewUserPhotoToDB:asset users:@[@(UserID)]];
//            }
//            
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        
//
//        
//        
//        
//    } else {
//    }
//}

- (IBAction)DoneClickedHandler:(id)sender {
    // DB작업 후 화면 전환.
    if([_operateIdentifier isEqualToString:@"new facetab"] && !IsEmpty(_operateIdentifier)  )
    {
        // 새로운 Facetab 만들고 Main dashboard로 돌아가기
        
        if(selectedPhotos.count < 5){
            [UIAlertView showWithTitle:@""
                               message:@"5장 이상 등록!!"
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      //[self.navigationController popViewControllerAnimated:YES];
                                  }
                              }];
            
        } else {
            //NSMutableArray *photoDatas = [NSMutableArray array];
#warning 추후에 얼굴 등록하는 프로세스 페이지 추가 필요.
            NSArray *result = [SQLManager newUser];
            NSDictionary *user = [result objectAtIndex:0];
            //NSString *UserName = [user objectForKey:@"UserName"];
            int UserID = [[user objectForKey:@"UserID"] intValue];
            int photoCount = 0;
            
            for(NSIndexPath *indexPath in selectedPhotos)
            {
                photoCount++;
                //NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
                NSArray *photoGroups = [self.photos objectAtIndex:indexPath.section];
                NSDictionary *photo = [photoGroups objectAtIndex:indexPath.row];

                ALAsset *asset = photo[@"Asset"];
                NSLog(@"photo data = %@", photo);
                
                NSArray *faces = [AssetLib getFaceData:asset];
                if(faces.count == 1 && !IsEmpty(faces)){
                    NSDictionary *face = faces[0];
                    NSData *faceData = face[@"image"];
                    
                    UIImage *faceImage = face[@"faceImage"];
                    if(faceImage != nil)
                        [SQLManager setUserProfileImage:faceImage UserID:UserID];
                    
                    [SQLManager setTrainModelForUserID:UserID withFaceData:faceData];
                }
                else {
                    CGImageRef cgImage = [asset aspectRatioThumbnail];
                    UIImage *faceImage = [UIImage imageWithCGImage:cgImage];
                    if(faceImage != nil)
                        [SQLManager setUserProfileImage:faceImage UserID:UserID];
                }
                
                
                [SQLManager saveNewUserPhotoToDB:asset users:@[@(UserID)]];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    else if([_operateIdentifier isEqualToString:@"add Photos"] && !IsEmpty(_operateIdentifier)  )
    {
#warning 추후에 얼굴 등록하는 프로세스 페이지 추가 필요.
        int UserID = [_userInfo[@"UserID"] intValue];
        
        for(NSIndexPath *indexPath in selectedPhotos)
        {
            NSArray *photoGroups = [self.photos objectAtIndex:indexPath.section];
            NSDictionary *photo = [photoGroups objectAtIndex:indexPath.row];
            ALAsset *asset = photo[@"Asset"];
            NSLog(@"photo data = %@", photo);
            
//            NSArray *faces = [AssetLib getFaceData:asset];
//            if(faces.count == 1 && !IsEmpty(faces)){
//                NSDictionary *face = faces[0];
//                NSData *faceData = face[@"image"];
//                
//                UIImage *faceImage = face[@"faceImage"];
//                if(faceImage != nil)
//                    [SQLManager setUserProfileImage:faceImage UserID:UserID];
//                
//                [SQLManager setTrainModelForUserID:UserID withFaceData:faceData];
//            }
//            else {
//                CGImageRef cgImage = [asset aspectRatioThumbnail];
//                UIImage *faceImage = [UIImage imageWithCGImage:cgImage];
//                if(faceImage != nil)
//                    [SQLManager setUserProfileImage:faceImage UserID:UserID];
//            }
            
            [SQLManager saveNewUserPhotoToDB:asset users:@[@(UserID)]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    else {
        // 필터 화면으로 이동
        [self performSegueWithIdentifier:SEGUE_GO_FILTER sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_FILTER]){
        self.navigationController.navigationBarHidden = NO;
        PBFilterViewController *destination = segue.destinationViewController;
        
        NSMutableArray *photoDatas = [NSMutableArray array];
        
        for(NSIndexPath *indexPath in selectedPhotos){
            NSArray *distancePhoto = [self.photos objectAtIndex:indexPath.section];
            NSDictionary *photo = [distancePhoto objectAtIndex:indexPath.row];
            [photoDatas addObject:photo];
        }
        
        destination.photos = photoDatas;
        
    }
}



@end
