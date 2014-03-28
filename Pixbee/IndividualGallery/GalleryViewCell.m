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
@synthesize delegate;
//- (id)initWithFrame:(CGRect)frame {
//	self = [super initWithFrame:frame];
//	if (self) {
//	}
//	return self;
//}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

//        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
//        [self addGestureRecognizer:tapGestureRecognizer];
        
        
        UILongPressGestureRecognizer *longPressPressGestureRecognizer
        = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressItem:)];
        [self addGestureRecognizer:longPressPressGestureRecognizer];


    }
    return self;
}

//- (void)tapItem:(id)sender
//{
//    
//    if ([self.delegate respondsToSelector:@selector(cellTap:)]){
//        [self.delegate cellTap:self];
//    }
//}

- (void)longPressItem:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(cellPressed:)]){
        [self.delegate cellPressed:self];
    }
}



- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    //self.checked = selected;
    
    if(self.selected){
        self.checkIcon.hidden = NO;
    }
    else {
        self.checkIcon.hidden = YES;
    }
}


- (void)setPhoto:(NSDictionary *)photo
{
    self.checkIcon.hidden = YES;
    self.selectIcon.hidden = YES;

    
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
