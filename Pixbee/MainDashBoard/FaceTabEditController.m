//
//  ModalTestViewController.m
//  AFPopup-Demo
//
//  Created by Alvaro Franco on 3/7/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "FaceTabEditController.h"
#import "UIImageView+AFNetworking.h"
#import "SDImageCache.h"

@interface FaceTabEditController ()
<UITextFieldDelegate, FBFriendControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    NSString *userName;
    int UserID;
    int colorValue;
    
    BOOL showFbList;
    
    int currentIndex;
}
@property (strong, nonatomic) UIView *colorBar;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation FaceTabEditController


-(IBAction)close:(id)sender {
    [self.nameTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideAFPopup" object:nil];
}

- (IBAction)Ok:(id)sender {
    
    [self cellEditDone];
    [self.nameTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideAFPopup" object:nil];

}

- (IBAction)nextProfile:(id)sender {
    
    [self goNextProfile];

}

- (IBAction)prevProfile:(id)sender {
    
    [self goPrevProfile];

}

- (void)goNextProfile
{
    if(!IsEmpty(self.photos)){
        currentIndex++;
        if(currentIndex >= [self.photos count]){
            currentIndex = (int)[self.photos count] - 1;
            self.nextProfileButton.enabled = NO;
            self.prevProfile.enabled = YES;
        } else {
            [self refreshprofileImage];
            self.nextProfileButton.enabled = YES;
        }
    }
}

- (void)goPrevProfile
{
    if(!IsEmpty(self.photos)){
        
        currentIndex--;
        if(currentIndex < 0) {
            currentIndex = 0;
            self.prevProfile.enabled = NO;
            self.nextProfileButton.enabled = YES;
        } else {
            [self refreshprofileImage];
            self.prevProfile.enabled = YES;
        }
        
    }
}

- (void)refreshprofileImage
{
    if(!IsEmpty(self.photos)){
        NSDictionary *photo = [self.photos objectAtIndex:currentIndex];
        
        NSString *imagePath = [photo objectForKey:@"AssetURL"];
        
        if (imagePath && ![imagePath isEqualToString:@""])
        {
            //self.profileImageView.image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imagePath];
            [self changeProfileImage:[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imagePath]];
            
            if (self.profileImageView.image == nil) {
                ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
                {
                    NSLog(@"This debug string was logged after this function was done");
                    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                    //self.profileImageView.image = image;
                    [self changeProfileImage:image];
                    
                    [[SDImageCache sharedImageCache] storeImage:image forKey:imagePath toDisk:NO];
                };
                
                ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
                {
                    NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
                };
                
                [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:imagePath]
                                        resultBlock:resultBlock
                                       failureBlock:failureBlock];
                
            }
        }

        
    }
}


- (void)changeProfileImage:(UIImage*)image
{
    [UIView transitionWithView:self.profileImageView
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.profileImageView.image = image;
                    }
                    completion:^(BOOL finished) {
                        
                    }];
}

- (IBAction)fbButtonHandler:(id)sender {
    
    showFbList = !showFbList;
    
    //self.fbPopupBG.hidden = NO;
    if(showFbList)
        [self.nameTextField resignFirstResponder];
    else
        [self.nameTextField becomeFirstResponder];
    
    [self frientList:showFbList];
}

- (IBAction)deleteFacetab:(id)sender {
    NSLog(@"deleteAction Button pressed.");
    
    [self.nameTextField resignFirstResponder];
    
    UIActionSheet *deleteMenu = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              destructiveButtonTitle:NSLocalizedString(@"Delete selected FaceTag", @"")
                                                   otherButtonTitles:nil];
	[deleteMenu showInView:self.view];

}


- (void)setUserInfo:(NSDictionary *)userInfo
{
    
    _userInfo = userInfo;
    
    userName = _userInfo[@"UserName"];
    
    UserID = [_userInfo[@"UserID"] intValue];
    
    colorValue = 0;
    
    if(!IsEmpty(_userInfo[@"color"])) {
        colorValue = [_userInfo[@"color"] intValue] ;
    }
    
    [self setUserColor:colorValue];
    
    [_profileImageView setImage:[SQLManager getUserProfileImage:UserID]];
    
    
    
//    NSAttributedString *str = [[NSAttributedString alloc] initWithString:userName attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
//    _nameTextField.attributedPlaceholder = str;
    
    
    NSAttributedString *placeHolderStr = [[NSAttributedString alloc] initWithString:userName attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
    _nameTextField.attributedPlaceholder = placeHolderStr;
    
    NSAttributedString *textStr = [[NSAttributedString alloc] initWithString:userName attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    _nameTextField.attributedText = textStr;


    if(self.colorBar == nil){
        [self addColorBar];
    }

    
    self.photos = (NSMutableArray*)[SQLManager getUserPhotos:UserID];
    currentIndex = 0;
    
    if(IsEmpty(self.photos)){
        self.nextProfileButton.enabled = NO;
        self.prevProfile.enabled = NO;
    } else {
        self.nextProfileButton.enabled = YES;
        self.prevProfile.enabled = YES;
    }
    
    [_nameTextField becomeFirstResponder];
    
}

- (void)setUserColor:(int)userColor
{
    UIColor *color = [SQLManager getUserColor:userColor alpha:0.5];
    [_nameField setBackgroundColor:color];
}



- (void)deleteSelectedCell
{
    if([SQLManager deleteUser:UserID]){
        [self close:nil];
    } else {
        
    }

}


#pragma mark UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (buttonIndex) {
        case 0:
            
            [self deleteSelectedCell];
            break;
        case 1:
            [_nameTextField becomeFirstResponder];
        default:
            break;
    }
    
}


