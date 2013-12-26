#import <Foundation/Foundation.h>

@interface IntroModel : NSObject

@property (nonatomic, strong) NSString  *titleText;
@property (nonatomic, strong) NSString  *descriptionText;
@property (nonatomic, strong) UIImage   *image;
@property (nonatomic, strong) UIButton  *closeButton;

- (id) initWithTitle:(NSString*)title description:(NSString*)desc image:(NSString*)imageText;
- (id) initWithTitle:(NSString*)title description:(NSString*)desc image:(NSString*)imageText button:(UIButton *)button;

@end
