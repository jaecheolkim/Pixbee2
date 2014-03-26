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
@property (weak, nonatomic) IBOutlet UIImageView *checkIcon;
//@property (strong, nonatomic) NSDictionary *photo;
@property(nonatomic, strong) ALAsset *asset;
@property(nonatomic, strong) NSDictionary *photoInfo;

- (void)updateCell:(NSDictionary *)photo;
- (void)showSelectIcon:(BOOL)show;

@end
