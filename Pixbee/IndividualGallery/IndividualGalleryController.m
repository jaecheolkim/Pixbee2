//
//  IndividualGalleryController.m
//  Pixbee
//
//  Created by JCKIM on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "IndividualGalleryController.h"
#import "GalleryViewCell.h"
//#import "GalleryHeaderView.h"
#import "UserCell.h"
#import "OpenPhotoSegue.h"
#import "OpenPhotoUnwindSegue.h"
#import "SCTInclude.h"
#import "IDMPhotoBrowser.h"
#import "FBFriendController.h"
#import "CopyActivity.h"
#import "MoveActivity.h"
#import "NewAlbumActivity.h"
#import "DeleteActivity.h"
#import "AlbumSelectionController.h"
#import "AllPhotosController.h"
#import "FXBlurView.h"
#import "UINavigationController+SGProgress.h"

#import "GalleryViewController.h"

#define REFRESH_COLOR RGB_COLOR(254,196,57)

@interface IndividualGalleryController ()
<UICollectionViewDataSource, UICollectionViewDelegate,
IDMPhotoBrowserDelegate, GalleryViewCellDelegate>
{
    BOOL EDIT_MODE;
    
    NSString *UserName;
    UIColor *UserColor;
    
    int totalCellCount;
    NSIndexPath *currentIndexPath;

    NSMutableArray *selectedPhotos;
    NSString *currentAction;

    UIRefreshControl *refreshControl;
    NSMutableAttributedString *refreshString;
    
    NSIndexPath *lastAccessed;
    UIPanGestureRecognizer *swipeToSelectGestureRecognizer;

    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) int UserID;
@property (strong, nonatomic) NSMutableArray *photos;

@property (strong, nonatomic) UIActivityViewController *activityController;

@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)editButtonClickHandler:(id)sender;

- (IBAction)shareButtonHandler:(id)sender;

@end

@implementation IndividualGalleryController


#pragma mark -
#pragma mark ViewController life cycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    _UserID = [_userInfo[@"UserID"] intValue];

    UserColor = [UIColor whiteColor]; //[SQLManager getUserColor:[_userInfo[@"color"] intValue] alpha:1.0];
    UserName = _userInfo[@"UserName"];

    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1]];
    
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    UIColor *strokeColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.15];
    
    [navigationBar setTitleTextAttributes: @{
                                             NSForegroundColorAttributeName : UserColor,
                                             NSStrokeWidthAttributeName : @-3,
                                             NSStrokeColorAttributeName : strokeColor,
                                             NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }];

    _shareButton.enabled = NO;

    self.collectionView.backgroundColor = [UIColor clearColor];
 
    [self initRefreshControl];



    // List all fonts on iPhone
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames = [[NSArray alloc] initWithArray:
//                     [UIFont fontNamesForFamilyName:
//                      [familyNames objectAtIndex:indFamily]]];
//        for (indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
//        }
// 
//    }
 
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshInfo];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self goBottom];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UIRefreshControl & refresh methods

- (void)initRefreshControl
{
    NSString *str = [NSString stringWithFormat:@"Searching %@'s photos..",UserName];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = REFRESH_COLOR;//[UIColor yellowColor];
    [refreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
    
    refreshString = [[NSMutableAttributedString alloc] initWithString:str];
    [refreshString addAttributes:@{NSForegroundColorAttributeName : REFRESH_COLOR } range:NSMakeRange(0, refreshString.length)];
    
    UIFont *font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    [refreshString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [refreshString length])];

    
    refreshControl.attributedTitle = refreshString;
    
    [self.collectionView addSubview:refreshControl];
    
    self.collectionView.alwaysBounceVertical = YES;
}


