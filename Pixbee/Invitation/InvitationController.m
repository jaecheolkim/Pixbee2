//
//  InvitationController.m
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "InvitationController.h"
#import "PBAppDelegate.h"
#import "SDImageCache.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Addon.h"

@interface InvitationController ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *InvitationLabel;
@property (weak, nonatomic) IBOutlet UILabel *DescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareFBButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

- (IBAction)skipButtonClickHandler:(id)sender;
- (IBAction)shareButtonClickHandler:(id)sender;

@end

@implementation InvitationController

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
    
    [self refreshBGImage:nil];
	// Do any additional setup after loading the view.
    
    // Uncomment to display a logo as the navigation bar title
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pixbee.png"]];
    
    UIColor *strokeColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.15];
    
    //UIFont *font = [UIFont fontWithName:@"AvenirLTStd-Black" size:16];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:@"Share to Facebook"
                                                                         attributes:@{
                                                                                      //NSFontAttributeName : font,
                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                      NSStrokeWidthAttributeName : @-3,
                                                                                      NSStrokeColorAttributeName : strokeColor,
                                                                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }];
    

    [self.shareFBButton setAttributedTitle:attributedText forState:UIControlStateNormal];
    
 
    attributedText = [[NSAttributedString alloc]
                                        initWithString:@"Skip"
                                        attributes:@{
                                                     //NSFontAttributeName : font,
                                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                                     NSStrokeWidthAttributeName : @-3,
                                                     NSStrokeColorAttributeName : strokeColor,
                                                     NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) }
                                        ];
    [self.skipButton setAttributedTitle:attributedText forState:UIControlStateNormal];
    
    
    [self.InvitationLabel setAttributedText:[[NSAttributedString alloc] initWithString:self.InvitationLabel.text
                                                                            attributes:@{
                                                                                         NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                         NSStrokeWidthAttributeName : @-3,
                                                                                         NSStrokeColorAttributeName : strokeColor  }]];
    
    [self.DescriptionLabel setAttributedText:[[NSAttributedString alloc] initWithString:self.DescriptionLabel.text
                                                                            attributes:@{
                                                                                         NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                         NSStrokeWidthAttributeName : @-3,
                                                                                         NSStrokeColorAttributeName : strokeColor  }]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ButtonAction

- (void)refreshBGImage:(UIImage*)image
{
    
    UIImage *lastImage;
    
    if(image != nil) {
        lastImage = image;
    } else {
        lastImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"LastImage"];
        if(IsEmpty(lastImage)) {
            lastImage = [UIImage imageNamed:@"bg.png"];
        }
    }
    
    
    lastImage = [lastImage applyExtraLightEffect];
    self.bgImageView.image = lastImage;
    
}

- (IBAction)skipButtonClickHandler:(id)sender {
    //[self performSegueWithIdentifier:SEGUE_1_4_TO_3_1 sender:self];
    
    PBAppDelegate *appdelegate = (PBAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdelegate goMainView];
}

- (IBAction)shareButtonClickHandler:(id)sender {
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy
    
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    [self posting];
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled){
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        [self posting];
    }
    
}


- (void)posting{
#warning 페북 피드 수정하기.
//    Pixbee - Facial recognition camera
//    Redefine the camera from the human eyes
//    Organize your memories by friends or family
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Sharing Tutorial", @"name",
                                   @"Build great social apps and get more installs.", @"caption",
                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                   nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSString *msg = [NSString stringWithFormat:@"result: %@", result];
                                  // Link posted successfully to Facebook
                                  NSLog(@"%@",msg);
                                  [self skipButtonClickHandler:nil];
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSString *msg = [NSString stringWithFormat:@"%@", error.description];
                                  NSLog(@"%@",msg);
                              }
                          }];
}

@end
