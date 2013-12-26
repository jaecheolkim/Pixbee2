#import "IntroModel.h"

@implementation IntroModel

@synthesize titleText;
@synthesize descriptionText;
@synthesize image;
@synthesize closeButton;

- (id) initWithTitle:(NSString*)title description:(NSString*)desc image:(NSString*)imageText {
    return [self initWithTitle:title description:desc image:imageText button:nil];
}

- (id) initWithTitle:(NSString*)title description:(NSString*)desc image:(NSString*)imageText button:(UIButton *)button {
    self = [super init];
    if(self != nil) {
        titleText = title;
        descriptionText = desc;
        image = [UIImage imageNamed:imageText];
        closeButton = button;
    }
    return self;
}

@end
