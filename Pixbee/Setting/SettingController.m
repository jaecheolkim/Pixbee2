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
@property (nonatomic) NSArray *timeZoneNames;

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

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    NSArray *timeZones = [NSTimeZone knownTimeZoneNames];
	self.timeZoneNames = [timeZones sortedArrayUsingSelector:@selector(localizedStandardCompare:)];


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



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of time zone names.
	return [self.timeZoneNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *MyIdentifier = @"MyIdentifier";
    
	/*
     Retrieve a cell with the given identifier from the table view.
     The cell is defined in the main storyboard: its identifier is MyIdentifier, and  its selection style is set to None.
     */
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
	// Set up the cell.
	NSString *timeZoneName = [self.timeZoneNames objectAtIndex:indexPath.row];
	cell.textLabel.text = timeZoneName;
    
	return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
////    if (indexPath.row == 0) {
////        return 91;
////    }
////    else if (indexPath.row == 1) {
////        return 50;
////    }
////    else if (indexPath.row == 2) {
////        return 50;
////    }
////    else if (indexPath.row == 3) {
////        return 80;
////    }
////    else if (indexPath.row == 4) {
////        return 91;
////    }
//    
//    return 50;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
////    UITableViewCell *cell;
////    if (indexPath.row == 0) {
////        if (self.accountCell == nil) {
////            cell = [tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier forIndexPath:indexPath];
////            
////            self.accountCell = (AccountCell *)cell;
////        }
////        
////        self.accountCell.accountLabel.text = GlobalValue.userName;
//        if ([FBSession activeSession].isOpen) {
//            [self.accountCell.logoutButton setTitle:@"Log-out" forState:UIControlStateNormal];
//        }
//        else {
//            [self.accountCell.logoutButton setTitle:@"Sign-in" forState:UIControlStateNormal];
//        }
////    }
////    else if (indexPath.row == 1) {
////        cell = [tableView dequeueReusableCellWithIdentifier:AutoAnalyzeCellIdentifier forIndexPath:indexPath];
////        
////        BOOL autoanalyze = [[NSUserDefaults standardUserDefaults] boolForKey:@"AUTOANALYZE_VALUE"];
////        UISwitch *autoAnalyzeSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
////        autoAnalyzeSwitch.on = !autoanalyze;
////    }
////    else if (indexPath.row == 2) {
////        cell = [tableView dequeueReusableCellWithIdentifier:OptionCellIdentifier forIndexPath:indexPath];
////        
////        BOOL option = [[NSUserDefaults standardUserDefaults] boolForKey:@"OPTION_VALUE"];
////        UISwitch *optionSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
////        optionSwitch.on = !option;
////    }
////    else if (indexPath.row == 3) {
////        if (self.segmentCell == nil) {
////            cell = (SegmentCell*)[tableView dequeueReusableCellWithIdentifier:SegmentCellIdentifier forIndexPath:indexPath];
////            
////            self.segmentCell = (SegmentCell *)cell;
////        }
////        long segmentselect = [[NSUserDefaults standardUserDefaults] integerForKey:@"SEGMEMT_VALUE"];
////        
////        [self.segmentCell.segmentControl setSelectedSegmentIndex:segmentselect];
////        self.segmentCell.segmentLabel.text = [self.segmentCell.segmentControl titleForSegmentAtIndex:[self.segmentCell.segmentControl selectedSegmentIndex]];
////    }
////    else if (indexPath.row == 4) {
////        cell = [tableView dequeueReusableCellWithIdentifier:AboutCellIdentifier forIndexPath:indexPath];
////    }
////
////
////    return cell;
//    
//    static NSString *MyIdentifier = @"MyIdentifier";
//    
//	/*
//     Retrieve a cell with the given identifier from the table view.
//     The cell is defined in the main storyboard: its identifier is MyIdentifier, and  its selection style is set to None.
//     */
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
//    
//    
//	return cell;
//}

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
