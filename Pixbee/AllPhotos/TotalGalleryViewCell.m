//
//  TotalGalleryViewCell.m
//  FlowLayoutNoNIB
//
//  Created by Beau G. Bolle on 2012.10.29.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "TotalGalleryViewCell.h"
#import "SDImageCache.h"

@implementation TotalGalleryViewCell

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {

	}
	return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(self.selected){
        self.checkIcon.hidden = NO;
        //self.selectIcon.image = [UIImage imageNamed:@"check"];
    }
    else {
        self.checkIcon.hidden = YES;
        //self.selectIcon.image = nil;
    }
}

//- (void)setPhoto:(NSDictionary *)photo
//{
//    ALAsset *asset= [photo objectForKey:@"Asset"];
//    
//    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
//    
//    self.checkIcon.hidden = YES;
//    self.selectIcon.hidden = YES;
//}

- (void)setAsset:(ALAsset *)asset
{
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    self.checkIcon.hidden = YES;
    self.selectIcon.hidden = YES;
  
}

- (void)setPhotoInfo:(NSDictionary *)photoInfo
{
    NSString *AssetURL = photoInfo[@"AssetURL"];
    
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
    {
        NSLog(@"This debug string was logged after this function was done");

        self.asset = asset;
        
        //[self setAsset:asset];
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
    {
        NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
    };
    
    [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:AssetURL]
                            resultBlock:resultBlock
                           failureBlock:failureBlock];
}

- (void)showSelectIcon:(BOOL)show {
//    if (show) {
//        self.selectIcon.hidden = NO;
//    }
//    else {
//        self.selectIcon.hidden = YES;
//    }
}

- (void)updateCell:(NSDictionary *)photo {
    
    //[self showSelectIcon:NO];
    
    ALAsset *asset= [photo objectForKey:@"Asset"];
    
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
//    if (asset)
//    {
//        self.photoImageView.image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imagePath];
//        
//        if (self.photoImageView.image == nil) {
//            ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
//            {
//                NSLog(@"This debug string was logged after this function was done");
//                UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
//                self.photoImageView.image = image;
//                //this line is needed to display the image when it is loaded asynchronously, otherwise image will not be shown as stated in comments
//                [self setNeedsLayout];
//                
//                [[SDImageCache sharedImageCache] storeImage:image forKey:imagePath toDisk:NO];
//            };
//            
//            ALAssetsLibraryAccessFailureBlock failureBlock  = ^(NSError *error)
//            {
//                NSLog(@"Unresolved error: %@, %@", error, [error localizedDescription]);
//            };
//            
//            [AssetLib.assetsLibrary assetForURL:[NSURL URLWithString:imagePath]
//                                resultBlock:resultBlock
//                               failureBlock:failureBlock];
//        }
//    }
}

@end
