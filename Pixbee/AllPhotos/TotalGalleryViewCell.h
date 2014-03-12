//
//  TotalGalleryViewCell.h
//  FlowLayoutNoNIB
//
//  Created by Beau G. Bolle on 2012.10.29.
//
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface TotalGalleryViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectIcon;
@property (strong, nonatomic) NSDictionary *photo;

- (void)updateCell:(NSDictionary *)photo;
- (void)showSelectIcon:(BOOL)show;

@end
