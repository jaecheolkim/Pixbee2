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

#import "CopyActivity.h"
#import "MoveActivity.h"
#import "NewAlbumActivity.h"
#import "DeleteActivity.h"

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))


@interface AllPhotosController ()
<UICollectionViewDataSource, UICollectionViewDelegate>
{
    BOOL EDIT_MODE;
    int totalCellCount;

    NSMutableArray *selectedPhotos;
    
    NSMutableArray *selectedStackImages;
    
    NSMutableArray *scrollViewCellFrames;
    
    UIRefreshControl *refreshControl;
    
    NSString *currentAction;
    
    CGPoint lastTouchPoint;
    
    int currentUserID;
    
    int currentPosition, previousPosiotion;
    
    UIButton *backBtn;
    UIButton *editBtn;
    
}
//@property (nonatomic, retain) APNavigationController *navController;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *assets;

@property (strong, nonatomic) UIActivityViewController *activityController;
@property (strong, nonatomic) IBOutlet ALLPhotosView *allPhotosView;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) TotalGalleryViewCell *selectedCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet UIView *faceTabListBar;
@property (weak, nonatomic) IBOutlet UIScrollView *faceTabScrollView;

@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UIView *toolbar;

@property (strong, nonatomic) UIBarButtonItem *buttonNew;
@property (strong, nonatomic) UIBarButtonItem *buttonAdd;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (weak, nonatomic) IBOutlet UIButton *stackImages;

- (IBAction)rightBarButtonHandler:(id)sender;

- (IBAction)shareButtonHandler:(id)sender;

- (IBAction)closeFaceTabButtonHandler:(id)sender;

- (IBAction)leftBarButtonHandler:(id)sender;


@end

@implementation AllPhotosController

#pragma mark - assets

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _assets = [NSMutableArray array]; //[@[] mutableCopy];
    _photos = [@[] mutableCopy];
    
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_unfacetab"]];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleView;

    NSLog(@"segueIdentifier = %@", _segueIdentifier);
    if([_segueIdentifier isEqualToString:@"Segue3_1to4_3"]){
        [_menuButton setImage:[UIImage imageNamed:@"back"]];
    }

    self.collectionView.backgroundColor = [UIColor clearColor];

    [self initialNotification];

    _shareButton.enabled = NO;

    selectedPhotos = [NSMutableArray array];
    selectedStackImages = [NSMutableArray array];
    
    scrollViewCellFrames = [NSMutableArray array];
    
    [self reloadDB];
    
    [self initFaceTabList];
    
    [self initStackImages];
    
    currentUserID = -1;
    currentPosition = -1;
    previousPosiotion = -2;
}


- (void)refershControlAction
{
    [self reloadDB];
    
}

- (void)dealloc
{
    [self closeNotification];
}


- (void)initialNotification
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DBEventHandler:)
												 name:@"DBEventHandler" object:nil];
}

- (void)closeNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DBEventHandler" object:nil];
}

- (void)DBEventHandler:(NSNotification *)notification
{

    
    NSDictionary *userInfo = [notification userInfo];
    
    if([userInfo[@"Msg"] isEqualToString:@"changedGalleryDB"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ALAsset *newAsset = userInfo[@"Asset"];
            [self.assets addObject:newAsset];
            NSInteger lastIndex = [self.assets count] - 1;
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastIndex inSection:0];
            
            [self.collectionView insertItemsAtIndexPaths:@[lastIndexPath]];
            //[self.collectionView reloadData];

            [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];

            
        });
        
        
//        NSInteger index = [self.assets indexOfObject:newAsset];
//        if(!index){
//            [self.assets addObject:newAsset];
//            [self.collectionView reloadData];
//        }

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
}

