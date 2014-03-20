//
//  PBSettingTableViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 1/31/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBSettingTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "IntroViewController.h"
#import "RFRateMe.h"

@interface PBSettingTableViewController ()
{
    UISwitch *AlbumScanSwitch;
    UISwitch *PushNotiSwitch;
}


- (IBAction)showMenu:(id)sender;

@end

@implementation PBSettingTableViewController

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
    UIImage *colorImage = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(30, 30)];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:colorImage style:UIBarButtonItemStylePlain target:self action:nil];
    
    //    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44.0f, 30.0f)];
    //    [backButton setImage:[UIImage imageNamed:@"back.png"]  forState:UIControlStateNormal];
    //    [backButton addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem =  backButton; //[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_setting_selected"]];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleView;
    
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(126, 440, 68, 22)];
    logo.image = [UIImage imageNamed:@"setting_logo"];
    [self.view addSubview:logo];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 460, 70, 22)];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:9];
    versionLabel.textColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:205.0/255.0 alpha:1.0];
    versionLabel.text = [NSString stringWithFormat:@"Version %@", GlobalValue.appVersion ];//@"Version 1.0";
    [self.view addSubview:versionLabel];

    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
 	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 50.0;
    

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.tableView = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 2;
    else if (section == 1) return 2;
    else if (section == 2) return 3;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 10.0;
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
////#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    if(section == 2){
//        return 3;
//    }
//    return 2;
//}

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
            layer.strokeColor = tableView.separatorColor.CGColor;//[UIColor lightGrayColor].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
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