#pragma mark ViewController Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    UIToolbar *blurbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    blurbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:blurbar];
    [self.view sendSubviewToBack:blurbar];
    
    self.fbPopupBG.hidden = YES;
    
    _nameTextField.delegate = self;
    [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //KEYBOARD OBSERVERS
    /************************/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    /************************/

    showFbList = NO;
    
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delegate = self;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:_panGestureRecognizer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPanGestureRecognizer Methods



- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if(velocity.x > 0)
    {
        NSLog(@"gesture went right");
        [self goNextProfile];
    }
    else
    {
        NSLog(@"gesture went left");
        [self goPrevProfile];
    }
}



#pragma mark ColorBar Methods
- (UIButton*)getColorButton:(int)i {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *bgColor = [SQLManager getUserColor:i alpha:1.0];
    
    [button setBackgroundColor:bgColor];
    [button addTarget:self action:@selector(colorButtonHandler:) forControlEvents: UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:CGRectMake(i * 53.3, 0, 53.3, 25)];
    [button setTag:i];
    //    [button setBackgroundImage:image forState:UIControlStateNormal];
    //    [button setBackgroundImage:selectedImage forState:UIControlStateDisabled];
    return button;
}


- (void)addColorBar
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.colorBar = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, 320, 25)];

    for(int i = 0 ; i < 6; i++){
        UIButton *colorButton = [self getColorButton:i];
        [self.colorBar addSubview:colorButton];
    }

    [self.view addSubview:self.colorBar];
}

#pragma mark ColorBar Keyboard Methods
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
                         [self.view bringSubviewToFront:self.colorBar];
                         self.colorBar.frame = CGRectMake(0, toHeight, 320, 25);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
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
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


//Override colorButtonHandler from PBCommonViewController
- (void)colorButtonHandler:(id)sender
{
    UIButton *colorButton = (UIButton*)sender;
    colorValue = (int)colorButton.tag;
    NSLog(@"ColorBar Selected = %d", colorValue );
    
    [self setUserColor:colorValue];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    NSLog(@"textFieldDidBeginEditing:");
    
   // self.fbPopupBG.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    userName = textField.text;
    
    NSLog(@"textFieldDidEndEditing:");
}

- (void)textFieldDidChange:(UITextField *)textField {
    if(!IsEmpty(textField.text)){
       userName = textField.text;
       [self searchFriend:userName];
    }
    NSLog(@"textFieldDidChange:");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn:");
    
    userName = textField.text;
    return [textField resignFirstResponder];
}


#pragma mark FBFriendControllerDelegate
// ProfileCardCell Delegate
- (void)frientList:(BOOL)show
{
    if(show) {
        // show friend Picker
        [self popover:_profileImageView];
        NSLog(@"show friend Picker ");
    } else {
        // hide friend Picker
        [self.friendPopup disAppearPopup];
        self.friendPopup = nil;
        NSLog(@"hide friend Picker ");
    }
}




- (void)searchFriend:(NSString *)name
{
    [self.friendPopup handleSearchForTerm:name];
    NSLog(@"changed Name = %@", name);
}

-(void)popover:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBFriendController *controller = (FBFriendController *)[storyboard instantiateViewControllerWithIdentifier:@"FBFriendController"];
    
    controller.delegate = self;
//    CGPoint convertedPoint = [self.view convertPoint:((UIImageView *)sender).center fromView:((UIImageView *)sender).superview];
//    int x = convertedPoint.x - 48;
//    int y = convertedPoint.y + 45;
    
    [controller appearPopup:CGPointMake(60, 292) reverse:NO];
    
    self.friendPopup = controller;
}


- (void)selectedFBFriend:(NSDictionary *)friend {
    NSDictionary *userInfo = self.userInfo;
    
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

        [_profileImageView setImageWithURL:[NSURL URLWithString:fbProfile]
                                             placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        [SQLManager setUserProfileImage:_profileImageView.image UserID:cellUserID];
        
        
        userName = fbUserName;
        
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc] initWithString:userName attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
        _nameTextField.attributedPlaceholder = placeHolderStr;
        
        NSAttributedString *textStr = [[NSAttributedString alloc] initWithString:userName attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
        _nameTextField.attributedText = textStr;
        
    }

}

- (void)cellEditDone
{
    
    NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(UserID), @"UserName" : userName,
                                                @"color" : @(colorValue) }];
    
    [SQLManager setUserProfileImage:_profileImageView.image UserID:UserID];

    [self frientList:NO];
}



@end
