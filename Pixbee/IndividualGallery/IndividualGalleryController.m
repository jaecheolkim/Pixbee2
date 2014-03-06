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
#import "FXBlurView.h"

@interface IndividualGalleryController ()
<UICollectionViewDataSource, UICollectionViewDelegate,
IDMPhotoBrowserDelegate, FBFriendControllerDelegate,
UserCellDelegate, GalleryViewCellDelegate>
{
    BOOL EDIT_MODE;
    int totalCellCount;
    NSIndexPath *currentIndexPath;
    GalleryViewCell *currentSelectedCell;
    
    NSMutableArray *selectedPhotos;
    NSString *currentAction;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UserCell *userProfileView;
@property (strong, nonatomic) GalleryViewCell *selectedCell;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) FBFriendController *friendPopup;
@property (strong, nonatomic) IBOutlet UIButton *importView;
//@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) UIActivityViewController *activityController;
//@property (weak, nonatomic) IBOutlet FXBlurView *toolbar;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)editButtonClickHandler:(id)sender;
- (IBAction)albumButtonClickHandler:(id)sender;
//- (IBAction)shareButtonClickHandler:(id)sender;
- (IBAction)shareButtonHandler:(id)sender;

@end

@implementation IndividualGalleryController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.tintColor = COLOR_RED;
//    self.navigationController.navigationBar.alpha = 0.7;
    
    [self refreshNavigationBarColor:COLOR_RED];
    
//    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
//    if ([[ver objectAtIndex:0] intValue] >= 7) {
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:100/255.0f green:174/255.0f blue:235/255.0f alpha:0.4f];
//        self.navigationController.navigationBar.translucent = NO;
//    }else{
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:100/255.0f green:174/255.0f blue:235/255.0f alpha:0.4f];
//    }
    
    
    [self refreshBGImage:nil];

    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = self.bgImageView;

    _shareButton.enabled = NO;
    
    self.userProfileView.delegate = self;
    self.title = @"ALBUM";
}

- (void)refreshInfo
{
    self.usersPhotos = [SQLManager getUserPhotos:_UserID];
    
//    self.user = [self.usersPhotos objectForKey:@"user"];
//    NSLog(@"userInfo = %@", self.user);
    
	// Do any additional setup after loading the view.
    selectedPhotos = [NSMutableArray array];
    
    self.photos = [self.usersPhotos objectForKey:@"photos"];
    self.user = [self.usersPhotos objectForKey:@"user"];
    
    [self.userProfileView.borderView removeFromSuperview];
    self.userProfileView.borderView = nil;
    [self.userProfileView updateCell:self.user count:[self.photos count]];
    
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 3, 0);
    
    [self.collectionView reloadData];
    [self.userProfileView.borderView removeFromSuperview];
    self.userProfileView.borderView = nil;
    
    self.importView.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.importView.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSLog(@"title - %@", self.importView.titleLabel.text);
    NSString *buttonTitle = [NSString stringWithFormat:@"Please import\nmore %@'s Photo", [self.user objectForKey:@"UserName"]];
    self.importView.titleLabel.text = buttonTitle;
 
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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshInfo];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.navigationController.navigationBarHidden = NO;
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
    cell.photo = photo;
    
    if(EDIT_MODE){
        cell.selectIcon.hidden = NO;
        
        if ([selectedPhotos containsObject:indexPath]) {
            //[cell showSelectIcon:YES];
           cell.selectIcon.image = [UIImage imageNamed:@"checked"];
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
        [self presentViewController:browser animated:YES completion:nil];
    }
    
//    if (self.collectionView.allowsMultipleSelection) {
//        [selectedPhotos addObject:indexPath];
//        
//        // UI
//        GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        [cell showSelectIcon:YES];
//        [cell setNeedsDisplay];
//        
//        [self refreshSelectedPhotCountOnNavTilte];
//    }
//    else {
//        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
////        [self performSegueWithIdentifier:SEGUE_4_1_TO_5_1 sender:self];
//        
//        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
//        for (NSDictionary *photoinfo in self.photos) {
//            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//            [idmPhotos addObject:photo];
//        }
//        
////        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
////        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
////        NSString *photo = [photoinfo objectForKey:@"AssetURL"];
////        [idmPhotos addObject:photo];
//        
//        // Create and setup browser
//        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
//        browser.delegate = self;
//        [browser setInitialPageIndex:indexPath.row];
//        browser.displayActionButton = NO;
//        browser.displayArrowButton = NO;
////        browser.displayArrowButton = YES;
//        browser.displayCounterLabel = YES;
//        browser.scaleImage = self.selectedCell.photoImageView.image;
//        
////        [self.navigationController p presentedViewController:browser];
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
        self.selectedCell = cell;//(GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
 
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
        for (NSDictionary *photoinfo in self.photos) {
            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
            [idmPhotos addObject:photo];
        }

        
//        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
//        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
//        NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//        [idmPhotos addObject:photo];
        
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
    [self shareButtonHandler:nil];
}


