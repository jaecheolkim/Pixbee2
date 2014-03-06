//
//  PBMainDashBoardViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 2/26/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//
#import "LXReorderableCollectionViewFlowLayout.h"
#import "PBMainDashBoardViewController.h"

#import "IndividualGalleryController.h"
#import "AllPhotosController.h"
#import "FaceDetectionViewController.h"

#import "ProfileCard.h"
#import "ProfileCardCell.h"

#import "FBFriendController.h"
#import "UIImageView+WebCache.h"
#import "FXImageView.h"

#define LX_LIMITED_MOVEMENT 0

@interface PBMainDashBoardViewController()
<LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout,
UIActionSheetDelegate, UITextFieldDelegate,
ProfileCardCellDelegate, FBFriendControllerDelegate >
{
    BOOL EDIT_MODE;
    int totalCellCount;
    int ActionSheetType;
    NSString *operateIdentifier; // add new facetab -> all photos로 이동하는 구분자.
    
    NSIndexPath *currentIndexPath;
    ProfileCardCell *currentSelectedCell;
    
    FaceMode facemode;
}


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) NSMutableArray *users;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (strong, nonatomic) FBFriendController *friendPopup;


- (IBAction)leftBarButtonHandler:(id)sender;
- (IBAction)rightBarButtonHandler:(id)sender;
- (IBAction)galleryButtonHandler:(id)sender;
- (IBAction)shutterButtonHandler:(id)sender;
- (IBAction)deleteButtonHandler:(id)sender;
- (IBAction)addFaceTabButtonHandler:(id)sender;

@end

@implementation PBMainDashBoardViewController


- (void)reloadData
{
    self.users = (NSMutableArray*)[SQLManager getAllUsers];
    NSLog(@"self.usersPhotos = %@", self.users);
    totalCellCount = (int)[self.users count];
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
//    if ([[ver objectAtIndex:0] intValue] >= 7) {
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:89/255.0f green:174/255.0f blue:235/255.0f alpha:0.7f];
//        self.navigationController.navigationBar.translucent = NO;
//    }else{
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:89/255.0f green:174/255.0f blue:235/255.0f alpha:0.7f];
//    }
    
    [self refreshNavigationBarColor:nil];
    
    [self refreshBGImage:nil];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = self.bgImageView;

    
    EDIT_MODE = NO;
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadData];
    self.title = [NSString stringWithFormat:@"%d Faces", totalCellCount];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self showToolBar:NO];
}



#pragma mark - UI Control methods

- (void)showToolBar:(BOOL)show
{
    CGRect rect = [UIScreen mainScreen].bounds;
    CGRect frame = _toolBar.frame;
    
    if(show){
        _shutterButton.alpha = 0.0;
        _galleryButton.alpha = 0.0;
        
        frame = CGRectMake(frame.origin.x, rect.size.height - frame.size.height, frame.size.width, frame.size.height);
        
    } else {

        frame = CGRectMake(frame.origin.x, rect.size.height, frame.size.width, frame.size.height);
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _toolBar.frame = frame;
                     }
                     completion:^(BOOL finished){
                         if(!show){
                             _shutterButton.alpha = 1.0;
                             _galleryButton.alpha = 1.0;
                         }
                     }];

    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return totalCellCount + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        if (indexPath.row == totalCellCount) { // Add new facetab cell
            
            
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddCell" forIndexPath:indexPath];
            
            return cell;
            
        } else { // Profile facetab cell

            ProfileCardCell *profileCardCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCardCell" forIndexPath:indexPath];
            
            NSDictionary *userInfo = [self.users  objectAtIndex:indexPath.item];
            profileCardCell.userInfo = userInfo;
            profileCardCell.indexPath = indexPath;
            
            if(EDIT_MODE){
                profileCardCell.delegate = self;
                
                profileCardCell.nameTextField.enabled = YES;
                profileCardCell.nameTextField.placeholder = profileCardCell.nameLabel.text;
                profileCardCell.checkImageView.hidden = NO;
                
            } else {
                
                profileCardCell.nameTextField.enabled = NO;
                profileCardCell.nameTextField.placeholder = nil;
                profileCardCell.checkImageView.hidden = YES;
            }
            
            return profileCardCell;

        }
    }
    
    return nil;
}


//- (NSArray *)indexPathsForSelectedItems; // returns nil or an array of selected index paths
//- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
//{
//    
//}
//- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
//{
//    
//}


