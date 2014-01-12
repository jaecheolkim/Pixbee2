//
//  AlbumPageController.m
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "AlbumPageController.h"
#import "UserCell.h"
#import "ALLPhotosView.h"
#import "UserAddView.h"
#import "SCTInclude.h"
#import "IndividualGalleryController.h"
#import "FaceDetectionViewController.h"
#import "AllPhotosController.h"
#import "FBFriendController.h"
#import "UIView+SubviewHunting.h"

@interface AlbumPageController () <UITableViewDelegate, UITableViewDataSource, FBFriendControllerDelegate, UserCellDelegate, UIActionSheetDelegate> {
    CGFloat _keyboardHeight;
    NSIndexPath *editIndexPath;
    
    int ActionSheetType;
}

@property (strong, nonatomic) IBOutlet UserAddView *addUserView;
@property (strong, nonatomic) IBOutlet ALLPhotosView *allPhotosView;
@property (strong, nonatomic) UserCell *editCell;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *usersPhotos;
@property (strong, nonatomic) FBFriendController *friendPopup;

- (IBAction)allPhotosViewClickHandler:(id)sender;
- (IBAction)userAddViewClickHandler:(id)sender;

@end

@implementation AlbumPageController

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
	// Do any additional setup after loading the view.
    // Uncomment to display a logo as the navigation bar title
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pixbee.png"]];
    

    [self initialNotification];
    
    self.usersPhotos = [[SQLManager getAllUserPhotos] mutableCopy];
    NSLog(@"usersPhotos: %@",_usersPhotos);
    [self calAllPhotos];
    
    // 이전 버튼 제거
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton=YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialNotification
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AlbumContentsViewEventHandler:)
												 name:@"AlbumContentsViewEventHandler" object:nil];
    
    //KEYBOARD OBSERVERS
    /************************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    /************************/

}

- (void)closeNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AlbumContentsViewEventHandler" object:nil];
}




- (void)AlbumContentsViewEventHandler:(NSNotification *)notification
{
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"changedGalleryDB"]) {
        
        self.usersPhotos = [[SQLManager getAllUserPhotos] mutableCopy];
        NSLog(@"usersPhotos: %@",_usersPhotos);
        [self calAllPhotos];
        
        [self.tableView reloadData];
        
        NSInteger section = [self.tableView numberOfSections] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:section]-1 inSection:section];
		
        if(indexPath != nil)
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}


- (void) calAllPhotos {
    int allphotocount = [[PBAssetsLibrary sharedInstance].totalAssets count];
    self.allPhotosView.countLabel.text = [NSString stringWithFormat:@"%d", allphotocount];
}

#pragma mark UITableViewDataSource

//움직일수 있는 셀인지 확인
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([editIndexPath isEqual:indexPath]) {
        return YES;
    }
    return YES;
}

//셀이 이동할때 실행 - 여기에서 실제 데이터의 이동을 구현해 준다.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersPhotos count];
}

- (void)tableView:(UITableView *)tableView willBeginReorderingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.friendPopup disAppearPopup];
    self.friendPopup = nil;
    [self.editCell.inputName resignFirstResponder];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"UserCell";
    
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
    	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
    	cell = (UserCell *)[nib objectAtIndex:0];
    }
    [cell updateBorder:indexPath];
    cell.delegate = self;
    
    NSDictionary *users = [self.usersPhotos objectAtIndex:indexPath.row];
    NSDictionary *user = [users objectForKey:@"user"];
    NSArray *photos = [users objectForKey:@"photos"];
    [cell updateCell:user count:[photos count]];

    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == ([self.usersPhotos count]-1)) {
        return 79+1.5;
    }
    else {
        return 79;
    }
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *users = [self.usersPhotos objectAtIndex:indexPath.row];
    NSArray *photos = [users objectForKey:@"photos"];

    if ([photos count] > 5) {
//        IndividualGalleryController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IndividualGallery"];
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        destViewController.usersPhotos = [self.usersPhotos objectAtIndex:indexPath.row];
//        [self.navigationController pushViewController:destViewController animated:YES];
        
        [self performSegueWithIdentifier:SEGUE_3_1_TO_4_1 sender:self];
    }
    else {
        [self performSegueWithIdentifier:SEGUE_3_1_TO_4_2 sender:self];
    }
}


