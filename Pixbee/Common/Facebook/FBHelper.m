//
//  FBHelper.m
//  matchme
//
//  Created by jaecheol kim on 10/4/13.
//  Copyright (c) 2013 jaecheol kim. All rights reserved.
//


/* 
시나리오 
 
 1) 어플 처음 로딩시 friends.plist 파일이 있는지 확인해 본다.
 - 확인 시 없으면 hasFriendList = FALSE  => 친구 리스트 보여 줄 수 없다.
 - 확인 시 있으면 hasFriendList = TRUE => 친구 리스트를 보여준다.
 
 2) 어플 처음 로딩시 페북 로그인 요청
 
 
 
*/

#import "FBHelper.h"
#import <CoreLocation/CoreLocation.h>

@interface FBHelper ()

@end

@implementation FBHelper
@synthesize loggedInUser = _loggedInUser;
@synthesize friends = _friends;
@synthesize delegate;

// 초기화.
- (id)init {
	if ((self = [super init])) {
    }
	return self;
}

- (void)dealloc {
    self.loggedInUser = nil;
    self.friends = nil;
}

+ (FBHelper *)sharedInstance {
    static dispatch_once_t pred;
    static FBHelper *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[FBHelper alloc] init];
    });
    return sharedInstance;
}

#pragma mark - FBHelper Methods
- (void)loadFBLoginView:(UIView *)_view {
    
    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] init];
    
    loginview.readPermissions = @[@"basic_info", @"read_stream", @"user_friends"];
    
    CGRect lvFrame = loginview.frame;
    
    CGSize lvSize = lvFrame.size;
    CGRect viewFrame = _view.frame; //[UIScreen mainScreen].bounds;
    // Center align the ad
    
    float position_x = (viewFrame.size.width - lvSize.width) / 2;
    float position_y = (viewFrame.size.height - lvSize.height) / 2; //25;
    
    lvFrame = CGRectMake(position_x, position_y, lvSize.width, lvSize.height);
    
    
    
    //    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.frame = lvFrame; //CGRectOffset(loginview.frame, position_x, position_y);
    
#ifdef __IPHONE_7_0
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        //        loginview.frame = CGRectOffset(loginview.frame, 5, 25);
        
        loginview.frame = lvFrame;
    }
#endif
#endif
#endif
    
    
    loginview.delegate = self;
    
    [_view addSubview:loginview];
    
    [loginview sizeToFit];
}


#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
    if ([[self delegate] respondsToSelector:@selector(FBLogedInUser)]) {
        [[self delegate] FBLogedInUser];
    }
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {

    self.loggedInUser = user;
    
//    NSLog(@"FB Loged user : %@", self.loggedInUser.name );
//    
//    [self fetchFriendList];
    
    if ([[self delegate] respondsToSelector:@selector(FBLoginFetchedUserInfo:)]) {
        [[self delegate] FBLoginFetchedUserInfo:user];
    }
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // test to see if we can use the share dialog built into the Facebook application
    FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
    p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
#ifdef DEBUG
    [FBSettings enableBetaFeatures:FBBetaFeaturesShareDialog];
#endif
    
     self.loggedInUser = nil;
    
    if ([[self delegate] respondsToSelector:@selector(FBLoggedOutUser)]) {
        [[self delegate] FBLoggedOutUser];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
    if ([[self delegate] respondsToSelector:@selector(FBHandleError)]) {
        [[self delegate] FBHandleError];
    }
}


#pragma mark - Usage Sample For FB API

- (void)saveFriendList
{
    if([self.friends count] < 1 ) return;
    
    NSLog(@"=========================================[[FBHelper sharedInstance] saveFriendList];");
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"list.plist"];
    NSMutableArray *list = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    if (list == nil) {
        list = [[NSMutableArray alloc] init];
    }
    
    [list removeAllObjects];

    [list addObjectsFromArray:self.friends];
    
//    NSLog(@"SAVE FRIENDS ====== %@", list);
    
    [list writeToFile:path atomically:YES];
}


- (BOOL)loadFriendList
{
    NSLog(@"=========================================[[FBHelper sharedInstance] loadFriendList];");
    
    self.friends = nil;
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"list.plist"];
    NSMutableArray *list = [[NSMutableArray alloc] initWithContentsOfFile:path];
 
    if([list count]) {
        self.friends = (NSArray *)list;
        
        // NSLog(@"LOAD FRIENDS ====== %@", self.friends);
        return TRUE;
    }
    
    return FALSE;
}

- (void)fetchFriendList {

    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        
        
//        NSLog(@"Fetched friends data : %@", result);
        
        self.friends = [result objectForKey:@"data"];
        
        [self saveFriendList];
        [self loadFriendList];
        
 
        
//        NSLog(@"Found: %i friends", self.friends.count);
//        for (NSDictionary<FBGraphUser>* friend in self.friends) {
//            NSLog(@"I have a friend named %@ ( %@ )", friend.name, [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", friend.id] );
//                //        NSArray *friendIDs = [friends collect:^id(NSDictionary<FBGraphUser>* friend) {
//                //            return friend.id;
//                //        }];
//        }
        
        if ([[self delegate] respondsToSelector:@selector(finishFriendLists:)]) {
            [[self delegate] finishFriendLists:self.friends];
        }

    }];
}




// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
  
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
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
        action();
    }
    
}

