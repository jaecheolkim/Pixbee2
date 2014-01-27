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
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor blueColor];
        bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
        bgView.layer.borderWidth = 4;
        self.selectedBackgroundView = bgView;
        
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        
        UILongPressGestureRecognizer *longPressPressGestureRecognizer
        = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressItem:)];
        [self addGestureRecognizer:longPressPressGestureRecognizer];


    }
    return self;
}

- (void)tapItem:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(cellTap:)]){
        [self.delegate cellTap:self];
    }
}

- (void)longPressItem:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(cellPressed:)]){
        [self.delegate cellPressed:self];
    }
}



- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
}

- (void)showSelectIcon:(BOOL)show {
    if (show) {
        self.selectIcon.hidden = NO;
    }
    else {
        self.selectIcon.hidden = YES;
    }
}

- (void)updateCell:(NSDictionary *)photo {
    
    [self showSelectIcon:NO];
    
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
