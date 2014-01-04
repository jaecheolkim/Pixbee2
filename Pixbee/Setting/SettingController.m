//
//  SettingController.m
//  Pixbee
//
//  Created by skplanet on 2014. 1. 4..
//  Copyright (c) 2014년 Pixbee. All rights reserved.
//

#import "SettingController.h"

@interface SettingController ()
//@property (strong, nonatomic) IBOutlet UILabel *accountLabel;
//@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
//@property (strong, nonatomic) IBOutlet UILabel *photoCountLabel;
//@property (strong, nonatomic) IBOutlet UISwitch *autoAnalyzeSwitch;
//@property (strong, nonatomic) IBOutlet UISwitch *optionSwitch;

- (IBAction)autoAnalyzeChange:(id)sender;
- (IBAction)logoutButtonClickHandler:(id)sender;
- (IBAction)settingOptionChange:(id)sender;
- (IBAction)photoCountChange:(id)sender;
- (IBAction)closeClickHandler:(id)sender;

@end

@implementation SettingController

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

- (void)awakeFromNib {
    
    static NSString *CellIdentifier = @"AccountCell";
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *accountLabel = (UILabel *)[cell.contentView viewWithTag:10];
    accountLabel.text = FBHELPER.loggedInUser.id;
    
    BOOL autoanalyze = [[NSUserDefaults standardUserDefaults] boolForKey:@"AUTOANALYZE_VALUE"];
    CellIdentifier = @"AutoAnalyzeCell";
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UISwitch *autoAnalyzeSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
    autoAnalyzeSwitch.on = !autoanalyze;
    
    BOOL option = [[NSUserDefaults standardUserDefaults] boolForKey:@"OPTION_VALUE"];
    CellIdentifier = @"OptionCell";
    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UISwitch *optionSwitch = (UISwitch *)[cell.contentView viewWithTag:10];
    optionSwitch.on = !option;
    
    
    int segmentselect = [[NSUserDefaults standardUserDefaults] integerForKey:@"SEGMEMT_VALUE"];
    CellIdentifier = @"SegmentCell";
    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *photoCountLabel = (UILabel *)[cell.contentView viewWithTag:10];
    UISegmentedControl *segmentcontrol = (UISegmentedControl *)[cell.contentView viewWithTag:20];
    [segmentcontrol setSelectedSegmentIndex:segmentselect];
    
    photoCountLabel.text = [segmentcontrol titleForSegmentAtIndex:[segmentcontrol selectedSegmentIndex]];
    [photoCountLabel setNeedsLayout];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
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
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"AccountCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"AutoAnalyzeCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else if (indexPath.row == 2) {
        static NSString *CellIdentifier = @"OptionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else if (indexPath.row == 3) {
        static NSString *CellIdentifier = @"SegmentCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    // Configure the cell...
    
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
}

- (IBAction)settingOptionChange:(id)sender {
    UISwitch *switchview = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:!switchview.on forKey:@"OPTION_VALUE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)photoCountChange:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    
    static NSString *CellIdentifier = @"SegmentCell";
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *photoCountLabel = (UILabel *)[cell.contentView viewWithTag:10];
    NSString *title = [control titleForSegmentAtIndex:[control selectedSegmentIndex]];
    [photoCountLabel setText:title];
    
    [[NSUserDefaults standardUserDefaults] setInteger:[control selectedSegmentIndex] forKey:@"SEGMEMT_VALUE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

- (IBAction)closeClickHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
