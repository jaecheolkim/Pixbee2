//
//  IndividualGalleryController.m
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "IndividualGalleryController.h"
#import "GalleryViewCell.h"
#import "GalleryHeaderView.h"
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

@interface IndividualGalleryController ()
<UICollectionViewDataSource, UICollectionViewDelegate,
IDMPhotoBrowserDelegate, FBFriendControllerDelegate,
UserCellDelegate, GalleryViewCellDelegate>
{
    NSMutableArray *selectedPhotos;
    NSDictionary *userInfo;
    NSString *currentAction;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UserCell *userProfileView;
@property (strong, nonatomic) GalleryViewCell *selectedCell;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) FBFriendController *friendPopup;
@property (strong, nonatomic) IBOutlet UIButton *importView;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) UIActivityViewController *activityController;

- (IBAction)editButtonClickHandler:(id)sender;
- (IBAction)albumButtonClickHandler:(id)sender;
- (IBAction)shareButtonClickHandler:(id)sender;

@end

@implementation IndividualGalleryController

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
    
    _shareButton.enabled = NO;
}

- (void)refreshInfo
{
    self.usersPhotos = [SQLManager getUserPhotos:_UserID];
    
    userInfo = [self.usersPhotos objectForKey:@"user"];
    NSLog(@"userInfo = %@", userInfo);
    
	// Do any additional setup after loading the view.
    selectedPhotos = [NSMutableArray array];
    
    self.photos = [self.usersPhotos objectForKey:@"photos"];
    self.user = [self.usersPhotos objectForKey:@"user"];
    
    [self.userProfileView.borderView removeFromSuperview];
    self.userProfileView.borderView = nil;
    [self.userProfileView updateCell:self.user count:[self.photos count]];
    self.userProfileView.delegate = self;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 3, 0);
    
    [self.collectionView reloadData];
    [self.userProfileView.borderView removeFromSuperview];
    self.userProfileView.borderView = nil;
    
    self.importView.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.importView.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *buttonTitle = [NSString stringWithFormat:@"Message Here\nPlease import\nmore %@'s Photo", [self.user objectForKey:@"UserName"]];
    self.importView.titleLabel.text = buttonTitle;
 
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshInfo];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
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
#pragma mark PSTCollectionViewDataSource stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (([self.photos count] > 0) && [[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [self.photos count];
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (([self.photos count] > 0) && [[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [[self.photos objectAtIndex:section] count];
    }
    
    return [self.photos count];
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *reusableview = nil;
//    
//    if (kind == UICollectionElementKindSectionHeader) {
//        GalleryHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GalleryHeaderView" forIndexPath:indexPath];
//        NSString *title = [[NSString alloc]initWithFormat:@"Photos Group #%i", indexPath.section + 1];
//        headerView.leftLabel.text = title;
//        UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
//        headerView.backgroundImage.image = headerImage;
//        
//        reusableview = headerView;
//    }
//    
//    if (kind == UICollectionElementKindSectionFooter) {
//        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
//        
//        reusableview = footerview;
//    }
//    
//    return reusableview;
//}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"GalleryViewCell";
    
    GalleryViewCell *cell = (GalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    //[cell setIndexPath:indexPath];
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
        GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell showSelectIcon:YES];
        [cell setNeedsDisplay];
        
        [self refreshSelectedPhotCountOnNavTilte];
    }
    else {
        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        [self performSegueWithIdentifier:SEGUE_4_1_TO_5_1 sender:self];
        
//        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
//        for (NSDictionary *photoinfo in self.photos) {
//            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//            [idmPhotos addObject:photo];
//        }
        
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
        NSString *photo = [photoinfo objectForKey:@"AssetURL"];
        [idmPhotos addObject:photo];
        
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        browser.delegate = self;
        [browser setInitialPageIndex:indexPath.row];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
//        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.scaleImage = self.selectedCell.photoImageView.image;
        
//        [self.navigationController p presentedViewController:browser];
        
        // Show
        [self presentViewController:browser animated:YES completion:nil];
        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos removeObject:indexPath];
        [self refreshSelectedPhotCountOnNavTilte];
    }
    
    // UI
    GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell showSelectIcon:NO];
    [cell setNeedsDisplay];
}