- (IBAction)allPhotosViewClickHandler:(id)sender {
}

- (IBAction)userAddViewClickHandler:(id)sender {
    ActionSheetType = 100;

    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Camera", @"From Photo Album", nil];
	[popupQuery showInView:self.view];
}

- (IBAction)dismiss:(UIButton *)sender {
    [self dismissCustomSegueViewControllerWithCompletion:^(BOOL finished) {
        NSLog(@"Dismiss complete!");
    }];
}

- (IBAction)presentProgrammatically:(UIButton *)sender {
//    IndividualGalleryController * demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IndividualGallery"];
//    [self presentNatGeoViewController:demoVC completion:^(BOOL finished) {
//        NSLog(@"Present complete!");
//    }];
    
}

//SEGUE_3_1_TO_6_1 // add new face tab from camera
//SEGUE_3_1_TO_4_3 // add new face tab from album
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_3_1_TO_4_1] || [segue.identifier isEqualToString:SEGUE_3_1_TO_4_2]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        IndividualGalleryController *destViewController = segue.destinationViewController;
        destViewController.usersPhotos = [self.usersPhotos objectAtIndex:indexPath.row];
    }
    else if([segue.identifier isEqualToString:SEGUE_3_1_TO_4_3]){ // add new face tab from Album
        AllPhotosController *destViewController = segue.destinationViewController;
        destViewController.photos = self.usersPhotos;
        destViewController.preIdentifier = segue.identifier;
    }
    
    else if ([segue.identifier isEqualToString:SEGUE_3_1_TO_6_1]) { // add new face tab from camera
        //int UserID = [SQLManager newUser];
        NSArray *result = [SQLManager newUser];
        NSDictionary *user = [result objectAtIndex:0];
        NSString *UserName = [user objectForKey:@"UserName"];
        int UserID = [[user objectForKey:@"UserID"] intValue];
        
        if(UserID) {
            FaceDetectionViewController *destination = segue.destinationViewController;
            destination.UserID = UserID;
            destination.UserName = UserName;
            destination.faceMode = FaceModeCollect;
            destination.segueid = SEGUE_3_1_TO_6_1;
        }
    }

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

#pragma mark UserCellDelegate

- (void)editUserCell:(UserCell *)cell {
    if (self.editCell) {
        [self.editCell doneButtonClickHandler:nil];
    }

    editIndexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView setEditing:YES];
    [self.tableView setScrollEnabled:NO];
    
    self.editCell = cell;
}

- (void)doneUserCell:(UserCell *)cell {
    NSString *inputUserName = cell.inputName.text;
    NSString *cellUserName = [cell.user objectForKey:@"UserName"];
    int cellUserID = [[cell.user objectForKey:@"UserID"] intValue];
    
    if(![cellUserName isEqualToString:inputUserName] && !IsEmpty(inputUserName)){
        //Update DB
        NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(cellUserID), @"UserName" :inputUserName}];
        if(!IsEmpty(result))
            cell.userName.text = inputUserName;
    }
    NSLog(@"Input text : %@", cell.inputName.text);
    [self.tableView setEditing:NO];
    [self.tableView setScrollEnabled:YES];
    self.editCell = nil;
}

