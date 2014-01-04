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
#import "AllPhotosController.h"
#import "FBFriendController.h"
#import "UIView+SubviewHunting.h"

@interface AlbumPageController () <UITableViewDelegate, UITableViewDataSource, FBFriendControllerDelegate, UserCellDelegate, UIActionSheetDelegate> {
    CGFloat _keyboardHeight;
    NSIndexPath *editIndexPath;
}

@property (strong, nonatomic) IBOutlet UserAddView *addUserView;
@property (strong, nonatomic) IBOutlet ALLPhotosView *allPhotosView;
@property (strong, nonatomic) UserCell *editCell;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *usersPhotos;
@property (strong, nonatomic) FBFriendController *friendPopup;

- (IBAction)allPhotosViewClickHandler:(id)sender;
- (IBAction)userAddViewClickHandler:(id)sender;

- (IBAction)UnwindFromIndividualGalleryToAlbumPage:(UIStoryboardSegue *)segue;

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

    
    self.usersPhotos = [[SQLManager getAllUserPhotos] mutableCopy];
    NSLog(@"usersPhotos: %@",_usersPhotos);
    
    NSDictionary *users = [[self.usersPhotos objectAtIndex:0] copy];
    NSDictionary *users1 = [[self.usersPhotos objectAtIndex:0] copy];
    NSDictionary *users2 = [[self.usersPhotos objectAtIndex:0] copy];
    NSDictionary *users3 = [[self.usersPhotos objectAtIndex:0] copy];
    
    NSMutableArray *newuser = [NSMutableArray arrayWithObjects:users, users1, users3, users2, nil];
    self.usersPhotos = newuser;
   
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

- (void) calAllPhotos {
    int allphotocount = 0;
    if (self.usersPhotos) {
        for (NSDictionary *user in self.usersPhotos) {
            NSArray *photos = [user objectForKey:@"photos"];
            allphotocount += [photos count];
        }
    }
    
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
        [self performSegueWithIdentifier:SEGUE_3_1_TO_4_1 sender:self];
    }
    else {
        [self performSegueWithIdentifier:SEGUE_3_1_TO_4_2 sender:self];
    }
}


- (IBAction)allPhotosViewClickHandler:(id)sender {
}

- (IBAction)userAddViewClickHandler:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"From Photo Album", nil];
	[popupQuery showInView:self.view];
}

- (IBAction)UnwindFromIndividualGalleryToAlbumPage:(UIStoryboardSegue *)segue{
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_3_1_TO_4_1] || [segue.identifier isEqualToString:SEGUE_3_1_TO_4_2]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        IndividualGalleryController *destViewController = segue.destinationViewController;
        destViewController.usersPhotos = [self.usersPhotos objectAtIndex:indexPath.row];
    }
    else if([segue.identifier isEqualToString:SEGUE_3_1_TO_6_1]){
        AllPhotosController *destViewController = segue.destinationViewController;
        destViewController.photos = self.usersPhotos;
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
    [self.tableView setEditing:NO];
    [self.tableView setScrollEnabled:YES];
    self.editCell = nil;
}

- (void)deleteUserCell:(UserCell *)cell {
    [self doneUserCell:cell];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *deleteIndexPaths = @[indexPath];

    [self.usersPhotos removeObjectAtIndex:indexPath.row];
   
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
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

- (void)searchFriend:(UserCell *)cell name:(NSString *)name {
    [self.friendPopup handleSearchForTerm:name];
}

#pragma mark FBFriendControllerDelegate

- (void)selectedFBFriend:(NSDictionary *)friend {
    self.editCell.userName.text = [friend objectForKey:@"name"];
    self.editCell.inputName.text = @"";
    
    [self.editCell doneButtonClickHandler:nil];
    // DB에 저장하는 부분 추가
}

#pragma mark UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        // Camera
        case 0:
            NSLog(@"Camera Clicked");
            break;
        // From Photo Album
        case 1:
            NSLog(@"From Photo Album Clicked");
            break;
        // Cancel
        case 2:
            NSLog(@"Cancel Clicked");
            break;
    }
}

-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
    CGRect keyboardRect = [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
}

-(void)keyboardWillHide:(NSNotification*)notification {
    _keyboardHeight = 0.0;
}
@end
