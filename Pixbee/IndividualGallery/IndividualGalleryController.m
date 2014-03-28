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
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) GalleryViewCell *selectedCell;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSDictionary *user;

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

    UserColor = [SQLManager getUserColor:[_userInfo[@"color"] intValue] alpha:1.0];
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
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor yellowColor];
    [refreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
    
    refreshString = [[NSMutableAttributedString alloc] initWithString:@"Pull To Refresh"];
    [refreshString addAttributes:@{NSForegroundColorAttributeName : UserColor } range:NSMakeRange(0, refreshString.length)];
    refreshControl.attributedTitle = refreshString;
    
    [self.collectionView addSubview:refreshControl];
    
    self.collectionView.alwaysBounceVertical = YES;
}


-(void)startRefresh
{

    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    
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
                [tmpAssets addObject:asset];
                
                //self.assets = tmpAssets;
                //[self.collectionView reloadData];

                
                
                
                counter++;
                
                progressPercentage =  (float)counter / (float)photoCount;
                NSLog(@"progress = %f  / counter = %d / PhotoID = %d",
                      progressPercentage, (int)counter, PhotoID);
                
                dispatch_async(dispatch_get_main_queue(), ^{
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


- (void)refreshInfo
{
    self.usersPhotos = [SQLManager getUserPhotos:_UserID];

    selectedPhotos = [NSMutableArray array];
    
    self.photos = [self.usersPhotos objectForKey:@"photos"];
    self.user = [self.usersPhotos objectForKey:@"user"];
    

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
           cell.selectIcon.image = [UIImage imageNamed:@"check"];
        }
    } else {
        cell.selectIcon.hidden = YES;
    }


    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(EDIT_MODE){
        
        [self refreshSelectedPhotCountOnNavTilte];
        
    } else {
        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
        for (NSDictionary *photoinfo in self.photos) {
            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
            [idmPhotos addObject:photo];
        }
 
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        browser.delegate = self;
        [browser setInitialPageIndex:indexPath.row];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        //        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.scaleImage = self.selectedCell.photoImageView.image;

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

- (void)cellTap:(GalleryViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSLog(@"tapItem: %d %@", (int)indexPath.row, cell.selected?@"YES":@"NO");
 
    if (self.collectionView.allowsMultipleSelection) {
        if(!cell.selected){
            [selectedPhotos addObject:indexPath];
            //[cell showSelectIcon:YES];
        }
        else {
            [selectedPhotos removeObject:indexPath];
            //[cell showSelectIcon:NO];
        }

        [cell setNeedsDisplay];
        [self refreshSelectedPhotCountOnNavTilte];
        cell.selected = !cell.selected;
    }
    else {
        self.selectedCell = cell;//(GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
 
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
        for (NSDictionary *photoinfo in self.photos) {
            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
            [idmPhotos addObject:photo];
        }

        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos];// animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        browser.delegate = self;
        [browser setInitialPageIndex:indexPath.row];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        //        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.scaleImage = self.selectedCell.photoImageView.image;
        

        
        [self.navigationController pushViewController:browser animated:YES];
        
        
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    }


}

- (void)cellPressed:(GalleryViewCell *)cell
{
    if(self.activityController) return;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSLog(@"longPressItem: %d", (int)indexPath.row);
    [selectedPhotos addObject:indexPath];
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
        
    }
    else {
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
    NSLog(@"userInfo = %@", self.user);
    
//    CopyActivity *copyActivity = [[CopyActivity alloc] init];
//    MoveActivity *moveActivity = [[MoveActivity alloc] init];
//    NewAlbumActivity *newalbumActivity = [[NewAlbumActivity alloc] init];
    DeleteActivity *deleteActivity = [[DeleteActivity alloc] init];
    
    //NSArray *activitys = @[copyActivity, moveActivity, newalbumActivity, deleteActivity];
    
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
//        currentAction = act;
//        if ( [act isEqualToString:@"com.pixbee.copySharing"] ) {
//            if (self.importView) {
//                [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
//            }
//            else {
//                [self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
//            }
//         }
//         else if ( [act isEqualToString:@"com.pixbee.moveSharing"] ) {
//             if (self.importView) {
//                 [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
//             }
//             else {
//                 [self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
//             }
//         }
//         else if ( [act isEqualToString:@"com.pixbee.newAlbumSharing"] ) {
//             if (self.importView) {
//                 [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
//             }
//             else {
//                 [self newFaceTab];
//             }
//             
//          }
//         else
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

//        GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        [cell showSelectIcon:NO];
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        int userID = [[photo objectForKey:@"UserID"] intValue];
        int photoID = [[photo objectForKey:@"PhotoID"] intValue];
        NSLog(@"photo = %@", photo);
        [SQLManager deleteUserPhoto:userID  withPhoto:photoID];

    }
    
    [self refresh];

}

@end