- (void)deleteUserCell:(UserCell *)cell {
    [self.editCell.inputName resignFirstResponder];
    
    
    
    ActionSheetType = 200;
    UIActionSheet *deleteMenu = [[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
								 destructiveButtonTitle:NSLocalizedString(@"Delete selected FaceTag", @"")
								 otherButtonTitles:nil];
	[deleteMenu showInView:self.view];

}

- (void)deleteSelectedCell
{
    
    NSIndexPath *indexPath = editIndexPath; //[self.tableView indexPathForCell:self.editCell];
    
    NSDictionary *users = [self.usersPhotos objectAtIndex:indexPath.row];
    NSDictionary *user = [users objectForKey:@"user"];
    int UserID = [[user objectForKey:@"UserID"] intValue];
    
    if([SQLManager deleteUser:UserID]){
        
        NSArray *deleteIndexPaths = @[indexPath];
        
        [self.usersPhotos removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        NSLog(@"Can't delete Users db row..");
#warning Error message 뿌려주기
    }
    
    [self.tableView setEditing:NO];
    [self.tableView setScrollEnabled:YES];
    self.editCell = nil;
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

- (void)searchFriend:(UserCell *)cell name:(NSString *)name {
    [self.friendPopup handleSearchForTerm:name];
}

#pragma mark FBFriendControllerDelegate

- (void)selectedFBFriend:(NSDictionary *)friend {
    NSDictionary *user = self.editCell.user;
    
    int cellUserID = [[user objectForKey:@"UserID"] intValue];
    NSString *cellUserName = [user objectForKey:@"UserName"];
    NSString *cellfbID = [user objectForKey:@"fbID"];
    
    NSString *fbUserName = [friend objectForKey:@"name"];
    NSString *fbID = [friend objectForKey:@"id"];
    NSString *fbProfile = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];

    
    if(GlobalValue.UserID != cellUserID && ![fbID isEqualToString:cellfbID])
    {  // 로그인 한 사용자는 페북 계정을 cell에서 바꿀 수 없음.
        
        
        NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(cellUserID), @"UserName" : fbUserName,
                                                  @"UserNick" : fbUserName,  @"UserProfile" : fbProfile,
                                                  @"fbID" : fbID, @"fbName" : fbUserName,
                                                  @"fbProfile" : fbProfile }];

        if(!IsEmpty(result)) {
            self.editCell.userName.text = fbUserName;
            self.editCell.inputName.text = @"";
            
            [self.editCell.userImage setImageWithURL:[NSURL URLWithString:fbProfile]
                                    placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
            [self.editCell doneButtonClickHandler:nil];
        }


    }
        
    

    
    // DB에 저장하는 부분 추가
    
 }

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
                [self performSegueWithIdentifier:SEGUE_3_1_TO_6_1 sender:self];
                //PopCamera
                break;
                // From Photo Album
            case 1:
                NSLog(@"From Photo Album Clicked");
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

-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
    CGRect keyboardRect = [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    
    CGPoint point = CGPointMake(self.friendPopup.view.frame.origin.x, self.friendPopup.view.frame.origin.y + self.friendPopup.view.frame.size.height);
    
    int ksy = keyboardRect.origin.y;

    if (keyboardRect.origin.y == self.view.frame.size.height) {
        ksy = keyboardRect.origin.y - _keyboardHeight;
    }

    if (point.y > ksy) {
        int gap = point.y - ksy;
        NSDictionary *info = notification.userInfo;
        float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

       NSLog(@"CGRectContainsPoint(keyboardRect = %@, point = %@)", NSStringFromCGRect(keyboardRect),NSStringFromCGPoint(point));
        
        CGRect rect = self.view.frame;
        [UIView animateWithDuration:duration
                         animations:^{
                             [self.view setFrame:CGRectMake(rect.origin.x, -gap, rect.size.width, rect.size.height)];
                         }
                         completion:^(BOOL finished){
                             
                         }];

    }
}

-(void)keyboardWillHide:(NSNotification*)notification {
    _keyboardHeight = 0.0;
    
    CGRect rect = self.view.frame;
    NSDictionary *info = notification.userInfo;
    float duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.view setFrame:CGRectMake(rect.origin.x, _keyboardHeight, rect.size.width, rect.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    return YES;
}


// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    
    if ([identifier isEqualToString:SEGUE_3_1_TO_4_3]) {
        NSLog(@"dddddd");
    }

    return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}

@end
