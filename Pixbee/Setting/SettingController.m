//
//  SettingController.m
//  Pixbee
//
//  Created by skplanet on 2014. 1. 4..
//  Copyright (c) 2014년 Pixbee. All rights reserved.
//

#import "SettingController.h"
#import "SegmentCell.h"
#import "AccountCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "IntroViewController.h"

@interface SettingController ()
@property (strong, nonatomic) SegmentCell *segmentCell;
@property (strong, nonatomic) AccountCell *accountCell;


//@property (strong, nonatomic) IBOutlet UILabel *photoCountLabel;
//@property (strong, nonatomic) IBOutlet UISwitch *autoAnalyzeSwitch;
//@property (strong, nonatomic) IBOutlet UISwitch *optionSwitch;

- (IBAction)autoAnalyzeChange:(id)sender;
- (IBAction)logoutButtonClickHandler:(id)sender;
- (IBAction)settingOptionChange:(id)sender;
- (IBAction)photoCountChange:(id)sender;
- (IBAction)closeClickHandler:(id)sender;
- (IBAction)goIntroView:(id)sender;


@end

@implementation SettingController

static NSString *AccountCellIdentifier = @"AccountCell";
static NSString *AutoAnalyzeCellIdentifier = @"AutoAnalyzeCell";
static NSString *OptionCellIdentifier = @"OptionCell";
static NSString *SegmentCellIdentifier = @"SegmentCell";
static NSString *AboutCellIdentifier = @"AboutCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)awakeFromNib {
//    
////    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
////    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier forIndexPath:indexPath];
////    UILabel *accountLabel = (UILabel *)[cell.contentView viewWithTag:10];
////    accountLabel.text = GlobalValue.userName;
////    UIButton *logoutButton = (UIButton *)[cell.contentView viewWithTag:20];
////    if ([FBSession activeSession].isOpen) {
////        [logoutButton setTitle:@"Log-out" forState:UIControlStateNormal];
////    }
////    else {
////        [logoutButton setTitle:@"Sign-in" forState:UIControlStateNormal];
////    }
////    
////    BOOL autoanalyze = [[NSUserDefaults standardUserDefaults] boolForKey:@"AUTOANALYZE_VALUE"];
////    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
////    cell = [self.tableView dequeueReusableCellWithIdentifier:AutoAnalyzeCellIdentifier forIndexPath:indexPath];
////    UISwitch *autoAnalyzeSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
////    autoAnalyzeSwitch.on = !autoanalyze;
////    
////    BOOL option = [[NSUserDefaults standardUserDefaults] boolForKey:@"OPTION_VALUE"];
////    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
////    cell = [self.tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier forIndexPath:indexPath];
////    UISwitch *optionSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
////    optionSwitch.on = !option;
//    
//    long segmentselect = [[NSUserDefaults standardUserDefaults] integerForKey:@"SEGMEMT_VALUE"];
//    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
//    cell = [self.tableView dequeueReusableCellWithIdentifier:SegmentCellIdentifier forIndexPath:indexPath];
//    UILabel *photoCountLabel = (UILabel *)[cell.contentView viewWithTag:10];
//    UISegmentedControl *segmentcontrol = (UISegmentedControl *)[cell.contentView viewWithTag:20];
//    [segmentcontrol setSelectedSegmentIndex:segmentselect];
//    photoCountLabel.text = [segmentcontrol titleForSegmentAtIndex:[segmentcontrol selectedSegmentIndex]];
//    [photoCountLabel setNeedsLayout];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 91;
    }
    else if (indexPath.row == 1) {
        return 50;
    }
    else if (indexPath.row == 2) {
        return 50;
    }
    else if (indexPath.row == 3) {
        return 80;
    }
    else if (indexPath.row == 4) {
        return 91;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;
    if (indexPath.row == 0) {
        if (self.accountCell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier forIndexPath:indexPath];
            
            self.accountCell = (AccountCell *)cell;
        }
        
        self.accountCell.accountLabel.text = GlobalValue.userName;
        if ([FBSession activeSession].isOpen) {
            [self.accountCell.logoutButton setTitle:@"Log-out" forState:UIControlStateNormal];
        }
        else {
            [self.accountCell.logoutButton setTitle:@"Sign-in" forState:UIControlStateNormal];
        }
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:AutoAnalyzeCellIdentifier forIndexPath:indexPath];
        
        BOOL autoanalyze = [[NSUserDefaults standardUserDefaults] boolForKey:@"AUTOANALYZE_VALUE"];
        UISwitch *autoAnalyzeSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
        autoAnalyzeSwitch.on = !autoanalyze;
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier forIndexPath:indexPath];
        
        BOOL option = [[NSUserDefaults standardUserDefaults] boolForKey:@"OPTION_VALUE"];
        UISwitch *optionSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
        optionSwitch.on = !option;
    }
    else if (indexPath.row == 3) {
        if (self.segmentCell == nil) {
            cell = (SegmentCell*)[tableView dequeueReusableCellWithIdentifier:SegmentCellIdentifier forIndexPath:indexPath];
            
            self.segmentCell = (SegmentCell *)cell;
        }
        long segmentselect = [[NSUserDefaults standardUserDefaults] integerForKey:@"SEGMEMT_VALUE"];
        
        [self.segmentCell.segmentControl setSelectedSegmentIndex:segmentselect];
        self.segmentCell.segmentLabel.text = [self.segmentCell.segmentControl titleForSegmentAtIndex:[self.segmentCell.segmentControl selectedSegmentIndex]];
    }
    else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:AboutCellIdentifier forIndexPath:indexPath];
    }


    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)autoAnalyzeChange:(id)sender {
    UISwitch *switchview = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:!switchview.on forKey:@"AUTOANALYZE_VALUE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)logoutButtonClickHandler:(id)sender {
    if ([FBSession activeSession].isOpen) {
        [self logoutViewUpdate];
    }
    else {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"basic_info", @"read_stream", @"user_friends",
                                nil];
        
        // Attempt to open the session. If the session is not open, show the user the Facebook login UX
        [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:true completionHandler:^(FBSession *session,
                                                                                                          FBSessionState status,
                                                                                                          NSError *error)
        {
            // Did something go wrong during login? I.e. did the user cancel?
            if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening) {
                
                // If so, just send them round the loop again
                [self logoutViewUpdate];
            }
            else 
            {
                [FBRequestConnection startWithGraphPath:@"/me"
                                             parameters:nil
                                             HTTPMethod:@"GET"
                                      completionHandler:^(
                                                          FBRequestConnection *connection,
                                                          id result,
                                                          NSError *error
                                                          ) {
                                          /* handle the result */
                                          NSDictionary *data = (NSDictionary *)result;
                                          GlobalValue.userName = [data objectForKey:@"name"];
                                          
                                          // Update our game now we've logged in
                                          self.accountCell.accountLabel.text = GlobalValue.userName;
                                          [self.accountCell.logoutButton setTitle:@"Log-out" forState:UIControlStateNormal];
                                      }];
            }                  
        }];
    }
}

- (void)logoutViewUpdate{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    
    self.accountCell.accountLabel.text = @"";
    [self.accountCell.logoutButton setTitle:@"Sign-in" forState:UIControlStateNormal];
    
    GlobalValue.userName = @"";
}

- (IBAction)settingOptionChange:(id)sender {
    UISwitch *switchview = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:!switchview.on forKey:@"OPTION_VALUE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)photoCountChange:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    
    NSString *title = [control titleForSegmentAtIndex:[control selectedSegmentIndex]];
    [self.segmentCell.segmentLabel setText:title];
    
    [[NSUserDefaults standardUserDefaults] setInteger:[control selectedSegmentIndex] forKey:@"SEGMEMT_VALUE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)closeClickHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goIntroView:(id)sender {
    NSLog(@"Go IntroView");

    IntroViewController *controller = [[IntroViewController alloc] init];
    controller.callerID = @"SettingViewController";
    
    [self.navigationController pushViewController:controller animated:YES];
    
}
@end
