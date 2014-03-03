//
//  PBCommonViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 1/29/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBCommonViewController.h"
#import "SDImageCache.h"
#import "UIImage+ImageEffects.h"

@interface PBCommonViewController () //<UITextFieldDelegate>

@end

@implementation PBCommonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        


    }
    return self;
}

- (void)refreshNavigationBarColor:(UIColor*)color
{
    if(color != nil){

        [[UINavigationBar appearance] setBarTintColor:color];
    } else {
        //Clear Navigationbar
        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];

    }
}

- (void)refreshBGImage:(UIImage*)image
{

    if(IsEmpty(_bgImageView))
        _bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIImage *lastImage;
    
    if(image != nil) {
        lastImage = image;
    } else {
        lastImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"LastImage"];
        if(IsEmpty(lastImage)) {
            lastImage = [UIImage imageNamed:@"bg.png"];
        }
    }
    
    
    lastImage = [lastImage applyLightEffect];
    _bgImageView.image = lastImage;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor grayColor];// [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           NAVIGATION_TITLE_COLOR, NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"GillSans-Medium" size:21.0], NSFontAttributeName, nil]];

    [self initialNotification];
    
    [self addColorBar];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self closeNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)initialNotification
{
    //KEYBOARD OBSERVERS
    /************************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    /************************/
    
}

- (void)closeNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification {
}

-(void)keyboardDidShow:(NSNotification*)notification {
}

-(void)keyboardWillHide:(NSNotification*)notification {
}

-(void)keyboardDidHide:(NSNotification*)notification {
}


//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
//}
//- (void)textFieldDidChange:(id)sender {
//    
//}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    return NO;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (UIButton*)getColorButton:(int)i {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *bgColor = [SQLManager getUserColor:i];

    [button setBackgroundColor:bgColor];
    [button addTarget:self action:@selector(colorButtonHandler:) forControlEvents: UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:CGRectMake(i * 32, 0, 32, 25)];
    [button setTag:i];
//    [button setBackgroundImage:image forState:UIControlStateNormal];
//    [button setBackgroundImage:selectedImage forState:UIControlStateDisabled];
    return button;
}


- (void)addColorBar
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.colorBar = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, 320, 25)];

    for(int i = 0 ; i < 10; i++){
        UIButton *colorButton = [self getColorButton:i];
        [self.colorBar addSubview:colorButton];
    }

}

- (void)colorButtonHandler:(id)sender {
}

@end