#pragma mark UserCellDelegate

- (void)editUserCell:(UserCell *)cell {
    [self.userProfileView setEditing:YES animated:NO];
}

- (void)doneUserCell:(UserCell *)cell {
    
    NSString *inputUserName = cell.inputName.text;
    int cellUserID = [[cell.user objectForKey:@"UserID"] intValue];
    
    if(!IsEmpty(inputUserName)){
        //Update DB
        NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(cellUserID), @"UserName" :inputUserName}];
        if(!IsEmpty(result)){
            cell.userName.text = inputUserName;
            
//            NSDictionary *users = [self.usersPhotos objectAtIndex:indexPath.row];
//            NSArray *photos = users[@"photos"];
//            NSDictionary *user =result[0];
//            [self.usersPhotos replaceObjectAtIndex:indexPath.row withObject:@{@"user":user,@"photos":photos}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumContentsViewEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"changedGalleryDB"}];
            
        }
    }

    
    [self frientList:cell appear:NO];
    [self.userProfileView setEditing:NO animated:NO];
}

- (void)deleteUserCell:(UserCell *)cell {
    [self.userProfileView setEditing:NO animated:NO];
    
    UIActionSheet *deleteMenu = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              destructiveButtonTitle:NSLocalizedString(@"Delete selected FaceTag", @"")
                                                   otherButtonTitles:nil];
	[deleteMenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index = %d", (int)buttonIndex);
    if(buttonIndex == 0) {
         int UserID = [[self.userProfileView.user objectForKey:@"UserID"] intValue];
        if([SQLManager deleteUser:UserID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumContentsViewEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"changedGalleryDB"}];
            
            [self.navigationController popViewControllerAnimated:YES];
 
        } else {
            NSLog(@"Can't delete Users db row..");
#warning Error message 뿌려주기
        }

    }
    
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
    
    int cellUserID = [[self.user objectForKey:@"UserID"] intValue];
    NSString *cellUserName = [self.user objectForKey:@"UserName"];
    NSString *cellfbID = [self.user objectForKey:@"fbID"];
    
    NSString *fbUserName = [friend objectForKey:@"name"];
    NSString *fbID = [friend objectForKey:@"id"];

    
    self.userProfileView.userName.text = [friend objectForKey:@"name"];
    self.userProfileView.inputName.text = @"";
    
    NSString *picurl;// = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    
    id picture = [friend objectForKey:@"picture"];
    if(!IsEmpty(picture)){
        picurl = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    } else {
        //    http://graph.facebook.com/[user id]/picture?type=large     -------------->    for larger image
        //    http://graph.facebook.com/[user id]/picture?type=smaller   -------------->    for smaller image
        //    http://graph.facebook.com/[user id]/picture?type=square     -------------->    for square image
        
        picurl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",friend[@"id"]];
    }
    
    [self.userProfileView.userImage setImageWithURL:[NSURL URLWithString:picurl]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    

    NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(cellUserID), @"UserName" : fbUserName,
                                                @"UserNick" : fbUserName,  @"UserProfile" : picurl,
                                                @"fbID" : fbID, @"fbName" : fbUserName,
                                                @"fbProfile" : picurl }];
    
    NSLog(@"result = %@", result);
    
    [self.userProfileView doneButtonClickHandler:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumContentsViewEventHandler"
                                                        object:self
                                                      userInfo:@{@"Msg":@"changedGalleryDB"}];
    // DB에 저장하는 부분 추가
}