//- (IBAction)shareButtonTouched:(id)sender {
//    if (shareEnabled) {
//        
//        // Post selected photos to Facebook
//        if ([selectedRecipes count] > 0) {
//            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//                
//                [controller setInitialText:@"Check out my recipes!"];
//                for (NSString *recipePhoto in selectedRecipes) {
//                    [controller addImage:[UIImage imageNamed:recipePhoto]];
//                }
//                
//                [self presentViewController:controller animated:YES completion:Nil];
//            }
//        }
//        
//        // Deselect all selected items
//        for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
//            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
//        }
//        
//        // Remove all items from selectedRecipes array
//        [selectedRecipes removeAllObjects];
//        
//        // Change the sharing mode to NO
//        shareEnabled = NO;
//        self.collectionView.allowsMultipleSelection = NO;
//        self.shareButton.title = @"Share";
//        [self.shareButton setStyle:UIBarButtonItemStylePlain];
//        
//    } else {
//        
//        // Change shareEnabled to YES and change the button text to DONE
//        shareEnabled = YES;
//        self.collectionView.allowsMultipleSelection = YES;
//        self.shareButton.title = @"Upload";
//        [self.shareButton setStyle:UIBarButtonItemStyleDone];
//        
//    }
//}
//
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Check delegate: should cell %@ be selected?", [self formatIndexPath:indexPath]);
//    return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Check delegate: should cell %@ be deselected?", [self formatIndexPath:indexPath]);
//    return YES;
//}

#pragma mark GalleryViewCellDelegate

- (void)cellTap:(GalleryViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSLog(@"tapItem: %d %@", (int)indexPath.row, cell.selected?@"YES":@"NO");
 
    if (self.collectionView.allowsMultipleSelection) {
        if(!cell.selected){
            [selectedPhotos addObject:indexPath];
            [cell showSelectIcon:YES];
        }
        else {
            [selectedPhotos removeObject:indexPath];
            [cell showSelectIcon:NO];
        }

        [cell setNeedsDisplay];
        [self refreshSelectedPhotCountOnNavTilte];
        cell.selected = !cell.selected;
    }
    else {
        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
 
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
        NSString *photo = [photoinfo objectForKey:@"AssetURL"];
        [idmPhotos addObject:photo];
        
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        browser.delegate = self;
        [browser setInitialPageIndex:indexPath.row];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        //        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.scaleImage = self.selectedCell.photoImageView.image;
        
        //        [self.navigationController p presentedViewController:browser];
        
        // Show
        [self presentViewController:browser animated:YES completion:nil];
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    }


}

- (void)cellPressed:(GalleryViewCell *)cell
{
    if(self.activityController) return;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSLog(@"longPressItem: %d", (int)indexPath.row);
    [selectedPhotos addObject:indexPath];
    [self shareButtonClickHandler:nil];
}


#pragma mark UserCellDelegate

- (void)editUserCell:(UserCell *)cell {
    [self.userProfileView setEditing:YES animated:NO];
}

- (void)doneUserCell:(UserCell *)cell {
    [self frientList:cell appear:NO];
    [self.userProfileView setEditing:NO animated:NO];
}

- (void)deleteUserCell:(UserCell *)cell {
    [self doneUserCell:cell];
    
    // 여기서 삭제시 어떻게 처리하는지 구현
    
    // 여기도 DB 업데이트
}

- (void)frientList:(UserCell *)cell appear:(BOOL)show {
    if (show) {
        [self popover:cell.editButton];
    }
    else {
        [self.friendPopup disAppearPopup];
        self.friendPopup = nil;
    }
}

#pragma mark FBFriendControllerDelegate

- (void)searchFriend:(UserCell *)cell name:(NSString *)name {
    [self.friendPopup handleSearchForTerm:name];
}

