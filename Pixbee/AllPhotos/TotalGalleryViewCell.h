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

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectIcon;
@property (weak, nonatomic) IBOutlet UIImageView *checkIcon;

@property (strong, nonatomic) ALAsset *asset;

@end