- (void) reloadDB {
    
    
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    // 1
    ALAssetsLibrary *assetsLibrary = [AllPhotosController defaultAssetsLibrary];
    // 2
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if([[group valueForProperty:ALAssetsGroupPropertyName]  isEqualToString:@"Pixbee"]){
            __block NSInteger groupAssetCount = group.numberOfAssets;
            
            
            //_photos = [SQLManager getGroupPhotos:[group valueForProperty:ALAssetsGroupPropertyURL]];
            //NSLog(@"result count = %d / %@ ", (int)[_photos count], _photos);
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    // 3
                    [tmpAssets addObject:result];
                    
                } else {
                    NSLog(@"index = %d / groupAssetCount = %d", (int)index, (int)groupAssetCount);
                }

            }];
            
            // 4
            //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
            //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
            self.assets = tmpAssets;
            
            // 5
            [self.collectionView reloadData];
            
 
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
}


#pragma mark -
#pragma mark PSTCollectionViewDataSource stuff



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TotalGalleryViewCell";
    
    TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;

    if(EDIT_MODE){
        cell.selectIcon.hidden = NO;
        if ([selectedPhotos containsObject:indexPath]) {
            cell.checkIcon.hidden = NO;
        }
    } else {
        cell.selectIcon.hidden = YES;
        cell.checkIcon.hidden = YES;
    }

    
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (EDIT_MODE) {
        [selectedPhotos addObject:indexPath];
        
        [self refreshSelectedPhotCountOnNavTilte];
    }
    else {
        TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.checkIcon.hidden = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos removeObject:indexPath];
        [self refreshSelectedPhotCountOnNavTilte];
    }
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
                             self.navigationItem.title = @"Un FaceTab"; //@"All Photos";
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];

}




#pragma mark - UI Control methods
- (IBAction)shareButtonHandler:(id)sender
{
    NSMutableArray *activityItems = selectedPhotos;//[NSMutableArray arrayWithCapacity:[selectedPhotos count]];

    
    //CopyActivity *copyActivity = [[CopyActivity alloc] init];
    MoveActivity *moveActivity = [[MoveActivity alloc] init];
    NewAlbumActivity *newalbumActivity = [[NewAlbumActivity alloc] init];
    //DeleteActivity *deleteActivity = [[DeleteActivity alloc] init];
    
    NSArray *activitys = @[moveActivity, newalbumActivity];//, deleteActivity];
    
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
        currentAction = act;
//        if ( [act isEqualToString:@"com.pixbee.copySharing"] ) {
//            [self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
//        }
        if ( [act isEqualToString:@"com.pixbee.moveSharing"] ) {
            [self showFaceTabBar:YES];
            //[self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
        }
        else if ( [act isEqualToString:@"com.pixbee.newAlbumSharing"] ) {
            [self makeNewFaceTab];
            
        }
//        else if ( [act isEqualToString:@"com.pixbee.deleteSharing"] ) {
//            [self deletePhotos];
//        }
        
        self.activityController = nil;

    }];
}

- (IBAction)closeFaceTabButtonHandler:(id)sender {
    [self showStackImages:NO];
    [self showFaceTabBar:NO];

}

- (IBAction)leftBarButtonHandler:(id)sender {
    if([_segueIdentifier isEqualToString:@"Segue3_1to4_3"]){
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } else {
        [self.sideMenuViewController presentMenuViewController];
    }
    
}



- (void)initFaceTabList
{
    NSArray *users = [SQLManager getAllUsers];
    int faceCount = 0;
    
    int margin = 8;
    int size = 88;
    int y = 4;//29;
    
    for(NSDictionary *userInfo in users) {
        
        int UserID = [userInfo[@"UserID"] intValue];
        UIImage *profileImage = [SQLManager getUserProfileImage:UserID];
        
        CGRect buttonFrame = CGRectMake(margin + faceCount * (margin + size), y, size, size);
        CGSize contentSize = CGSizeMake(margin + faceCount * (margin + size) + size, _faceTabScrollView.frame.size.height);

        [scrollViewCellFrames addObject:NSStringFromCGRect(buttonFrame)];
        
        UIButton_FaceIcon* button = [UIButton_FaceIcon buttonWithType:UIButtonTypeCustom];

        [button setProfileImage:profileImage];

        button.frame = buttonFrame;

        button.UserID = UserID;
        button.index = faceCount;
        button.originRect = button.frame;
        
        [_faceTabScrollView addSubview:button];

        [_faceTabScrollView setContentSize:contentSize];
        
        
        
        faceCount++;
    }
}