- (void)selectedFBFriend:(NSDictionary *)friend {
    self.userProfileView.userName.text = [friend objectForKey:@"name"];
    self.userProfileView.inputName.text = @"";
    NSString *picurl = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    
    [self.userProfileView.userImage setImageWithURL:[NSURL URLWithString:picurl]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    [self.userProfileView doneButtonClickHandler:nil];
    // DB에 저장하는 부분 추가
}

-(void)popover:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBFriendController *controller = (FBFriendController *)[storyboard instantiateViewControllerWithIdentifier:@"FBFriendController"];
    
    controller.delegate = self;
    CGPoint convertedPoint = [self.view convertPoint:((UIButton *)sender).center fromView:((UIButton *)sender).superview];
    int x = convertedPoint.x - 140;
    int y = convertedPoint.y + 14;
    
    [controller appearPopup:CGPointMake(x, y) reverse:NO];
    
    self.friendPopup = controller;
}

#pragma mark -
#pragma mark ButtonAction
- (IBAction)editButtonClickHandler:(id)sender {
    self.collectionView.allowsMultipleSelection = !self.collectionView.allowsMultipleSelection;
    
    if (self.collectionView.allowsMultipleSelection) {
        self.navigationItem.rightBarButtonItem.title = @"Close";
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.shareButton.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"Select";
        
        for (NSIndexPath *indexPath in selectedPhotos) {
            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell showSelectIcon:NO];
            [cell setNeedsDisplay];
        }
        
        [selectedPhotos removeAllObjects];
        [self refreshSelectedPhotCountOnNavTilte];
     }
}

- (IBAction)albumButtonClickHandler:(id)sender {
}

- (IBAction)shareButtonClickHandler:(id)sender {
    
    NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:[selectedPhotos count]];
    
    for (NSIndexPath *indexPath in selectedPhotos) {
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        NSLog(@"Selected Photo = %@", photo);
        NSString *imagePath = [photo objectForKey:@"AssetURL"];
        [activityItems addObject:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imagePath]];
    }
    
    NSLog(@"selectedPhoto = %@", selectedPhotos);
    NSLog(@"userInfo = %@",userInfo);
    
    CopyActivity *copyActivity = [[CopyActivity alloc] init];
    MoveActivity *moveActivity = [[MoveActivity alloc] init];
    NewAlbumActivity *newalbumActivity = [[NewAlbumActivity alloc] init];
    DeleteActivity *deleteActivity = [[DeleteActivity alloc] init];
    
    NSArray *activitys = @[copyActivity, moveActivity, newalbumActivity, deleteActivity];
    
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
    