- (UILabel*)getTitleLabel:(NSString*)title tag:(int)tag color:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(25.0, 2.0, 210.0, 46.0)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:color] ;//]RGB_COLOR(115.0, 115.0, 115.0)]; 76 114 205
    [label setTag:tag];
    [label setText:title];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static int LOGINNAME_TAG            = 1000;
    static int LOGINOUT_TAG             = 1010;
    static int AUTOALBUMSCAN_TAG        = 1020;
    static int PUSHNOTI_TAG             = 1030;
    static int PIXBEEINTRO_TAG          = 1040;
    static int RATEPIXBEE_TAG           = 1050;
    static int TERMOFUSE_TAG            = 1060;
    static int PUSHNOTICONTROL_TAG      = 1070;
    static int AUTOALBUMSCANCONTROL_TAG = 1080;

    static NSString *LoginNameCell = @"LoginNameCell";
    static NSString *LoginOutCell = @"LoginOutCell";
    static NSString *AutoAlbumScanCell = @"AutoAlbumScanCell";
    static NSString *PushNotiCell = @"PushNotiCell";
    static NSString *PixbeeIntroCell = @"PixbeeIntroCell";
    static NSString *RatePixbeeCell = @"RatePixbeeCell";
    static NSString *TermOfUseCell = @"TermOfUseCell";
    
    UITableViewCell *cell;

    if(indexPath.section == 0){
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:LoginNameCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginNameCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSString *title = [NSString stringWithFormat:@"%@", GlobalValue.userName];
            if((UILabel *)[cell.contentView viewWithTag:LOGINNAME_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:LOGINNAME_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:LOGINNAME_TAG color:RGB_COLOR(76.0, 114.0, 205.0)];
                [cell.contentView addSubview:label];
            }
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:LoginOutCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginOutCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            NSString *title;
            if ([FBSession activeSession].isOpen) {
                title = @"Log-out";
            }
            else {
                title = @"Log-in";
            }

            
            //NSString *title = [NSString stringWithFormat:@"%@", @"Log-out"];
            if((UILabel *)[cell.contentView viewWithTag:LOGINOUT_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:LOGINOUT_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:LOGINOUT_TAG color:RGB_COLOR(115.0, 115.0, 115.0)];
                [cell.contentView addSubview:label];
            }
        }
        
    }
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:AutoAlbumScanCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoAlbumScanCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            NSString *title = @"Auto Album Scan";
            if((UILabel *)[cell.contentView viewWithTag:AUTOALBUMSCAN_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:AUTOALBUMSCAN_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:AUTOALBUMSCAN_TAG color:RGB_COLOR(115.0, 115.0, 115.0)];
                [cell.contentView addSubview:label];
            }
            
            if((UISwitch *)[cell.contentView viewWithTag:AUTOALBUMSCANCONTROL_TAG]) {
                if(GlobalValue.autoAlbumScanSetting){
                    [(UISwitch *)[cell.contentView viewWithTag:AUTOALBUMSCANCONTROL_TAG] setOn:YES];
                }
                else {
                    [(UISwitch *)[cell.contentView viewWithTag:AUTOALBUMSCANCONTROL_TAG] setOn:NO];
                }
                
            } else {
                AlbumScanSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250.0, 7.0, 94.0, 27.0)];
                [AlbumScanSwitch setTag:AUTOALBUMSCANCONTROL_TAG];
                
                if(GlobalValue.autoAlbumScanSetting){
                    [AlbumScanSwitch setOn:YES];
                }
                else {
                    [AlbumScanSwitch setOn:NO];
                }
                
                [AlbumScanSwitch addTarget:self action:@selector(AlbumScanSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:AlbumScanSwitch];
            }

            
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:PushNotiCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PushNotiCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            NSString *title = @"Push Notification(test)";
            if((UILabel *)[cell.contentView viewWithTag:PUSHNOTI_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:PUSHNOTI_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:PUSHNOTI_TAG color:RGB_COLOR(115.0, 115.0, 115.0)];
                [cell.contentView addSubview:label];
            }
            
            if((UISwitch *)[cell.contentView viewWithTag:PUSHNOTICONTROL_TAG]) {
                if(GlobalValue.pushNotificationSetting){
                    [(UISwitch *)[cell.contentView viewWithTag:PUSHNOTICONTROL_TAG] setOn:YES];
                }
                else {
                    [(UISwitch *)[cell.contentView viewWithTag:PUSHNOTICONTROL_TAG] setOn:NO];
                }
                
            } else {
                PushNotiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250.0, 7.0, 94.0, 27.0)];
                [PushNotiSwitch setTag:PUSHNOTICONTROL_TAG];
                
                if(GlobalValue.pushNotificationSetting){
                    [PushNotiSwitch setOn:YES];
                }
                else {
                    [PushNotiSwitch setOn:NO];
                }
                
                [PushNotiSwitch addTarget:self action:@selector(PushNotiSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:PushNotiSwitch];
            }
        }
    }
    else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:PixbeeIntroCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PixbeeIntroCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            NSString *title = @"Pixbee Intro";
            if((UILabel *)[cell.contentView viewWithTag:PIXBEEINTRO_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:PIXBEEINTRO_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:PIXBEEINTRO_TAG color:RGB_COLOR(115.0, 115.0, 115.0)];
                [cell.contentView addSubview:label];
            }
            
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:RatePixbeeCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RatePixbeeCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            NSString *title = @"Rate Pixbee";
            if((UILabel *)[cell.contentView viewWithTag:RATEPIXBEE_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:RATEPIXBEE_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:RATEPIXBEE_TAG color:RGB_COLOR(115.0, 115.0, 115.0)];
                [cell.contentView addSubview:label];
            }
        }
        
        else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:TermOfUseCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TermOfUseCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            
            NSString *title = @"Term Of Use";
            if((UILabel *)[cell.contentView viewWithTag:TERMOFUSE_TAG]) {
                [(UILabel *)[cell.contentView viewWithTag:TERMOFUSE_TAG] setText:title];
            } else {
                UILabel *label = [self getTitleLabel:title tag:TERMOFUSE_TAG color:RGB_COLOR(115.0, 115.0, 115.0)];
                [cell.contentView addSubview:label];
            }
        }
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1) // 로그인 / 로그아웃
        {
            NSLog(@"Login/Out");
            [self logoutButtonClickHandler:nil];
        }
    }

    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0) // Pixbee Intro
        {
             NSLog(@"Pixbee Intro");
            IntroViewController *controller = [[IntroViewController alloc] init];
            controller.callerID = @"SettingViewController";
            
            [self.navigationController pushViewController:controller animated:YES];

        }
        else if (indexPath.row == 1) // Rate Pixbee
        {
            NSLog(@"Rate Pixbee");
            [RFRateMe showRateAlert];
        }
        else if (indexPath.row == 2) // Term Of Use
        {
            NSLog(@"Term Of Use"); //@"SettingToFaceList"
            [self performSegueWithIdentifier:@"SettingToFaceList" sender:self];
        }
    }
}


- (void)AlbumScanSwitchValueChanged : (id)sender
{
    if([(UISwitch *)sender isOn]) {
        GlobalValue.autoAlbumScanSetting = 1;
    }
    else {
        GlobalValue.autoAlbumScanSetting = 0;
    }
}

- (void)PushNotiSwitchValueChanged : (id)sender
{
    if([(UISwitch *)sender isOn]) {
        GlobalValue.pushNotificationSetting = 1;
        GlobalValue.testMode = 1;
    }
    else {
        GlobalValue.pushNotificationSetting = 0;
        GlobalValue.testMode = 0;
    }
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
                                           
                                           [self.tableView reloadData];
                                           // Update our game now we've logged in
//                                           self.accountCell.accountLabel.text = GlobalValue.userName;
//                                           [self.accountCell.logoutButton setTitle:@"Log-out" forState:UIControlStateNormal];
                                       }];
             }
         }];
    }
}

- (void)logoutViewUpdate{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    
     GlobalValue.userName = @"";
    
    [self.tableView reloadData];
//    self.accountCell.accountLabel.text = @"";
//    [self.accountCell.logoutButton setTitle:@"Sign-in" forState:UIControlStateNormal];
    
   
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showMenu:(id)sender {
    [self.sideMenuViewController presentMenuViewController];
}
@end
