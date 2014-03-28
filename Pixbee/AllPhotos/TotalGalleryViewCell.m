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


- (void)setAsset:(ALAsset *)asset
{
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    self.checkIcon.hidden = YES;
    self.selectIcon.hidden = YES;
  
}

@end
