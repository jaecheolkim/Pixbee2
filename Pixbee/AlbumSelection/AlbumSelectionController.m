//
//  AlbumSelectionController.m
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "AlbumSelectionController.h"
#import "UserCell.h"
#import "SCTInclude.h"
#import "UIView+SubviewHunting.h"

@interface AlbumSelectionController () <UITableViewDelegate, UITableViewDataSource> {
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *usersPhotos;
@property (strong, nonatomic) UserCell *selectedCell;

- (IBAction)doneButtonClickHandler:(id)sender;
- (IBAction)xButtonClickHandler:(id)sender;

- (IBAction)UnwindFromIndividualGalleryToAlbumPage:(UIStoryboardSegue *)segue;

@end

@implementation AlbumSelectionController

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
    
    /************************/

    
    self.usersPhotos = [[SQLManager getAllUserPhotos] mutableCopy];
    //NSLog(@"usersPhotos: %@",_usersPhotos);
    
//    NSDictionary *users = [[self.usersPhotos objectAtIndex:0] copy];
//    NSDictionary *users1 = [[self.usersPhotos objectAtIndex:0] copy];
//    NSDictionary *users2 = [[self.usersPhotos objectAtIndex:0] copy];
//    NSDictionary *users3 = [[self.usersPhotos objectAtIndex:0] copy];
//    
//    NSMutableArray *newuser = [NSMutableArray arrayWithObjects:users, users1, users3, users2, nil];
//    self.usersPhotos = newuser;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersPhotos count];
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
    if (self.selectedCell != nil) {
        self.selectedCell.checkIcon.image = [UIImage imageNamed:@"uncheck.png"];
    }
    
    self.selectedCell = (UserCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedCell.checkIcon.image = [UIImage imageNamed:@"check.png"];
}


- (IBAction)doneButtonClickHandler:(id)sender {
}

- (IBAction)xButtonClickHandler:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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

}

@end
