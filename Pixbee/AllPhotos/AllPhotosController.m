//
//  AllPhotosController.m
//  Pixbee
//
//  Created by skplanet on 2013. 12. 5..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "AllPhotosController.h"
#import "ALLPhotosView.h"
#import "TotalGalleryViewCell.h"
#import "GalleryHeaderView.h"
#import "PBAssetLibrary.h"
#import "PBFilterViewController.h"

@interface AllPhotosController () <UICollectionViewDataSource, UICollectionViewDelegate>{
        NSMutableArray *selectedPhotos;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet ALLPhotosView *allPhotosView;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *shotButton;
@property (strong, nonatomic) TotalGalleryViewCell *selectedCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)DoneClickedHandler:(id)sender;
@end

@implementation AllPhotosController

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
    [self initialNotification];
    
	// Do any additional setup after loading the view.
    if([self.preIdentifier isEqualToString:SEGUE_6_1_TO_4_4]){
        //Change Done button to Share button
        self.doneButton.title = @"Share";
    }
    selectedPhotos = [NSMutableArray array];
    [self reloadDB];
}

- (void)dealloc
{
    [self closeNotification];
}

- (void)initialNotification
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AlbumContentsViewEventHandler:)
												 name:@"AlbumContentsViewEventHandler" object:nil];
}

- (void)closeNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AlbumContentsViewEventHandler" object:nil];
}

- (void)AlbumContentsViewEventHandler:(NSNotification *)notification
{
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"changedGalleryDB"]) {
        
        [self reloadDB];
        [self goBottom];
        
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self goBottom];
}

- (void) reloadDB {
    self.photos = [PBAssetsLibrary sharedInstance].totalAssets;
    int allphotocount = (int)[self.photos count];
//    if (self.photos) {
//        for (NSDictionary *user in self.photos) {
//            NSArray *photos = [user objectForKey:@"photos"];
//            allphotocount += [photos count];
//        }
//    }
    
    self.allPhotosView.countLabel.text = [NSString stringWithFormat:@"%d", allphotocount];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView reloadData];
}

- (void)goBottom
{
    NSInteger section = [self numberOfSectionsInCollectionView:_collectionView] - 1;
    NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];

}

#pragma mark -
#pragma mark PSTCollectionViewDataSource stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if ([[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [self.photos count];
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [[self.photos objectAtIndex:section] count];
    }
    
    return [self.photos count];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GalleryHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GalleryHeaderView" forIndexPath:indexPath];
        NSString *title = [[NSString alloc]initWithFormat:@"Photos Group #%i", indexPath.section + 1];
        headerView.leftLabel.text = title;
        UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
        headerView.backgroundImage.image = headerImage;
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TotalGalleryViewCell";
    
    TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    [cell updateCell:photo];
    
    if ([selectedPhotos containsObject:indexPath]) {
        [cell showSelectIcon:YES];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos addObject:indexPath];
        
        // UI
        TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell showSelectIcon:YES];
        [cell setNeedsDisplay];
        
        unsigned long selectcount = [selectedPhotos count];
        [UIView animateWithDuration:0.3
                         animations:^{
                             if (selectcount > 0) {
                                 self.navigationItem.title = [NSString stringWithFormat:@"%lu Photo Selected", selectcount];
                             }
                             else {
                                 self.navigationItem.title = @"Album";
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
//    else {
//        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        //        [self performSegueWithIdentifier:SEGUE_4_1_TO_5_1 sender:self];
//        
//        //        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
//        //        for (NSDictionary *photoinfo in self.photos) {
//        //            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//        //            [idmPhotos addObject:photo];
//        //        }
//        
//        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
//        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
//        NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//        [idmPhotos addObject:photo];
//        
//        // Create and setup browser
//        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
//        browser.delegate = self;
//        [browser setInitialPageIndex:indexPath.row];
//        browser.displayActionButton = NO;
//        browser.displayArrowButton = NO;
//        //        browser.displayArrowButton = YES;
//        browser.displayCounterLabel = YES;
//        browser.scaleImage = self.selectedCell.photoImageView.image;
//        
//        //        [self.navigationController p presentedViewController:browser];
//        
//        // Show
//        [self presentViewController:browser animated:YES completion:nil];
//        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        [selectedPhotos removeObject:indexPath];
        
        unsigned long selectcount = [selectedPhotos count];
        [UIView animateWithDuration:0.3
                         animations:^{
                             if (selectcount > 0) {
                                 self.navigationItem.title = [NSString stringWithFormat:@"%lu Photo Selected", selectcount];
                             }
                             else {
                                 self.navigationItem.title = @"All Photos";
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
    // UI
    TotalGalleryViewCell *cell = (TotalGalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell showSelectIcon:NO];
    [cell setNeedsDisplay];
}

- (IBAction)DoneClickedHandler:(id)sender {
    // DB작업 후 화면 전환.
    if([self.preIdentifier isEqualToString:SEGUE_6_1_TO_4_4]){
        [self performSegueWithIdentifier:SEGUE_GO_FILTER sender:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_FILTER]){
        self.navigationController.navigationBarHidden = NO;
        PBFilterViewController *destination = segue.destinationViewController;
#warning  호석과장님 아래에 imageData에 NSData 이미지 (jpeg) 집어 넣으면 되...
        destination.imageData = nil;
        
    }
}



@end
