//
//  CollectionViewCell.h
//  FlowLayoutNoNIB
//
//  Created by Beau G. Bolle on 2012.10.29.
//
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface GalleryViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectIcon;

- (void)updateCell:(NSDictionary *)photo;
- (void)showSelectIcon:(BOOL)show;

@end
