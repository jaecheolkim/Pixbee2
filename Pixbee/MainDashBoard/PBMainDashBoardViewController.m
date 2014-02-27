//
//  PBMainDashBoardViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 2/26/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//
#import "LXReorderableCollectionViewFlowLayout.h"
#import "PBMainDashBoardViewController.h"
#import "ProfileCard.h"
#import "ProfileCardCell.h"
#import "SDImageCache.h"
#import "UIImage+ImageEffects.h"

// LX_LIMITED_MOVEMENT:
// 0 = Any card can move anywhere
// 1 = Only Spade/Club can move within same rank

#define LX_LIMITED_MOVEMENT 0

@interface PBMainDashBoardViewController()
<LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>
{
    BOOL EDIT_MODE;
}


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *collectionBGView;
@property (strong, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;

@property (strong, nonatomic) NSMutableArray *deck;

@property (weak, nonatomic) NSMutableArray *usersPhotos;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

- (IBAction)leftBarButtonHandler:(id)sender;
- (IBAction)rightBarButtonHandler:(id)sender;
- (IBAction)galleryButtonHandler:(id)sender;
- (IBAction)shutterButtonHandler:(id)sender;

@end

@implementation PBMainDashBoardViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    EDIT_MODE = NO;

    self.title = @"11 Faces";


    // 제일 마지막에 저장된 사진의 Blur Image를 백그라운드 깔아 준다.
    UIImage *lastImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"LastImage"];
    lastImage = [lastImage applyLightEffect];
    
    if(IsEmpty(lastImage)) lastImage = [UIImage imageNamed:@"defaultBG"];
    
    [self.collectionBGView setImage:lastImage];
    

    
    self.usersPhotos = [SQLManager getAllUserPhotos];
    NSLog(@"self.usersPhotos = %@", self.usersPhotos);
    
    self.deck = [self constructsDeck];
    NSLog(@"self.deck = %@", self.deck);
}

- (NSMutableArray *)constructsDeck {
    NSMutableArray *newDeck = [NSMutableArray arrayWithCapacity:52];
    
    for (NSInteger rank = 1; rank <= 13; rank++) {
        // Spade
        {
            ProfileCard *playingCard = [[ProfileCard alloc] init];
            playingCard.suit = PlayingCardSuitSpade;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
        
        // Heart
        {
            ProfileCard *playingCard = [[ProfileCard alloc] init];
            playingCard.suit = PlayingCardSuitHeart;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
        
        // Club
        {
            ProfileCard *playingCard = [[ProfileCard alloc] init];
            playingCard.suit = PlayingCardSuitClub;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
        
        // Diamond
        {
            ProfileCard *playingCard = [[ProfileCard alloc] init];
            playingCard.suit = PlayingCardSuitDiamond;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
    }
    
    return newDeck;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return self.deck.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCard *profileCard = [self.deck objectAtIndex:indexPath.item];
    ProfileCardCell *profileCardCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCardCell" forIndexPath:indexPath];
    profileCardCell.profileCard = profileCard;
    [(UICollectionViewCell *)profileCardCell setSelected:NO];
    profileCardCell.checkImageView.hidden = YES;
    
    return profileCardCell;
}


//- (NSArray *)indexPathsForSelectedItems; // returns nil or an array of selected index paths
//- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
//{
//    
//}
//- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
//{
//    
//}


// (when the touch lifts)
// 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
// 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
// 5. -collectionView:didUnhighlightItemAtIndexPath:
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//// called when the user taps on an already-selected item in multi-select mode
//{
//    return NO;
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    ProfileCardCell *playingCardCell = (ProfileCardCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if(EDIT_MODE){
        if(!playingCardCell.checkImageView.hidden)
        {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            
            [(UICollectionViewCell *)playingCardCell setSelected:NO];
            playingCardCell.checkImageView.hidden = YES;
        }
        else {
           [(UICollectionViewCell *)playingCardCell setSelected:YES];
            playingCardCell.checkImageView.hidden = NO;
        }
        
    } else {
        NSLog(@"go to detail view");
    }
    
     NSLog(@"didSelectItemAtIndexPath : %@", self.collectionView.indexPathsForSelectedItems);
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectItemAtIndexPath : %@", self.collectionView.indexPathsForSelectedItems);
    
    if(EDIT_MODE){
        
        ProfileCardCell *playingCardCell = (ProfileCardCell *)[collectionView cellForItemAtIndexPath:indexPath];

        [(UICollectionViewCell *)playingCardCell setSelected:NO];
        playingCardCell.checkImageView.hidden = YES;
    }

}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
}



#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    ProfileCard *profileCard = [self.deck objectAtIndex:fromIndexPath.item];
    
    [self.deck removeObjectAtIndex:fromIndexPath.item];
    [self.deck insertObject:profileCard atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
}



#pragma mark - Button Handler

//Settung Button
- (IBAction)leftBarButtonHandler:(id)sender {
    NSLog(@"clicked leftBarButtonHandler");
}

//Edit Button
- (IBAction)rightBarButtonHandler:(id)sender {
     NSLog(@"clicked rightBarButtonHandler");
    EDIT_MODE = !EDIT_MODE;
    
    if(EDIT_MODE){
        self.rightBarButton.image = nil;
       self.rightBarButton.title = @"Cancel";
    }
    else {
        self.rightBarButton.title = nil;
        self.rightBarButton.image = [UIImage imageNamed:@"edit"];
        
        NSLog(@"clean selectItemAtIndexPath : %@", self.collectionView.indexPathsForSelectedItems);
        
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            ProfileCardCell *profileCardCell = (ProfileCardCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [(UICollectionViewCell *)profileCardCell setSelected:NO];
            profileCardCell.checkImageView.hidden = YES;
        }
    }

    [self.collectionView setAllowsMultipleSelection:EDIT_MODE];
}

- (IBAction)galleryButtonHandler:(id)sender {
     NSLog(@"clicked galleryButtonHandler");
}

- (IBAction)shutterButtonHandler:(id)sender {
     NSLog(@"clicked shutterButtonHandler");
}
@end