-(void)startRefresh
{
    if( AssetLib.isSyncPixbeeAlbum) {
        NSString *msg = @"Please wait until sync Pixbee.";
        refreshString = [[NSMutableAttributedString alloc] initWithString:msg];
        [refreshString addAttributes:@{NSForegroundColorAttributeName : REFRESH_COLOR } range:NSMakeRange(0, refreshString.length)];
        
        UIFont *font = [UIFont fontWithName:@"Avenir-Medium" size:12];
        [refreshString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [refreshString length])];

        refreshControl.attributedTitle = refreshString;
        
//        [NSThread sleepForTimeInterval:1.0];
//        [refreshControl endRefreshing];

        //__weak IndividualGalleryController *weakSelf = self;
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [refreshControl endRefreshing];
        });
        
        
        return;
    }

    if([AssetLib prepareFaceRecognizeForUser:_UserID])
    {
        NSArray *allPixbeePhots = [SQLManager getGroupPhotos:[AssetLib.pixbeeAssetGroup valueForProperty:ALAssetsGroupPropertyURL] filter:YES];
        
        dispatch_queue_t serialQueue = dispatch_queue_create("com.pixbee.serialqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_semaphore_t exeSignal = dispatch_semaphore_create(1);
        
        __block NSInteger photoCount = [allPixbeePhots count];
        __block NSInteger counter = 0;
        __block float progressPercentage = 0.0f;
        
        for(NSDictionary *photoInfo in allPixbeePhots){
            //PhotoID, AssetURL, Longitude, Latitude, Date, CheckType <= 이걸로 나중에 필터링.
            
            dispatch_async(serialQueue, ^{
                
                dispatch_semaphore_wait(exeSignal, DISPATCH_TIME_FOREVER);
                
                NSString *AssetURL = photoInfo[@"AssetURL"];
                int PhotoID = [photoInfo[@"PhotoID"] intValue];
                
                ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
                {
                    NSDictionary *photoInfo = nil;
                    
                    //여기서 UserID 와 Asset 을 가지고 사용자 사진인지 아닌지 구분해서 UserID의 사진이 맞다면..
                    if([AssetLib checkFace:_UserID asset:asset photoID:PhotoID])
                    {
                        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
                        NSString *assetURL = url.absoluteString;
                        
                        photoInfo = @{@"UserID" : @(_UserID), @"FaceNo" : @(-1), @"PhotoID": @(PhotoID), @"AssetURL": assetURL};
                        
                    } 
                    
                    counter++;
                    
                    progressPercentage =  (float)counter / (float)photoCount;
                    NSLog(@"progress = %f  / counter = %d / PhotoID = %d",
                          progressPercentage, (int)counter, PhotoID);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if(NSNotFound == [self.photos indexOfObject:photoInfo] && !IsEmpty(photoInfo)) {
//                            [self.photos addObject:photoInfo];
//                            [self.collectionView reloadData];
                            
                            [self.collectionView performBatchUpdates:^{
                                //NSInteger lastIndex = [self.photos count]-1;
                                [self.photos insertObject:photoInfo atIndex:0];
                                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                [self.collectionView insertItemsAtIndexPaths:@[lastIndexPath]];
                            //
                            } completion:^(BOOL finished) {
                            //
                             }];
                            
                        }
                        
                        [self.navigationController setSGProgressPercentage:progressPercentage * 100];
                        
                        if(progressPercentage == 1.0f) {
                            [self.navigationController finishSGProgress];
                            [refreshControl endRefreshing];
                        }
                    });
                    
                    dispatch_semaphore_signal(exeSignal);
                };
                
                ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
                {
                    dispatch_semaphore_signal(exeSignal);
                };
                
                [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:AssetURL]
                                        resultBlock:resultBlock
                                       failureBlock:failureBlock];
                
            });
        }

    }

}


- (void)refreshInfo
{

    selectedPhotos = [NSMutableArray array];
 
    self.photos = (NSMutableArray*)[SQLManager getUserPhotos:_UserID];

    [self.collectionView reloadData];

    self.title = [NSString stringWithFormat:@"%@ (%d)", UserName, (int)[self.photos count]];
 
}

