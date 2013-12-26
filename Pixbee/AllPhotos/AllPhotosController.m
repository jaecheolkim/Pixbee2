//
//  AllPhotosController.m
//  Pixbee
//
//  Created by skplanet on 2013. 12. 5..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "AllPhotosController.h"
#import "ALLPhotosView.h"
#import "GalleryViewCell.h"
#import "GalleryHeaderView.h"

@interface AllPhotosController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet ALLPhotosView *allPhotosView;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *shotButton;
@property (strong, nonatomic) GalleryViewCell *selectedCell;

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
	// Do any additional setup after loading the view.
    
    [self calAllPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) calAllPhotos {
    int allphotocount = 0;
    if (self.photos) {
        for (NSDictionary *user in self.photos) {
            NSArray *photos = [user objectForKey:@"photos"];
            allphotocount += [photos count];
        }
    }
    
    self.allPhotosView.countLabel.text = [NSString stringWithFormat:@"%d", allphotocount];
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
    static NSString *identifier = @"GalleryViewCell";
    
    GalleryViewCell *cell = (GalleryViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    [cell updateCell:photo];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-selected.png"]];
    
    return cell;
}

@end