-(void)popover:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBFriendController *controller = (FBFriendController *)[storyboard instantiateViewControllerWithIdentifier:@"FBFriendController"];
    
    controller.delegate = self;
    CGPoint convertedPoint = [self.view convertPoint:((UIButton *)sender).center fromView:((UIButton *)sender).superview];
    int x = convertedPoint.x - 150;
    int y = convertedPoint.y + 14;
    
    [controller appearPopup:CGPointMake(x, y) reverse:NO];
    
    self.friendPopup = controller;
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
        self.navigationItem.rightBarButtonItem.image = nil;
        self.navigationItem.rightBarButtonItem.title = @"Cancel";
        
    }
    else {
        [selectedPhotos removeAllObjects];
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit"];
    }
    
    [self showToolBar:EDIT_MODE];
    [self.collectionView setAllowsMultipleSelection:EDIT_MODE];
    [self.collectionView reloadData];
    
//    
//    
//    self.collectionView.allowsMultipleSelection = !self.collectionView.allowsMultipleSelection;
//    
//    
//    if (self.collectionView.allowsMultipleSelection) {
//        self.navigationItem.rightBarButtonItem.image = nil;
//        self.navigationItem.rightBarButtonItem.title = @"Close";
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             self.shareButton.alpha = 1.0;
//                         }
//                         completion:^(BOOL finished){
//                             
//                         }];
//        
//    }
//    else {
//        self.navigationItem.rightBarButtonItem.title = nil;
//        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit"];
//        
//        for (NSIndexPath *indexPath in selectedPhotos) {
//            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//            [cell showSelectIcon:NO];
//            [cell setNeedsDisplay];
//        }
//        
//        [selectedPhotos removeAllObjects];
//        [self refreshSelectedPhotCountOnNavTilte];
//     }
//    
//    [self.collectionView reloadData];
}

