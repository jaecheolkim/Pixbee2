//
//  CollectionViewCell.h
//  FlowLayoutNoNIB
//
//  Created by Beau G. Bolle on 2012.10.29.
//
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
@protocol GalleryViewCellDelegate;

@interface GalleryViewCell : UICollectionViewCell
@property (nonatomic, assign) id<GalleryViewCellDelegate> delegate;
@property (strong, nonatomic) NSDictionary *photo;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectIcon;
@property (nonatomic) BOOL checked;

- (void)updateCell:(NSDictionary *)photo;
- (void)showSelectIcon:(BOOL)show;

@end


@protocol GalleryViewCellDelegate <NSObject>
@optional
-(void)cellPressed:(id)sender;
-(void)cellTap:(id)sender;

@end