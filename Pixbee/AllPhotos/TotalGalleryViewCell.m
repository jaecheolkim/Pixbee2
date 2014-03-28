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
    }
    else {
        self.checkIcon.hidden = YES;
    }
}


- (void)setAsset:(ALAsset *)asset
{
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    self.checkIcon.hidden = YES;
    self.selectIcon.hidden = YES;
  
}

@end