// (when the touch lifts)
// 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
// 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
// 5. -collectionView:didUnhighlightItemAtIndexPath:
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//// called when the user taps on an already-selected item in multi-select mode
//{
//    return NO;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if (indexPath.row == totalCellCount) {
        
        } else {

            currentIndexPath = indexPath;
//            ProfileCardCell *profileCardCell = (ProfileCardCell *)[collectionView cellForItemAtIndexPath:indexPath];
            
            
            if(EDIT_MODE){
//                if(profileCardCell.selected)
//                {
//                    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
//                    
//                    [(UICollectionViewCell *)profileCardCell setSelected:NO];
//                    //profileCardCell.checkImageView.hidden = YES;
//                }
//                else {
//                    [(UICollectionViewCell *)profileCardCell setSelected:YES];
//                    //profileCardCell.checkImageView.hidden = NO;
//                }
                
            } else {
                NSLog(@"go to detail view");
                [self performSegueWithIdentifier:SEGUE_3_1_TO_4_1 sender:self];
            }
            
            NSLog(@"didSelectItemAtIndexPath : %@", self.collectionView.indexPathsForSelectedItems);
        }
    }

}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if (indexPath.row == totalCellCount) {
        
        } else {
            NSLog(@"didDeselectItemAtIndexPath : %@", self.collectionView.indexPathsForSelectedItems);
            
            if(EDIT_MODE){
                
                //ProfileCardCell *profileCardCell = (ProfileCardCell *)[collectionView cellForItemAtIndexPath:indexPath];
                
                //[(UICollectionViewCell *)profileCardCell setSelected:NO];
                //profileCardCell.checkImageView.hidden = YES;
            }

        }
    }

}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
}



#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {

    if(totalCellCount < 2) return;
    
    if(fromIndexPath.section == 0){
        if (fromIndexPath.row == totalCellCount) {
        
        } else {
            
            NSDictionary *userInfo = [self.users  objectAtIndex:fromIndexPath.item];
            [self.users removeObjectAtIndex:fromIndexPath.item];
            [self.users insertObject:userInfo atIndex:toIndexPath.item];
            
        }
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(totalCellCount < 2) return NO;
    
    if(indexPath.section == 0){
        if (indexPath.row == totalCellCount) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {

    if(totalCellCount < 2) return NO;
    
    if(toIndexPath.section == 0){
        if (toIndexPath.row == totalCellCount) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
    [self updateProfileDBSeq];
}


#pragma mark - Button Handler

//Settung Button
- (IBAction)leftBarButtonHandler:(id)sender {
    [self performSegueWithIdentifier:@"Segue3_1toSetting" sender:self];
    
    NSLog(@"clicked leftBarButtonHandler");
}

//Edit Button
- (IBAction)rightBarButtonHandler:(id)sender {
    NSLog(@"clicked rightBarButtonHandler");
    EDIT_MODE = !EDIT_MODE;
    
    if(EDIT_MODE){
        self.rightBarButton.image = nil;
        self.rightBarButton.title = @"Cancel";
        
    }
    else {
        self.rightBarButton.title = nil;
        self.rightBarButton.image = [UIImage imageNamed:@"edit"];
        
        NSLog(@"clean selectItemAtIndexPath : %@", self.collectionView.indexPathsForSelectedItems);
        
//        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
//            id collectionViewCell = [self.collectionView cellForItemAtIndexPath:indexPath];
//            if([@"ProfileCardCell" isEqual:NSStringFromClass([collectionViewCell class])]){
//                ProfileCardCell *profileCardCell = (ProfileCardCell *)collectionViewCell;
//                [(UICollectionViewCell *)profileCardCell setSelected:NO];
//                profileCardCell.checkImageView.hidden = YES;
//            }
//            
//        }
    }
    
    [self showToolBar:EDIT_MODE];
    [self.collectionView setAllowsMultipleSelection:EDIT_MODE];
    [self.collectionView reloadData];
}

- (IBAction)galleryButtonHandler:(id)sender {
     NSLog(@"clicked galleryButtonHandler");
    [self performSegueWithIdentifier:SEGUE_3_1_TO_4_3 sender:self];
}

- (IBAction)shutterButtonHandler:(id)sender {
    facemode = FaceModeRecognize;
    NSLog(@"clicked shutterButtonHandler");
}

- (IBAction)deleteButtonHandler:(id)sender {
    ActionSheetType = 200;
    UIActionSheet *deleteMenu = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              destructiveButtonTitle:NSLocalizedString(@"Delete selected FaceTag", @"")
                                                   otherButtonTitles:nil];
	[deleteMenu showInView:self.view];

}

- (IBAction)addFaceTabButtonHandler:(id)sender {
    NSLog(@"Add Face Tab");
    ActionSheetType = 100;
    
    [self.view addSubview:[self getSnapShot]];
    
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Camera", @"From Photo Album", nil];
	[popupQuery showInView:self.view];

}



#pragma mark - Logic Handler

- (void)updateProfileDBSeq
{
    if(IsEmpty(self.users)) return;
    
    int seq = 0;
    for(NSDictionary *userInfo in self.users)
    {
        int UserID = [userInfo[@"UserID"] intValue];
        
        NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(UserID), @"seq" :@(seq)}];
        NSLog(@"result = %@", result);
        seq++;
    }
}