// Post Status Update button handler; will attempt different approaches depending upon configuration.
- (IBAction)postStatusUpdateClick:(UIButton *)sender {
    // Post a status update to the user's feed via the Graph API, and display an alert view
    // with the results or an error.
    
    NSURL *urlToShare = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
    
    // This code demonstrates 3 different ways of sharing using the Facebook SDK.
    // The first method tries to share via the Facebook app. This allows sharing without
    // the user having to authorize your app, and is available as long as the user has the
    // correct Facebook app installed. This publish will result in a fast-app-switch to the
    // Facebook app.
    // The second method tries to share via Facebook's iOS6 integration, which also
    // allows sharing without the user having to authorize your app, and is available as
    // long as the user has linked their Facebook account with iOS6. This publish will
    // result in a popup iOS6 dialog.
    // The third method tries to share via a Graph API request. This does require the user
    // to authorize your app. They must also grant your app publish permissions. This
    // allows the app to publish without any user interaction.
    
    // If it is available, we will first try to post using the share dialog in the Facebook app
    FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:urlToShare
                                                          name:@"Hello Facebook"
                                                       caption:nil
                                                   description:@"The 'Hello Facebook' sample application showcases simple Facebook integration."
                                                       picture:nil
                                                   clientState:nil
                                                       handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                           if (error) {
                                                               NSLog(@"Error: %@", error.description);
                                                           } else {
                                                               NSLog(@"Success!");
                                                           }
                                                       }];
    
    if (!appCall) {
        // Next try to post using Facebook's iOS6 integration
        BOOL displayedNativeDialog = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                                              initialText:nil
                                                                                    image:nil
                                                                                      url:urlToShare
                                                                                  handler:nil];
        
        if (!displayedNativeDialog) {
            // Lastly, fall back on a request for permissions and a direct post using the Graph API
            [self performPublishAction:^{
                NSString *message = [NSString stringWithFormat:@"Updating status for %@ at %@", self.loggedInUser.first_name, [NSDate date]];
                
                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                
                connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
                | FBRequestConnectionErrorBehaviorAlertUser
                | FBRequestConnectionErrorBehaviorRetry;
                
                [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
                     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                         
                         [self showAlert:message result:result error:error];
                         //                                        self.buttonPostStatus.enabled = YES;
                     }];
                
             
                [connection start];
                
                //                self.buttonPostStatus.enabled = NO;
            }];
        }
    }
}

// Post Photo button handler
- (IBAction)postPhotoClick:(UIButton *)sender {
    // Just use the icon image from the application itself.  A real app would have a more
    // useful way to get an image.
    UIImage *img = [UIImage imageNamed:@"Icon-72@2x.png"];
    
    [self performPublishAction:^{
        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
        | FBRequestConnectionErrorBehaviorAlertUser
        | FBRequestConnectionErrorBehaviorRetry;
        
        [connection addRequest:[FBRequest requestForUploadPhoto:img]
             completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 
                 [self showAlert:@"Photo Post" result:result error:error];
                 if (FBSession.activeSession.isOpen) {
                     //                     self.buttonPostPhoto.enabled = YES;
                 }
             }];
        [connection start];
        
        //        self.buttonPostPhoto.enabled = NO;
    }];
}

// Pick Friends button handler
- (IBAction)pickFriendsClick:(UIButton *)sender {
    FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
    friendPickerController.title = @"Pick Friends";
    [friendPickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [friendPickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *sender, BOOL donePressed) {
         
         if (!donePressed) {
             return;
         }
         
         NSString *message;
         
         if (friendPickerController.selection.count == 0) {
             message = @"<No Friends Selected>";
         } else {
             
             NSMutableString *text = [[NSMutableString alloc] init];
             
             // we pick up the users from the selection, and create a string that we use to update the text view
             // at the bottom of the display; note that self.selection is a property inherited from our base class
             for (id<FBGraphUser> user in friendPickerController.selection) {
                 if ([text length]) {
                     [text appendString:@", "];
                 }
                 [text appendString:user.name];
             }
             message = text;
         }
         
         [[[UIAlertView alloc] initWithTitle:@"You Picked:"
                                     message:message
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
}

// Pick Place button handler
- (IBAction)pickPlaceClick:(UIButton *)sender {
    FBPlacePickerViewController *placePickerController = [[FBPlacePickerViewController alloc] init];
    placePickerController.title = @"Pick a Seattle Place";
    placePickerController.locationCoordinate = CLLocationCoordinate2DMake(47.6097, -122.3331);
    [placePickerController loadData];
    
    // Use the modal wrapper method to display the picker.
    [placePickerController presentModallyFromViewController:self animated:YES handler:
     ^(FBViewController *sender, BOOL donePressed) {
         
         if (!donePressed) {
             return;
         }
         
         NSString *placeName = placePickerController.selection.name;
         if (!placeName) {
             placeName = @"<No Place Selected>";
         }
         
         [[[UIAlertView alloc] initWithTitle:@"You Picked:"
                                     message:placeName
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // Since we use FBRequestConnectionErrorBehaviorAlertUser,
        // we do not need to surface our own alert view if there is an
        // an fberrorUserMessage unless the session is closed.
        if (error.fberrorUserMessage && FBSession.activeSession.isOpen) {
            alertTitle = nil;
            
        } else {
            // Otherwise, use a general "connection problem" message.
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    if (alertTitle) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


@end