- (IBAction)albumButtonClickHandler:(id)sender {
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
    

    [self presentViewController:self.activityController
                       animated:YES
                     completion:^
                    {

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
    
    [self refresh];
    
//    [self.collectionView performBatchUpdates:^{
//        for (NSIndexPath *indexPath in selectedPhotos) {
//            // UI
//            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//            [cell showSelectIcon:NO];
//            
//            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
//            int photoID = [[photo objectForKey:@"PhotoID"] intValue];
//            int FaceNo = [[photo objectForKey:@"FaceNo"] intValue];
//            NSLog(@"photo = %@", photo);
//            
//            [SQLManager newUserPhotosWith:destUserID withPhoto:photoID withFace:FaceNo];
//
//        }
//    } completion:^(BOOL finished) {
//        self.activityController = nil;
//        NSLog(@"Operation : %@ complete!", currentAction);
//        [selectedPhotos removeAllObjects];
//        [self.collectionView reloadData];
//        [self refreshSelectedPhotCountOnNavTilte];
//    }];
}

- (void)movePhotos:(int)destUserID
{
    if(IsEmpty(selectedPhotos)) return;
    
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
        //[self.photos removeObjectAtIndex:indexPath.row];
    }

    [self refresh];
    
//    [self.collectionView performBatchUpdates:^{
//        for (NSIndexPath *indexPath in selectedPhotos) {
//            // UI
//            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//            [cell showSelectIcon:NO];
//            
//            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
//            int userID = [[photo objectForKey:@"UserID"] intValue];
//            int photoID = [[photo objectForKey:@"PhotoID"] intValue];
//            int FaceNo = [[photo objectForKey:@"FaceNo"] intValue];
//            NSLog(@"photo = %@", photo);
//            
//            [SQLManager newUserPhotosWith:destUserID withPhoto:photoID withFace:FaceNo];
//            
//            [SQLManager deleteUserPhoto:userID  withPhoto:photoID];
//            [self.photos removeObjectAtIndex:indexPath.row];
//        }
//        
//        [self.collectionView deleteItemsAtIndexPaths:selectedPhotos];
//
//        [self.userProfileView updateCell:self.user count:[self.photos count]];
//        
//    } completion:^(BOOL finished) {
//        self.activityController = nil;
//        NSLog(@"Operation : %@ complete!", currentAction);
//        [selectedPhotos removeAllObjects];
//        [self.collectionView reloadData];
//        [self refreshSelectedPhotCountOnNavTilte];
//    }];
}


- (void)deletePhotos
{
//    if(IsEmpty(selectedPhotos)) return;
//    
//    [self.activityController dismissViewControllerAnimated:YES completion:nil];
// 
//    @try
//    {
//        [self.collectionView performBatchUpdates:^{
//            for (NSIndexPath *indexPath in selectedPhotos) {
//                
//                if( indexPath.row < [self.photos count]){
//                    GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//                    [cell showSelectIcon:NO];
//                    NSLog(@"selected:%d / photos count:%d", indexPath.row, [self.photos count]);
//                    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
//                    int userID = [[photo objectForKey:@"UserID"] intValue];
//                    int photoID = [[photo objectForKey:@"PhotoID"] intValue];
//                    NSLog(@"photo = %@", photo);
//                    [SQLManager deleteUserPhoto:userID  withPhoto:photoID];
//                    
//                    [self.photos removeObjectAtIndex:indexPath.row];
//                }
//                
//            }
//            [self.collectionView deleteItemsAtIndexPaths:selectedPhotos];
//            [self.userProfileView updateCell:self.user count:[self.photos count]];
//
//            
//        } completion:^(BOOL finished) {
//
//            self.activityController = nil;
//            NSLog(@"deletePhotos complete!");
//            [selectedPhotos removeAllObjects];
//            //[self editButtonClickHandler:nil];
//            [self.collectionView reloadData];
//            [self refreshSelectedPhotCountOnNavTilte];
//            
//        }];
//    }
//    @catch (NSException *except)
//    {
//        NSLog(@"DEBUG: failure to batch update.  %@", except.description);
//    }

    
    if(IsEmpty(selectedPhotos)) return;
    
    [self.activityController dismissViewControllerAnimated:YES completion:nil];
    
    
    for (NSIndexPath *indexPath in selectedPhotos) {
        NSLog(@"=====> indexPath.row : %d || [self.photos count] : %d", (int)indexPath.row, (int)[self.photos count]);
        //if( indexPath.row < [self.photos count]){
            GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell showSelectIcon:NO];
            NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
            int userID = [[photo objectForKey:@"UserID"] intValue];
            int photoID = [[photo objectForKey:@"PhotoID"] intValue];
            NSLog(@"photo = %@", photo);
            [SQLManager deleteUserPhoto:userID  withPhoto:photoID];
            
            //[self.photos removeObjectAtIndex:indexPath.row];
        //}
        
    }

    [self refresh];
    
//    @try
//    {
//        [self.collectionView performBatchUpdates:^{
//             [self.collectionView deleteItemsAtIndexPaths:selectedPhotos];
//        } completion:^(BOOL finished) {
//            
//            [self refresh];
//            
//        }];
//    }
//    @catch (NSException *except)
//    {
//        NSLog(@"DEBUG: failure to batch update.  %@", except.description);
//    }

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
        destViewController.userInfo = self.user;
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
        
        if(destUserID ==  [self.user[@"UserID"] intValue]){
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
