//
//  ModalTestViewController.h
//  AFPopup-Demo
//
//  Created by Alvaro Franco on 3/7/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBFriendController.h"

@interface FaceTabEditController : UIViewController

- (IBAction)close:(id)sender;
- (IBAction)Ok:(id)sender;
- (IBAction)nextProfile:(id)sender;
- (IBAction)prevProfile:(id)sender;
- (IBAction)fbButtonHandler:(id)sender;
- (IBAction)deleteFacetab:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *fbListButton;
@property (weak, nonatomic) IBOutlet UIButton *nextProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *prevProfile;
@property (weak, nonatomic) IBOutlet UIImageView *fbPopupBG;
@property (weak, nonatomic) IBOutlet UIView *nameField;

@property (strong, nonatomic) FBFriendController *friendPopup;


@property (strong, nonatomic) NSDictionary *userInfo;
@end