- (void)refresh
{
    self.activityController = nil;
    
    [selectedPhotos removeAllObjects];
    [self editButtonClickHandler:nil];
    [self refreshSelectedPhotCountOnNavTilte];
    
    [self refreshInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumContentsViewEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"changedGalleryDB"}];
    
}




- (void)goBottom
{
    if(IsEmpty(self.photos)) return;
    
    NSInteger section = [self numberOfSectionsInCollectionView:_collectionView] - 1;
    NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    
}

- (void)refreshSelectedPhotCountOnNavTilte
{
    _shareButton.enabled = NO;
    int selectcount = 0;
    if(!IsEmpty(selectedPhotos)) {
        selectcount = (int)[selectedPhotos count];
    }
    if(selectcount) {
        _shareButton.enabled = YES;
    }
    
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


#pragma mark -
#pragma mark CollectionViewDataSource stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.photos count];
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"GalleryViewCell";
    
    GalleryViewCell *cell = (GalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    cell.photo = photo;
    
    if(EDIT_MODE){
        cell.selectIcon.hidden = NO;
        
        if ([selectedPhotos containsObject:indexPath]) {
           cell.checkIcon.hidden = NO;
        }
    } else {
        cell.selectIcon.hidden = YES;
        cell.checkIcon.hidden = YES;
    }


    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(EDIT_MODE){
        [selectedPhotos addObject:indexPath];
        [self refreshSelectedPhotCountOnNavTilte];
        
    } else {
        GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.selectIcon.hidden = YES;
        cell.checkIcon.hidden = YES;
        
        
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
        for (NSDictionary *photoinfo in self.photos) {
            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
            [idmPhotos addObject:photo];
        }
 
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:cell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        browser.delegate = self;
        [browser setInitialPageIndex:indexPath.row];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        //        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.scaleImage = cell.photoImageView.image;

        // Show
        [self.navigationController pushViewController:browser animated:YES];

    }
    

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos removeObject:indexPath];
        [self refreshSelectedPhotCountOnNavTilte];
    }

}



#pragma mark GalleryViewCellDelegate



- (void)cellPressed:(GalleryViewCell *)cell
{
    if(self.activityController) return;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSLog(@"longPressItem: %d", (int)indexPath.row);

    
    [self shareButtonHandler:nil];
}



#pragma mark - UI Control methods

- (void)showToolBar:(BOOL)show
{
    CGRect rect = [UIScreen mainScreen].bounds;
    CGRect frame = self.toolbar.frame;
    
    if(show){
         frame = CGRectMake(frame.origin.x, rect.size.height - frame.size.height, frame.size.width, frame.size.height);
        
    } else {
        
        frame = CGRectMake(frame.origin.x, rect.size.height, frame.size.width, frame.size.height);
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.toolbar.frame = frame;
                     }
                     completion:^(BOOL finished){
                         if(!show){

                         }
                     }];
    
    
}

#pragma mark -
#pragma mark ButtonAction
//Edit Button
- (IBAction)editButtonClickHandler:(id)sender {
    EDIT_MODE = !EDIT_MODE;
    
    if(EDIT_MODE){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                            object:self
                                                          userInfo:@{@"panGestureEnabled":@"NO"}];
        
        self.navigationItem.rightBarButtonItem.image = nil;
        self.navigationItem.rightBarButtonItem.title = @"Cancel";
        
        [self initSwipeToSelectPanGesture];
        
    }
    else {
        
        [self removeSwipeToSelectPanGesture];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                            object:self
                                                          userInfo:@{@"panGestureEnabled":@"YES"}];
        
        [selectedPhotos removeAllObjects];
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit"];
    }
    
    [self showToolBar:EDIT_MODE];
    [self.collectionView setAllowsMultipleSelection:EDIT_MODE];
    [self.collectionView reloadData];

}



