//
//  DemoTableControllerViewController.m
//  FPPopoverDemo
//
//  Created by Alvise Susmel on 4/13/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//

#import "FBFriendController.h"
#import "FBHelper.h"
#import "UIImageView+WebCache.h"
#import "FriendCell.h"

@interface FBFriendController ()

@end

@implementation FBFriendController

@synthesize delegate=_delegate;
@synthesize tableView;
@synthesize searchFriends;
@synthesize searchTerm;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchFriends = FBHELPER.friends ;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (FriendCell *)[nib objectAtIndex:0];
    }
    
    NSDictionary *friend = [self.searchFriends objectAtIndex:indexPath.row];
    [cell updateFriendCell:friend];
       
    return cell;
}

- (void)appearPopup:(CGPoint)point reverse:(BOOL)reverse {

    //CGRect frame = CGRectMake(point.x, point.y, 115, 95);
    CGRect frame = CGRectMake(point.x, point.y, 292, 250);
    
    [self.view setFrame:frame];
    
    if (self.delegate) {
        
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [((UIViewController *)self.delegate).view addSubview:self.view];
            
        }
        else if ([self.delegate isKindOfClass:[UIView class]]){
            [((UIView *)self.delegate) addSubview:self.view];
        }
        
        self.view.alpha = 0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view.alpha = 1.0;
                        }
                         completion:^(BOOL finished){

                         }];

        
    }
}

- (void)disAppearPopup {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.delegate respondsToSelector:@selector(selectedFBFriend:)])
    {
        NSDictionary *friend = [self.searchFriends objectAtIndex:indexPath.row];
        [self.delegate selectedFBFriend:friend];
    }
}


// 실질적인 검색기능을 하는 곳이다.
- (void)handleSearchForTerm:(NSString *)searchterm {
    NSMutableArray *search = [[NSMutableArray alloc] init];
    
    if ([searchterm isEqualToString:@""]) {
        self.searchFriends = FBHELPER.friends;
        [self.tableView reloadData];
        return;
    }
    
    // row 단위 루프
    for (NSDictionary *friend in FBHELPER.friends) {
        // 조건 검색
        // rangeOfString는 location, length멤버를 가지고 있다. 이중 location값을 찾을 수 없다면 제외 대상이 되는 것이다.
        // NSCaseInsensitiveSearch 대소문자 무시
        NSString *name = [friend objectForKey:@"name"];
        if ([name rangeOfString:searchterm options:NSCaseInsensitiveSearch].location != NSNotFound){
            [search addObject:friend];
        }
    }
    
    self.searchFriends = search;
    [self.tableView reloadData];
}

@end