- (void)initStackImages
{
    _stackImages.hidden = YES;
    
    [_stackImages addTarget:self action:@selector(imageTouch:withEvent:) forControlEvents:UIControlEventTouchDown];
    [_stackImages addTarget:self action:@selector(imageMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [_stackImages addTarget:self action:@selector(imageEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void)gatteringStackImages
{
 
    NSLog(@"self.faceTabListBar frame = %@", NSStringFromCGRect(self.faceTabListBar.frame));
    _stackImages.frame = CGRectMake(0, 0, 320, 568);
    for(NSIndexPath *indexPath in selectedPhotos)
    {

        ALAsset *asset = self.assets[indexPath.row];
        UIImage *thumbImage = [UIImage imageWithCGImage:[asset thumbnail]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75,75)];
        imgView.image = thumbImage;
        imgView.alpha = 0.9;
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        //[cell addSubview:imgView];

        CGPoint convertedPoint = [self.view convertPoint:cell.center fromView:cell.superview];
        imgView.center = convertedPoint;
        
#warning 이상하게 self.view 에 이미지들 붙이면 facetablistbar 가 사라짐... 아래 구문이 되어야 모이는 애니메이션이 되는데...
        //[self.view addSubview:imgView];
        //[self.view insertSubview:imgView aboveSubview:self.faceTabListBar];
        
        
        [selectedStackImages addObject:imgView];
    }
 }

- (void)attatchStackImages
{
    for(UIImageView *imgView in selectedStackImages)
    {
        imgView.frame = CGRectMake(110, 234, 100, 100);
    }
}

- (void)alignStackImages
{

    NSInteger imageCount = [selectedStackImages count];
    double angle = -0.3;
    
    NSMutableArray *angleArray = [NSMutableArray array];
    
    for(int i = 0; i < imageCount; i++) {
        UIImageView *imgView = [selectedStackImages objectAtIndex:i];
        imgView.frame = CGRectMake(0, 0, 100, 100);
        [_stackImages addSubview:imgView];
        
        angle =  ((double)arc4random() / 0x100000000);
        if(i % 2) angle = angle * -1 ;
        if(i == (imageCount -1)) angle = 0;
        
        [angleArray addObject:@(angle)];
    }

    
    [UIView animateWithDuration:0.25
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for(int i = 0; i < imageCount; i++) {
                             UIImageView *imgView = [selectedStackImages objectAtIndex:i];
                             double viewAngle = [[angleArray objectAtIndex:i] doubleValue];
                             imgView.transform = CGAffineTransformMakeRotation(viewAngle);
                             
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
    

    
}

- (void)showStackImages:(BOOL)show
{
    float duration = 0.3;
    float delay = 0.1;
    
    if(!show){
        duration = 0.1;
        delay = 0.0;
    }
    else {
        [self gatteringStackImages];
    }
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if(show) {
                             _stackImages.frame = CGRectMake(110, 234, 100, 100);  // 다시 보일때 중앙위치에 처음 사이즈로 복귀.
                             _stackImages.hidden = NO;
                             [self attatchStackImages];
                         } else {
                             _stackImages.hidden = YES;
                         }
                     }
                     completion:^(BOOL finished){
                         if(show){
                             [self alignStackImages];
                             
                         } else {
                             for(UIView *view in _stackImages.subviews){
                                 [view removeFromSuperview];
                             }
                         }
                     }];
}


- (void) imageTouch:(id) sender withEvent:(UIEvent *) event
{
    //if(_faceListScrollView.dragging || _faceListScrollView.decelerating) return;
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    
    lastTouchPoint = point;
    
    _stackImages.center = point;

}

- (void) imageMoved:(id)sender withEvent:(UIEvent *) event
{
    //if(_faceListScrollView.dragging || _faceListScrollView.decelerating) return;
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    
    UIControl *control = sender;
    control.center = point;

    if(CGRectContainsPoint (_faceTabListBar.frame, point))
    {
        NSLog(@"Button.point = %@", NSStringFromCGPoint(point));
        
        CGSize contentSize = [_faceTabScrollView contentSize];
        CGPoint contentOffset = [_faceTabScrollView contentOffset];
        CGFloat frameWidth = [_faceTabScrollView frame].size.width;
        
        CGFloat deltaX = ((point.x - lastTouchPoint.x) / [_stackImages bounds].size.width) * [_faceTabScrollView contentSize].width;
        CGPoint newContentOffset = CGPointMake(CLAMP(contentOffset.x + deltaX, 0, contentSize.width - frameWidth), contentOffset.y);
        
        NSLog(@"deltaX = %f / newContentOffset = %@", deltaX, NSStringFromCGPoint(newContentOffset));
        
        lastTouchPoint = point;
        
        
        if(TRUE) //newContentOffset.x >= 0 &&  newContentOffset.x < contentSize.width)
        {
            NSInteger subViewCount = [_faceTabScrollView.subviews count] - 1;
            if(subViewCount > 3) {
                [_faceTabScrollView setContentOffset:newContentOffset animated:NO];
            }
            
            
            
//            lastTouchPoint = point;
            
            
            //NSInteger cellCount = 0;
#warning 왜 subViewCount가 1개 더 붙는지 모르겠다...
            
            //NSInteger subViewCount = [_faceTabScrollView.subviews count] - 1;
            

            
            currentPosition = round((point.x +  newContentOffset.x )/ 96.0);
            NSLog(@"CurrentPosition = %d", currentPosition);
            
            if(currentPosition >= 0 && currentPosition < subViewCount && currentPosition != previousPosiotion )
            {
                id cellObject = [_faceTabScrollView.subviews objectAtIndex:currentPosition];
                
                if([NSStringFromClass([cellObject class]) isEqualToString:@"UIButton_FaceIcon"])
                {
                  
                    for(NSInteger i = 0; i < subViewCount; i++){
                        //for(UIView *cell in _faceTabScrollView.subviews){
                        UIButton_FaceIcon *cell = (UIButton_FaceIcon *)[_faceTabScrollView.subviews objectAtIndex:i];
                        NSString *cellRect = [scrollViewCellFrames objectAtIndex:i];
                        cell.frame = CGRectFromString(cellRect);
                        //cellCount++;
                    }
                    
                    UIButton_FaceIcon *cell = (UIButton_FaceIcon *)cellObject;
                    
                    //if(currentPosition != previousPosiotion) {
                        [UIView animateWithDuration:0.2 animations:^{
                            CGPoint cellCenter = cell.center;
                            CGRect cellFrame = cell.frame;
                            cell.frame = CGRectMake(cellFrame.origin.x - 10, cellFrame.origin.y - 10, cellFrame.size.width * 1.3, cellFrame.size.height * 1.3);
                            cell.center = cellCenter;
                            
                        } completion:^(BOOL finished) {
                            currentUserID = cell.UserID;
                            
                        }];
                    //}

                    
                    previousPosiotion =  currentPosition;
                    
                    
                } else {
                    return;
                }
                
                NSLog(@"newContentOffset = %@ / currentPosition = %d / userID = %d", NSStringFromCGPoint(newContentOffset), currentPosition, currentUserID);
            }
            

            
        }
 
        
    }

}

- (void) imageEnd:(id) sender withEvent:(UIEvent *) event
{
    //if(_faceTabScrollView.dragging || _faceTabScrollView.decelerating) return;
    
    lastTouchPoint = CGPointZero;
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    if(CGRectContainsPoint (_faceTabListBar.frame, point))
    {

        [self showStackImages:NO];
        [self showFaceTabBar:NO];
        
        
        if(currentUserID > 0) [self addPhotosToFaceTab:currentUserID];
        
        currentUserID = -1;
        
    }

}


- (void)makeNewFaceTab
{
    NSArray *result = [SQLManager newUser];
    NSDictionary *user = [result objectAtIndex:0];
    //NSString *UserName = [user objectForKey:@"UserName"];
    int UserID = [[user objectForKey:@"UserID"] intValue];
    int photoCount = 0;
    
    for(NSIndexPath *indexPath in selectedPhotos)
    {
        photoCount++;

        ALAsset *asset = self.assets[indexPath.row];
        
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
    
    if(EDIT_MODE) [self toggleEdit];
    
    if([_segueIdentifier isEqualToString:@"Segue3_1to4_3"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MeunViewControllerEventHandler"
                                                            object:self
                                                          userInfo:@{@"moveTo":@"MainDashBoard"}];

    }
    
}

- (void)addPhotosToFaceTab:(int)UserID
{
    for(NSIndexPath *indexPath in selectedPhotos)
    {

        ALAsset *asset = self.assets[indexPath.row];
        
        [SQLManager saveNewUserPhotoToDB:asset users:@[@(UserID)]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doAction
{
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

                ALAsset *asset = self.assets[indexPath.row];
                
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

            ALAsset *asset = self.assets[indexPath.row];
            

            [SQLManager saveNewUserPhotoToDB:asset users:@[@(UserID)]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    else {
        // 필터 화면으로 이동
        [self performSegueWithIdentifier:SEGUE_GO_FILTER sender:self];
    }
}

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

- (void)showFaceTabBar:(BOOL)show
{
    CGRect rect = [UIScreen mainScreen].bounds;
    CGRect frame = self.faceTabListBar.frame;
    
    if(show){
        frame = CGRectMake(frame.origin.x, rect.size.height - frame.size.height, frame.size.width, frame.size.height);
        
    } else {
        
        frame = CGRectMake(frame.origin.x, rect.size.height, frame.size.width, frame.size.height);
    }
    
    if(show){
        if(EDIT_MODE) [self showToolBar:NO];
    }
    
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.faceTabListBar.frame = frame;
                     }
                     completion:^(BOOL finished){
                         if(!show){
                             if(EDIT_MODE) {
                                 
                                 [selectedPhotos removeAllObjects];
                                 [selectedStackImages removeAllObjects];
                                 
                                 [self refreshSelectedPhotCountOnNavTilte];
                                 [_collectionView reloadData];
                                 
                                 [self showToolBar:YES];
                                 
                              }
                         }
                         else {
                             if(EDIT_MODE){
                                 [self showStackImages:YES];

                             }
                         }
                     }];

}

- (IBAction)rightBarButtonHandler:(id)sender {
    
    [self toggleEdit];

}

- (void)toggleEdit
{
    EDIT_MODE = !EDIT_MODE;
    
    if(EDIT_MODE){
        self.navigationItem.rightBarButtonItem.image = nil;
        self.navigationItem.rightBarButtonItem.title = @"Cancel";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                            object:self
                                                          userInfo:@{@"panGestureEnabled":@"NO"}];
        backBtn.enabled = NO;
        
    }
    else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RootViewControllerEventHandler"
                                                            object:self
                                                          userInfo:@{@"panGestureEnabled":@"YES"}];
        backBtn.enabled = YES;
        
        [self showStackImages:NO];
        [self showFaceTabBar:NO];

        [selectedStackImages removeAllObjects];
        
        [selectedPhotos removeAllObjects];
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit"];
    }
    
    [self showToolBar:EDIT_MODE];
    //self.collectionView.allowsSelection = EDIT_MODE;
    [self.collectionView setAllowsMultipleSelection:EDIT_MODE];
    [self.collectionView reloadData];

    
    [self refreshSelectedPhotCountOnNavTilte];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_FILTER]){
        self.navigationController.navigationBarHidden = NO;
        PBFilterViewController *destination = segue.destinationViewController;
        
        NSMutableArray *photoDatas = [NSMutableArray array];
        
        for(NSIndexPath *indexPath in selectedPhotos){

            ALAsset *asset = self.assets[indexPath.row];
            [photoDatas addObject:asset];
            
        }
        
        destination.photos = photoDatas;
        
    }
}






@end