- (IBAction)shareButtonHandler:(id)sender {
    
    NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:[selectedPhotos count]];
    
    for (NSIndexPath *indexPath in selectedPhotos) {
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        NSLog(@"Selected Photo = %@", photo);
        NSString *imagePath = [photo objectForKey:@"AssetURL"];
        [activityItems addObject:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imagePath]];
    }
    
    NSLog(@"selectedPhoto = %@", selectedPhotos);

    DeleteActivity *deleteActivity = [[DeleteActivity alloc] init];
 
    NSArray *activitys = @[deleteActivity];
    
    self.activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activitys];
    [self.activityController setExcludedActivityTypes:@[UIActivityTypePostToTwitter,
                                                   UIActivityTypePostToWeibo,
                                                   UIActivityTypePrint,
                                                   UIActivityTypeCopyToPasteboard,
                                                   UIActivityTypeAssignToContact,
                                                   UIActivityTypeSaveToCameraRoll,
                                                   UIActivityTypeAddToReadingList,
                                                   UIActivityTypePostToFlickr,
                                                   UIActivityTypePostToVimeo,
                                                   UIActivityTypePostToTencentWeibo,
                                                   UIActivityTypeAirDrop]];
    

    [self presentViewController:self.activityController
                       animated:YES
                     completion:^
                    {

                    }];
    
    [self.activityController setCompletionHandler:^(NSString *act, BOOL done) {

        if ( [act isEqualToString:@"com.pixbee.deleteSharing"] ) {

             [self deletePhotos];
         }
        
        self.activityController = nil;
//         if ( [act isEqualToString:UIActivityTypeMail] )           ServiceMsg = @"Mail sended!";
//         if ( [act isEqualToString:UIActivityTypePostToTwitter] )  ServiceMsg = @"Post on twitter, ok!";
//         if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @"Post on facebook, ok!";
//         if ( [act isEqualToString:UIActivityTypeMessage] )        ServiceMsg = @"SMS sended!";
//         if ( done )
//         {
////             UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
////             [Alert show];
////             [Alert release];
//         }
     }];

}




- (void)deletePhotos
{
    if(IsEmpty(selectedPhotos)) return;
    
    [self.activityController dismissViewControllerAnimated:YES completion:nil];
    
    
    for (NSIndexPath *indexPath in selectedPhotos) {
        NSLog(@"=====> indexPath.row : %d || [self.photos count] : %d", (int)indexPath.row, (int)[self.photos count]);

        
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        int userID = [[photo objectForKey:@"UserID"] intValue];
        int photoID = [[photo objectForKey:@"PhotoID"] intValue];
        NSLog(@"photo = %@", photo);
        [SQLManager deleteUserPhoto:userID  withPhoto:photoID];

    }
    
    [self refresh];

}

#pragma mark -
#pragma mark SwiptToSelect methods

- (void)initSwipeToSelectPanGesture
{
    swipeToSelectGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:swipeToSelectGestureRecognizer];
    [swipeToSelectGestureRecognizer setMinimumNumberOfTouches:1];
    [swipeToSelectGestureRecognizer setMaximumNumberOfTouches:1];
}

- (void)removeSwipeToSelectPanGesture
{
    [self.view removeGestureRecognizer:swipeToSelectGestureRecognizer];
    swipeToSelectGestureRecognizer.delegate = nil;
    swipeToSelectGestureRecognizer = nil;
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    float pointerX = [gestureRecognizer locationInView:self.collectionView].x;
    float pointerY = [gestureRecognizer locationInView:self.collectionView].y;
    
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY)
        {
            NSIndexPath *touchOver = [self.collectionView indexPathForCell:cell];
            
            if (lastAccessed != touchOver)
            {
                if (cell.selected)
                    [self deselectCellForCollectionView:self.collectionView atIndexPath:touchOver];
                else
                    [self selectCellForCollectionView:self.collectionView atIndexPath:touchOver];
            }
            
            lastAccessed = touchOver;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        lastAccessed = nil;
        self.collectionView.scrollEnabled = YES;
    }
    
    
}

- (void) selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void) deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}


@end
