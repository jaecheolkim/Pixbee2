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
    
    _nameTextField.delegate = self;
    [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setUserColor:(int)userColor
{
    UIColor *color = [SQLManager getUserColor:userColor];
    [_nameLabel setBackgroundColor:color];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
   _profileImageView.alpha = highlighted ? 0.75f : 1.0f;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(self.selected) _checkImageView.image = [UIImage imageNamed:@"checked"];
    else _checkImageView.image = [UIImage imageNamed:@"checkbox"];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = self.nameLabel.text;
    self.nameLabel.text = nil;
    NSLog(@"textFieldDidBeginEditing:");
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(!IsEmpty(textField.text)){
        self.nameLabel.text = textField.text;
    } else {
        self.nameLabel.text = userName;
    }

    textField.text = nil;
    textField.placeholder = nil;
    NSLog(@"textFieldDidEndEditing:");
}
- (void)textFieldDidChange:(id)sender {
    
    
    NSLog(@"textFieldDidChange:");
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSLog(@"textFieldShouldReturn:");
    return [textField resignFirstResponder];
}


@end
