//
//  ProfileCardCell.m
//  Pixbee
//
//  Created by jaecheol kim on 2/26/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//


#import "ProfileCardCell.h"
#import "UIImageView+WebCache.h"

@interface ProfileCardCell () <UITextFieldDelegate>
{
    NSString *userName;
    int UserID;
    int colorValue;
}
@end

@implementation ProfileCardCell
@synthesize delegate;

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-2.png"]];
    
    //[self resetFontShape:_nameLabel];
 
//    _nameTextField.delegate = self;
//    [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

}


- (void)resetFontShape
{
    

    
//    label.attributedText=[[NSAttributedString alloc]
//                               initWithString:@"string to both stroke and fill"
//                               attributes:@{
//                                            NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-3.0],
//                                            NSStrokeColorAttributeName:[UIColor yellowColor],
//                                            NSForegroundColorAttributeName:[UIColor redColor]
//                                            }
//                               ];

    
//    label.layer.shadowColor = [[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7] CGColor];
//    label.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
//    label.layer.shadowOpacity = 1.0f;
//    label.layer.shadowRadius = 1.0f;
    
    
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_nameLabel setShadowColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3]];
    [_nameLabel setShadowOffset:CGSizeMake(0, 1)];
    [_nameLabel setNumberOfLines:1];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
//
}




- (void)setUserInfo:(NSDictionary *)userInfo
{
    _userInfo = userInfo;
    
    userName = _userInfo[@"UserName"];
    
    UserID = [_userInfo[@"UserID"] intValue];
    
    colorValue = 0;
    
    if(!IsEmpty(_userInfo[@"color"])) {
        colorValue = [_userInfo[@"color"] intValue] ;
    }

    [self setUserColor:colorValue];

    [_profileImageView setImage:[SQLManager getUserProfileImage:UserID]];
     _nameLabel.text = userName;
    
    
//    _nameLabel.attributedText = [[NSAttributedString alloc]
//                                 initWithString:userName
//                                 attributes:@{
//                                              NSForegroundColorAttributeName :[UIColor whiteColor],
//                                              NSStrokeWidthAttributeName: [NSNumber numberWithFloat:3.0],
//                                              NSStrokeColorAttributeName:[UIColor grayColor]
//                                              }
//                                 ];
    
}

- (void)setUserColor:(int)userColor
{
    UIColor *color = [SQLManager getUserColor:userColor alpha:0.5];
    [_nameLabel setBackgroundColor:color];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
   _profileImageView.alpha = highlighted ? 0.75f : 1.0f;
}

//- (void)setSelected:(BOOL)selected
//{
//    [super setSelected:selected];
//    
//    if(self.selected) _checkImageView.image = [UIImage imageNamed:@"check"];
//    else _checkImageView.image = nil;//[UIImage imageNamed:@"checkbox"];
//}
//
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    textField.placeholder = self.nameLabel.text;
//    self.nameLabel.text = nil;
//    
//    
//    if([self.delegate respondsToSelector:@selector(nameDidBeginEditing:)])
//    {
//        [self.delegate nameDidBeginEditing:self];
//    }
//    
//    NSLog(@"textFieldDidBeginEditing:");
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if(!IsEmpty(textField.text)){
//        self.nameLabel.text = textField.text;
//    } else {
//        self.nameLabel.text = userName;
//    }
//
//    textField.text = nil;
//    textField.placeholder = nil;
//    
//    if([self.delegate respondsToSelector:@selector(nameDidEndEditing:)])
//    {
//        [self.delegate nameDidEndEditing:self];
//    }
//    NSLog(@"textFieldDidEndEditing:");
//}
//- (void)textFieldDidChange:(id)sender {
//    
//    if([self.delegate respondsToSelector:@selector(nameDidChange:)])
//    {
//        [self.delegate nameDidChange:self];
//    }
//    NSLog(@"textFieldDidChange:");
//}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    
//    NSLog(@"textFieldShouldReturn:");
//    return [textField resignFirstResponder];
//}


@end