//    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 320, 20)];
//    tabView.backgroundColor = [UIColor redColor];
//    
//    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 20, 20)];
//    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(290, -10, 32, 40)];
//    [deleteButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
//    
//    shareButton.backgroundColor = [UIColor blueColor];
//    deleteButton.backgroundColor = [UIColor blueColor];
//    [tabView addSubview:shareButton];
//    [tabView addSubview:deleteButton];
//    
//    [activityController.view addSubview:tabView];
    
    [self presentViewController:self.activityController
                       animated:YES
                     completion:^
                    {
//                        NSLog(@"%@", self.activityController);
//                        
//                        UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, 320, 30)];
//                        tabView.backgroundColor = [UIColor whiteColor];
//                        tabView.alpha = 0.9;
//
//                        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
//                        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(280, -5, 32, 40)];
//                        [deleteButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
//
//                        shareButton.backgroundColor = [UIColor blueColor];
//                        [tabView addSubview:shareButton];
//                        [tabView addSubview:deleteButton];
//                        [deleteButton addTarget:self action:@selector(deletePhotos:) forControlEvents:UIControlEventTouchUpInside];
//                        
//                        [self.activityController.view addSubview:tabView];
                        
                    }];
    
    [self.activityController setCompletionHandler:^(NSString *act, BOOL done) {
        currentAction = act;
        if ( [act isEqualToString:@"com.pixbee.copySharing"] ) {
            if (self.importView) {
                [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
            }
            else {
                [self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
            }
         }
         else if ( [act isEqualToString:@"com.pixbee.moveSharing"] ) {
             if (self.importView) {
                 [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
             }
             else {
                 [self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
             }
         }
         else if ( [act isEqualToString:@"com.pixbee.newAlbumSharing"] ) {
             if (self.importView) {
                 [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
             }
             else {
                 [self newFaceTab];
             }
             
          }
         else if ( [act isEqualToString:@"com.pixbee.deleteSharing"] ) {
//             if (self.importView) {
//                 [self performSegueWithIdentifier:SEGUE_4_2_TO_3_2 sender:self];
//             }
//             else {
//                 [self deletePhotos];
//             }
             
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

- (void)newFaceTab {
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
        
        NSArray *result = [SQLManager newUser];
        NSDictionary *user = [result objectAtIndex:0];
        //NSString *UserName = [user objectForKey:@"UserName"];
        __block int UserID = [[user objectForKey:@"UserID"] intValue];
        __block int photoCount = 0;
        
        for(NSIndexPath *indexPath in selectedPhotos){
            
            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
            NSLog(@"photo data = %@", photo);

            [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:photo[@"AssetURL"]]
            resultBlock:^(ALAsset *asset)
            {
                
                photoCount++;
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
            failureBlock:^(NSError *error) {
                NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
            }];
        }
        
#warning 얼굴인식 TrainModel 업데이트 필요. (추가된 얼굴들에 대하여..)

        [self.navigationController popViewControllerAnimated:YES];
        //[self performSegueWithIdentifier:SEGUE_4_1_TO_3_2 sender:self];
    }

}

- (void)copyPhotos:(int)destUserID
{
    [self.collectionView performBatchUpdates:^{
        for (NSIndexPath *indexPath in selectedPhotos) {
            // UI
            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell showSelectIcon:NO];
            
            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
            int photoID = [[photo objectForKey:@"PhotoID"] intValue];
            int FaceNo = [[photo objectForKey:@"FaceNo"] intValue];
            NSLog(@"photo = %@", photo);
            
            [SQLManager newUserPhotosWith:destUserID withPhoto:photoID withFace:FaceNo];

        }
    } completion:^(BOOL finished) {
        self.activityController = nil;
        NSLog(@"Operation : %@ complete!", currentAction);
        [selectedPhotos removeAllObjects];
        [self.collectionView reloadData];
        [self refreshSelectedPhotCountOnNavTilte];
    }];
}

- (void)movePhotos:(int)destUserID
{
    [self.collectionView performBatchUpdates:^{
        for (NSIndexPath *indexPath in selectedPhotos) {
            // UI
            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell showSelectIcon:NO];
            
            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
            int userID = [[photo objectForKey:@"UserID"] intValue];
            int photoID = [[photo objectForKey:@"PhotoID"] intValue];
            int FaceNo = [[photo objectForKey:@"FaceNo"] intValue];
            NSLog(@"photo = %@", photo);
            
            [SQLManager newUserPhotosWith:destUserID withPhoto:photoID withFace:FaceNo];
            
            [SQLManager deleteUserPhoto:userID  withPhoto:photoID];
            [self.photos removeObjectAtIndex:indexPath.row];
        }
        
        [self.collectionView deleteItemsAtIndexPaths:selectedPhotos];

        [self.userProfileView updateCell:self.user count:[self.photos count]];
        
    } completion:^(BOOL finished) {
        self.activityController = nil;
        NSLog(@"Operation : %@ complete!", currentAction);
        [selectedPhotos removeAllObjects];
        [self.collectionView reloadData];
        [self refreshSelectedPhotCountOnNavTilte];
    }];
}

- (void)deletePhotos
{
    if(IsEmpty(selectedPhotos)) return;
    
    [self.activityController dismissViewControllerAnimated:YES completion:nil];
    
    [self.collectionView performBatchUpdates:^{
        for (NSIndexPath *indexPath in selectedPhotos) {

            if( indexPath.row < [self.photos count]){
                GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell showSelectIcon:NO];
                NSLog(@"selected:%d / photos count:%d", indexPath.row, [self.photos count]);
                NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
                int userID = [[photo objectForKey:@"UserID"] intValue];
                int photoID = [[photo objectForKey:@"PhotoID"] intValue];
                NSLog(@"photo = %@", photo);
                [SQLManager deleteUserPhoto:userID  withPhoto:photoID];
                
                [self.photos removeObjectAtIndex:indexPath.row];
            }

        }
        
        [self.collectionView deleteItemsAtIndexPaths:selectedPhotos];
        
        [self.userProfileView updateCell:self.user count:[self.photos count]];
        
    } completion:^(BOOL finished) {
        self.activityController = nil;
        NSLog(@"deletePhotos complete!");
        [selectedPhotos removeAllObjects];
        //[self editButtonClickHandler:nil];
        [self.collectionView reloadData];
        [self refreshSelectedPhotCountOnNavTilte];
        
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.collectionView.allowsMultipleSelection) {
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"segue.identifier = %@", segue.identifier);
    
    if([segue isKindOfClass:[OpenPhotoSegue class]]) {
        // Set the start point for the animation to center of the button for the animation
        CGPoint point2 = [self.view convertPoint:self.selectedCell.center fromView:self.collectionView];
        ((OpenPhotoSegue *)segue).originatingPoint = point2;
    }
    else if ([segue.identifier isEqualToString:SEGUE_4_1_TO_3_2]){
        AlbumSelectionController *destination = segue.destinationViewController;

        
        NSMutableArray *photoDatas = [NSMutableArray array];
        
        for(NSIndexPath *indexPath in selectedPhotos){
            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
            [photoDatas addObject:photo];
        }
        
        destination.photos = photoDatas;
        destination.operateIdentifier = currentAction;
        
    }
    else if([segue.identifier isEqualToString:@"Segue4_2to6_1"]) // 사진을 직접 개인 앨범에 추가하기 위해 All Photos 로 이동.
    {
        AllPhotosController *destViewController = segue.destinationViewController;
        destViewController.segueIdentifier = segue.identifier;
        destViewController.operateIdentifier = @"add Photos";
        destViewController.userInfo = userInfo;
    }
}


//unwindSegue handler from AlbumSelectionController.
- (IBAction)unwindToIndividualGallery:(UIStoryboardSegue *)unwindSegue
{
    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
    //만약에 copy or move operation을 진행하고 다른 user의 facetab을 선택하고 오면
    if ([sourceViewController isKindOfClass:[AlbumSelectionController class]])
    {
        AlbumSelectionController *controller = (AlbumSelectionController *)unwindSegue.sourceViewController;
        NSString *destOperation = controller.operateIdentifier;
        NSDictionary *destUserInfo = controller.selectedUserInfo;
        //NSArray *destPhotos = controller.photos;
        
        int destUserID = [destUserInfo[@"UserID"] intValue];
        
        if(destUserID ==  [userInfo[@"UserID"] intValue]){
            NSLog(@"동일 유저에 대한 명령 취소..");
            return;
        }
        
        if([destOperation isEqualToString:@"com.pixbee.moveSharing"]) {
            [self movePhotos:destUserID];
        }
        else if ([destOperation isEqualToString:@"com.pixbee.copySharing"]) {
            [self copyPhotos:destUserID];
        }
        
    }
    else if([sourceViewController isKindOfClass:[AllPhotosController class]]) {
        //AlbumSelectionController *controller = (AlbumSelectionController *)unwindSegue.sourceViewController;
        
    }


}


- (IBAction)backButtonClickHandler:(id)sender {
    [self dismissCustomSegueViewControllerWithCompletion:^(BOOL finished) {
        NSLog(@"Dismiss complete!");
    }];
}

// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {

    // Instantiate a new CustomUnwindSegue
    OpenPhotoUnwindSegue *segue = [[OpenPhotoUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    // Set the target point for the animation to the center of the button in this VC
    CGPoint point = [self.collectionView convertPoint:self.selectedCell.center toView:self.view];
    segue.targetPoint = point;
    return segue;
}


@end