// CollectionView delete batch and animation
- (void)deleteSelectedCell
{
    
    NSArray *selectedItemsIndexPaths = [self.collectionView indexPathsForSelectedItems];
    NSLog(@"selected Items = %@", selectedItemsIndexPaths);
    
    //NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *itemPath  in selectedItemsIndexPaths) {
        
        ProfileCardCell *profileCardCell = (ProfileCardCell *)[self.collectionView cellForItemAtIndexPath:itemPath];
        NSDictionary *userInfo = profileCardCell.userInfo;
        //[indexSet addIndex:itemPath.row];
        int UserID = [userInfo[@"UserID"] intValue];
        
        if([SQLManager deleteUser:UserID]){
            [self.users removeObjectAtIndex:itemPath.row];
            totalCellCount = (int)[self.users count];
            [self.collectionView deleteItemsAtIndexPaths:@[itemPath]];
            
        } else {
            NSLog(@"Can't delete Users db row..");
#warning Error message 뿌려주기
        }
    }
}

//- (void)doneUserCell:(UserCell *)cell {
//    NSIndexPath *indexPath = editIndexPath;
//    
//    NSString *inputUserName = cell.inputName.text;
//    //NSString *cellUserName = [cell.user objectForKey:@"UserName"];
//    int cellUserID = [[cell.user objectForKey:@"UserID"] intValue];
//    
//    if(!IsEmpty(inputUserName)){
//        //Update DB
//        NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(cellUserID), @"UserName" :inputUserName}];
//        if(!IsEmpty(result)){
//            cell.userName.text = inputUserName;
//            
//            NSDictionary *users = [self.usersPhotos objectAtIndex:indexPath.row];
//            NSArray *photos = users[@"photos"];
//            NSDictionary *user =result[0];
//            [self.usersPhotos replaceObjectAtIndex:indexPath.row withObject:@{@"user":user,@"photos":photos}];
//            
//        }
//    }
//    NSLog(@"Input text : %@", cell.inputName.text);
//    [self.tableView setEditing:NO];
//    [self.tableView setScrollEnabled:YES];
//    self.editCell = nil;
//}



#pragma mark UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(ActionSheetType == 200){
        
        NSLog(@"Button index = %d", (int)buttonIndex);
        if(buttonIndex == 0) {
            [self deleteSelectedCell];
        }
        
    } else if(ActionSheetType == 100){
        switch (buttonIndex) {
                // Camera
            case 0:
                NSLog(@"Camera Clicked");
                facemode = FaceModeCollect;
                [self performSegueWithIdentifier:SEGUE_3_1_TO_6_1 sender:self];
                //PopCamera
                break;
                // From Photo Album
            case 1:
                NSLog(@"From Photo Album Clicked");
                operateIdentifier = @"new facetab";
                [self performSegueWithIdentifier:SEGUE_3_1_TO_4_3 sender:self];
                //Segue3_1to6_1
                break;
                // Cancel
            case 2:
                NSLog(@"Cancel Clicked");
                break;
        }
    }
    
}

