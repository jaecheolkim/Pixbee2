//
//  IndividualGalleryController.m
//  Pixbee
//
//  Created by 호석 이 on 2013. 11. 30..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "IndividualGalleryController.h"
#import "GalleryViewCell.h"
#import "GalleryHeaderView.h"
#import "UserCell.h"
#import "OpenPhotoSegue.h"
#import "OpenPhotoUnwindSegue.h"
#import "SCTInclude.h"
#import "IDMPhotoBrowser.h"

@interface IndividualGalleryController () <UICollectionViewDataSource, UICollectionViewDelegate, IDMPhotoBrowserDelegate>{
    NSMutableArray *selectedPhotos;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UserCell *userProfileView;
@property (strong, nonatomic) GalleryViewCell *selectedCell;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSDictionary *user;

- (IBAction)editButtonClickHandler:(id)sender;
- (IBAction)albumButtonClickHandler:(id)sender;

@end

@implementation IndividualGalleryController

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
    selectedPhotos = [NSMutableArray array];
    
    self.photos = [self.usersPhotos objectForKey:@"photos"];
    self.user = [self.usersPhotos objectForKey:@"user"];
    
    [self.userProfileView.borderView removeFromSuperview];
    self.userProfileView.borderView = nil;
    [self.userProfileView updateCell:self.user count:[self.photos count]];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    [self.collectionView reloadData];
    [self.userProfileView.borderView removeFromSuperview];
    self.userProfileView.borderView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PSTCollectionViewDataSource stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (([self.photos count] > 0) && [[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return [self.photos count];
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (([self.photos count] > 0) && [[self.photos objectAtIndex:0] isKindOfClass:[NSArray class]]) {
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
    static NSString *identifier = @"GalleryViewCell";
    
    GalleryViewCell *cell = (GalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    [cell updateCell:photo];

    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue isKindOfClass:[OpenPhotoSegue class]]) {
        // Set the start point for the animation to center of the button for the animation
        CGPoint point2 = [self.view convertPoint:self.selectedCell.center fromView:self.collectionView];
        ((OpenPhotoSegue *)segue).originatingPoint = point2;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        [selectedPhotos addObject:photo];
        
        // UI
        GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setSelected:YES];
        [cell setNeedsDisplay];
    }
    else {
        
        self.selectedCell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        [self performSegueWithIdentifier:SEGUE_6A_TO_10A sender:self];
        
//        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:[self.photos count]];
//        for (NSDictionary *photoinfo in self.photos) {
//            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
//            [idmPhotos addObject:photo];
//        }
        
        NSMutableArray *idmPhotos = [NSMutableArray arrayWithCapacity:1];
        NSDictionary *photoinfo = [self.photos objectAtIndex:indexPath.row];
            NSString *photo = [photoinfo objectForKey:@"AssetURL"];
            [idmPhotos addObject:photo];
        
        // Create and setup browser
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:idmPhotos animatedFromView:self.selectedCell]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
        browser.delegate = self;
        [browser setInitialPageIndex:indexPath.row];
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
//        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.scaleImage = self.selectedCell.photoImageView.image;
        
//        [self.navigationController p presentedViewController:browser];
        
        // Show
        [self presentViewController:browser animated:YES completion:nil];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.allowsMultipleSelection) {
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        [selectedPhotos removeObject:photo];

        // UI
        GalleryViewCell *cell = (GalleryViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setSelected:NO];
        [cell setNeedsDisplay];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.collectionView.allowsMultipleSelection) {
        return NO;
    } else {
        return YES;
    }
}

//- (IBAction)shareButtonTouched:(id)sender {
//    if (shareEnabled) {
//        
//        // Post selected photos to Facebook
//        if ([selectedRecipes count] > 0) {
//            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//                
//                [controller setInitialText:@"Check out my recipes!"];
//                for (NSString *recipePhoto in selectedRecipes) {
//                    [controller addImage:[UIImage imageNamed:recipePhoto]];
//                }
//                
//                [self presentViewController:controller animated:YES completion:Nil];
//            }
//        }
//        
//        // Deselect all selected items
//        for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
//            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
//        }
//        
//        // Remove all items from selectedRecipes array
//        [selectedRecipes removeAllObjects];
//        
//        // Change the sharing mode to NO
//        shareEnabled = NO;
//        self.collectionView.allowsMultipleSelection = NO;
//        self.shareButton.title = @"Share";
//        [self.shareButton setStyle:UIBarButtonItemStylePlain];
//        
//    } else {
//        
//        // Change shareEnabled to YES and change the button text to DONE
//        shareEnabled = YES;
//        self.collectionView.allowsMultipleSelection = YES;
//        self.shareButton.title = @"Upload";
//        [self.shareButton setStyle:UIBarButtonItemStyleDone];
//        
//    }
//}
//
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Check delegate: should cell %@ be selected?", [self formatIndexPath:indexPath]);
//    return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Check delegate: should cell %@ be deselected?", [self formatIndexPath:indexPath]);
//    return YES;
//}

#pragma mark -
#pragma mark ButtonAction
- (IBAction)editButtonClickHandler:(id)sender {
    self.collectionView.allowsMultipleSelection = !self.collectionView.allowsMultipleSelection;
}

- (IBAction)albumButtonClickHandler:(id)sender {
}

- (IBAction)backButtonClickHandler:(id)sender {
    [self dismissCustomSegueViewControllerWithCompletion:^(BOOL finished) {
        NSLog(@"Dismiss complete!");
    }];
}


- (IBAction)UnwindFromFullScreenPhotoToIndividualGallery:(UIStoryboardSegue *)segue{
    
}

// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // Instantiate a new CustomUnwindSegue
    OpenPhotoUnwindSegue *segue = [[OpenPhotoUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    // Set the target point for the animation to the center of the button in this VC
    CGPoint point = [self.collectionView convertPoint:self.selectedCell.center toView:self.view];
    segue.targetPoint = point;
    return segue;
}


@end
