//
//  CollectionViewCell.m
//  FlowLayoutNoNIB
//
//  Created by Beau G. Bolle on 2012.10.29.
//
//

#import "GalleryViewCell.h"
#import "SDImageCache.h"

@implementation GalleryViewCell

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
	}
	return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self setBackgroundColor:[UIColor blueColor]];
    }
    else {
        [self setBackgroundColor:[UIColor yellowColor]];
    }
}

- (void)updateCell:(NSDictionary *)photo {
    
    NSString *imagePath = [photo objectForKey:@"AssetURL"];
    
    if (imagePath && ![imagePath isEqualToString:@""])
    {
        self.photoImageView.image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imagePath];
        
        if (self.photoImageView.image == nil) {
            ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
            {
                NSLog(@"This debug string was logged after this function was done");
                UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                self.photoImageView.image = image;
                //this line is needed to display the image when it is loaded asynchronously, otherwise image will not be shown as stated in comments
                [self setNeedsLayout];
                
                [[SDImageCache sharedImageCache] storeImage:image forKey:imagePath toDisk:NO];
            };
            
            ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
            {
                NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
            };
            
            [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:imagePath]
                                resultBlock:resultBlock
                               failureBlock:failureBlock];

        }
    }
}

@end