//SEGUE_3_1_TO_6_1 // add new face tab from camera
//SEGUE_3_1_TO_4_3 // add new face tab from album
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_3_1_TO_4_1] || [segue.identifier isEqualToString:SEGUE_3_1_TO_4_2]) {
        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        IndividualGalleryController *destViewController = segue.destinationViewController;
//        
//        NSDictionary *users = [self.usersPhotos objectAtIndex:indexPath.row];
//        NSDictionary *user = [users objectForKey:@"user"];
//        int UserID = [[user objectForKey:@"UserID"] intValue];
        
        NSDictionary *userInfo = [self.users  objectAtIndex:currentIndexPath.item];
        //NSDictionary *userInfo = currentProfileCardCell.userInfo;
        int UserID = [userInfo[@"UserID"] intValue];
        
        
        //destViewController.usersPhotos = [self.usersPhotos objectAtIndex:indexPath.row];
        destViewController.UserID = UserID;
        
    }
    else if([segue.identifier isEqualToString:SEGUE_3_1_TO_4_3]){ // add new face tab from Album
        AllPhotosController *destViewController = segue.destinationViewController;
        //destViewController.photos = self.usersPhotos;
        destViewController.segueIdentifier = segue.identifier;
        destViewController.operateIdentifier = operateIdentifier;
        
    }
    
    else if ([segue.identifier isEqualToString:SEGUE_3_1_TO_6_1]) { // add new face tab from camera
        if(facemode == FaceModeRecognize) {
            FaceDetectionViewController *destination = segue.destinationViewController;
            destination.faceMode = facemode;
            destination.segueid = SEGUE_3_1_TO_6_1;
        } else if(facemode == FaceModeCollect) {
            NSArray *result = [SQLManager newUser];
            NSDictionary *user = [result objectAtIndex:0];
            NSString *UserName = [user objectForKey:@"UserName"];
            int UserID = [[user objectForKey:@"UserID"] intValue];
            
            if(UserID) {
                FaceDetectionViewController *destination = segue.destinationViewController;
                destination.UserID = UserID;
                destination.UserName = UserName;
                destination.faceMode = facemode;
                destination.segueid = SEGUE_3_1_TO_6_1;
            }
        }

    }
    
}
//unwindSegue handler from AlbumSelectionController.
- (IBAction)unwindToMainDashBoardViewController:(UIStoryboardSegue *)unwindSegue
{
    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
//    //만약에 copy or move operation을 진행하고 다른 user의 facetab을 선택하고 오면
//    if ([sourceViewController isKindOfClass:[IndividualGalleryController class]])
//    {
//        NSLog(@"unwindToAlbumPageController - from IndividualGalleryController");
//        
//    }
//    
//    else if([sourceViewController isKindOfClass:[AllPhotosController class]])
//    {
//        NSLog(@"unwindToAlbumPageController - from AllPhotosController");
//    }
    
    
}





//Override Keyboard noti handler from PBcommonViewController
-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    CGRect keyboardRect = [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    int keyboardHeight = keyboardRect.size.height;
    float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect rect = self.view.frame;
    
    

    float toHeight = rect.size.height - keyboardHeight - 25;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.colorBar.frame = CGRectMake(0, toHeight, 320, 25);
                         [self.view addSubview:self.colorBar];
//                         [self.view setFrame:CGRectMake(rect.origin.x, -keyboardHeight, rect.size.width, rect.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }];
 
}
-(void)keyboardDidShow:(NSNotification*)notification
{
    
}
-(void)keyboardWillHide:(NSNotification*)notification
{
    //int keyboardHeight = 0.0;
    NSDictionary *info = notification.userInfo;
    float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect rect = self.view.frame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.colorBar.frame = CGRectMake(0, rect.size.height, 320, 25);
                         [self.colorBar removeFromSuperview];
                     }
                     completion:^(BOOL finished){
                         
                     }];

    
}
-(void)keyboardDidHide:(NSNotification*)notification
{
    
}

//Override colorButtonHandler from PBCommonViewController
- (void)colorButtonHandler:(id)sender
{
    UIButton *colorButton = (UIButton*)sender;
    int color = (int)colorButton.tag;
    NSLog(@"ColorBar Selected = %d", color );
    
    if(currentSelectedCell){
        currentSelectedCell.nameLabel.backgroundColor = [SQLManager getUserColor:color];
    }
}


- (void)nameDidBeginEditing:(ProfileCardCell *)cell
{
    currentSelectedCell = cell;
    NSLog(@"==> nameDidBeginEditing: userInfo = %@", cell.userInfo);
    [self frientList:cell appear:YES];
}
- (void)nameDidEndEditing:(ProfileCardCell *)cell
{
    currentSelectedCell = cell;
    NSLog(@"==> nameDidEndEditing:");
    //[self frientList:cell appear:NO];
    [self cellEditDone];
}
- (void)nameDidChange:(ProfileCardCell *)cell
{
    currentSelectedCell = cell;
    NSLog(@"==> nameDidChange:");
    [self searchFriend:cell name:cell.nameTextField.text];
}



#pragma mark FBFriendControllerDelegate
// ProfileCardCell Delegate
- (void)frientList:(ProfileCardCell *)cell appear:(BOOL)show
{
    
    if(show) {
        // show friend Picker
        [self popover:cell.profileImageView];
        NSLog(@"show friend Picker ");
    } else {
        // hide friend Picker
        [self.friendPopup disAppearPopup];
        self.friendPopup = nil;
        NSLog(@"hide friend Picker ");
    }
}
- (void)searchFriend:(ProfileCardCell *)cell name:(NSString *)name
{
    currentSelectedCell = cell;
    [self.friendPopup handleSearchForTerm:name];
    NSLog(@"changed Name = %@", name);
}

-(void)popover:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBFriendController *controller = (FBFriendController *)[storyboard instantiateViewControllerWithIdentifier:@"FBFriendController"];
    
    controller.delegate = self;
    CGPoint convertedPoint = [self.view convertPoint:((UIImageView *)sender).center fromView:((UIImageView *)sender).superview];
    int x = convertedPoint.x - 48;
    int y = convertedPoint.y + 45;
    
    [controller appearPopup:CGPointMake(x, y) reverse:NO];
    
    self.friendPopup = controller;
}


- (void)selectedFBFriend:(NSDictionary *)friend {
    NSDictionary *userInfo = currentSelectedCell.userInfo;
    
    int cellUserID = [[userInfo objectForKey:@"UserID"] intValue];
    NSString *cellUserName = [userInfo objectForKey:@"UserName"];
    NSString *cellfbID = [userInfo objectForKey:@"fbID"];
    
    NSString *fbUserName = [friend objectForKey:@"name"];
    NSString *fbID = [friend objectForKey:@"id"];
    
    NSString *fbProfile;// = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    
    id picture = [friend objectForKey:@"picture"];
    if(!IsEmpty(picture)){
        fbProfile = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    } else {
        //    http://graph.facebook.com/[user id]/picture?type=large     -------------->    for larger image
        //    http://graph.facebook.com/[user id]/picture?type=smaller   -------------->    for smaller image
        //    http://graph.facebook.com/[user id]/picture?type=square     -------------->    for square image
        
        fbProfile = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",friend[@"id"]];
    }
    
    
    //NSString *fbProfile = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    
    
    //if(GlobalValue.UserID != cellUserID && ![fbID isEqualToString:cellfbID])
    //{  // 로그인 한 사용자는 페북 계정을 cell에서 바꿀 수 없음.
    
    
    NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(cellUserID), @"UserName" : fbUserName,
                                                @"UserNick" : fbUserName,  @"UserProfile" : fbProfile,
                                                @"fbID" : fbID, @"fbName" : fbUserName,
                                                @"fbProfile" : fbProfile }];
    
    NSLog(@"result = %@", result);
    
    if(!IsEmpty(result)) {
        
        currentSelectedCell.userInfo = [result objectAtIndex:0];
        currentSelectedCell.nameTextField.text = nil;
        currentSelectedCell.nameTextField.placeholder = nil;
        
        [currentSelectedCell.profileImageView setImageWithURL:[NSURL URLWithString:fbProfile]
                         placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        [SQLManager setUserProfileImage:currentSelectedCell.profileImageView.image UserID:cellUserID];
        
//        self.editCell.userName.text = fbUserName;
//        self.editCell.inputName.text = @"";
//        
//        [self.editCell.userImage setImageWithURL:[NSURL URLWithString:fbProfile]
//                                placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
//        
//        [self.editCell doneButtonClickHandler:nil];
    }
    
//    [self frientList:currentSelectedCell appear:NO];
//    [currentSelectedCell.nameTextField resignFirstResponder];
    //}
    
    [self cellEditDone];
    
    
    
    // DB에 저장하는 부분 추가
    
}

- (void)cellEditDone
{
    NSDictionary *userInfo = currentSelectedCell.userInfo;
    NSIndexPath *indexPath = currentSelectedCell.indexPath;
   
    int UserID = [userInfo[@"UserID"] intValue];
    NSString *UserName = currentSelectedCell.nameLabel.text;
    int color = currentSelectedCell.userColor;
    
    NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(UserID), @"UserName" : UserName,
                                                @"color" : @(color) }];

    if(!IsEmpty(result)){
        [self.users replaceObjectAtIndex:indexPath.row withObject:[result objectAtIndex:0]];
    }
    
    
    currentSelectedCell.nameTextField.placeholder = UserName;
    
    [self frientList:currentSelectedCell appear:NO];
    [currentSelectedCell.nameTextField resignFirstResponder];
    
    
}



@end
