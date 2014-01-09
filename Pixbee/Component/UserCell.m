//
//  UserCell.m
//  Pixbee
//
//  Created by skplanet on 2013. 12. 3..
//  Copyright (c) 2013년 Pixbee. All rights reserved.
//

#import "UserCell.h"
#import "UIView+Hexagon.h"
#import "UIView+SubviewHunting.h"

@interface UserCell () <UITextFieldDelegate> {
    BOOL editMode;
}

@end

@implementation UserCell

@synthesize delegate;
@synthesize userImage;
@synthesize userName;
@synthesize editButton;
@synthesize countLabel;
@synthesize arrowIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"style");
    UIImageView *border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"individualbar.png"]];
    border.frame = CGRectMake(3, 3, 314, 76);
    self.borderView = border;
    [self addSubview:border];
    [self bringSubviewToFront:self.contentView];
    [self.userImage configureLayerForHexagon];
    
    self.inputName.delegate = self;
    [self.inputName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editMode animated:animated];
    
    UIView* reorderControl = [self huntedSubviewWithClassName:@"UITableViewCellReorderControl"];
    
    for(UIImageView* subview in reorderControl.subviews) {
        if ([subview isKindOfClass: [UIImageView class]]) {
            ((UIImageView *)subview).image = [UIImage imageNamed: @"list.png"];
            ((UIImageView *)subview).frame = CGRectMake(0, 0, 16, 16);
        }
    }

    [UIView animateWithDuration:0.1
                     animations:^{
                         if (editMode) {
                             self.userName.alpha = 0;
                             self.countLabel.alpha = 0;
                             self.editButton.alpha = 0;
                             
                             self.doneButton.alpha = 1;
                             self.inputName.alpha = 1;
                             self.lineView.alpha = 1;
                             self.trashButton.alpha = 1;
                         }
                         else {
                             self.userName.alpha = 1;
                             self.countLabel.alpha = 1;
                             self.editButton.alpha = 1;
                             
                             self.doneButton.alpha = 0;
                             self.inputName.alpha = 0;
                             self.lineView.alpha = 0;
                             self.trashButton.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)updateBorder:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.borderView.frame = CGRectMake(3, 3, self.frame.size.width-6, 76);
    }
    else {
        self.borderView.frame = CGRectMake(3, 1.5, self.frame.size.width-6, 76);
    }
}

- (void)updateCell:(NSDictionary *)user count:(NSUInteger)count{
    /*
     UserID         :  로컬 UserID	: int  (auto gen.)
     UserName		:  사용자 이름 (default = nil / fbName)	: text
     GUID           :  서비스 연동시 필요한 Unique Global User id (default = nil / )	: text
     UserNick		:  사용자 닉네임 (default = nil / fbName) 	: text
     UserProfile	:  사용자 프로필 사진 (default = nil / fbProfile)	: blob
     fbID			:  페북 ID	(default = nil) 	: text
     fbName         :  페북 사용자명	(default = nil)	: text
     fbProfile		:  페북 프로필 사진 	(default = nil)	: blob
     timestamp      :  생성일자		: datetime
     */
    
    int UserID = [[user objectForKey:@"UserID"] intValue];
    
    // 사용자 이미지
    if(IsEmpty([user objectForKey:@"UserProfile"])) {
        [self.userImage setImage:[SQLManager getUserProfileImage:UserID]];
    } else {
        NSString *urlSting = [user objectForKey:@"UserProfile"];
        if ([urlSting hasPrefix:@"http"]){
            [self.userImage setImageWithURL:[NSURL URLWithString:urlSting]
                           placeholderImage:[UIImage imageNamed:@"photo_profile_hive@2x.png"]];
        }
        else if([urlSting hasSuffix:@"png"]) {
            [self.userImage setImage:[SQLManager getUserProfileImage:UserID]];
        }
    }

    
    // 사용자 이름
    [self.userName setText:[user objectForKey:@"UserName"]];
    [self.inputName setText:@""];
    
    // 사용자 사진
    [self.countLabel setText:[NSString stringWithFormat:@"%ld", (unsigned long)count]];
}

- (IBAction)editButtonClickHandler:(id)sender {
    
    editMode = YES;
    
    if([self.delegate respondsToSelector:@selector(editUserCell:)])
    {
        [self.delegate editUserCell:self];
    }
    
    [self.inputName becomeFirstResponder];
}

- (IBAction)doneButtonClickHandler:(id)sender {

    editMode = NO;
    [self.inputName resignFirstResponder];
  
    if([self.delegate respondsToSelector:@selector(doneUserCell:)])
    {
        [self.delegate doneUserCell:self];
    }
}

- (IBAction)deleteButtonClickHandler:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(deleteUserCell:)])
    {
        [self.delegate deleteUserCell:self];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(editUserCell:)])
    {
        [self.delegate frientList:self appear:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(frientList:appear:)])
    {
        [self.delegate frientList:self appear:NO];
    }
}

-(void)textFieldDidChange:(id)sender {
    // whatever you wanted to do
    if([self.delegate respondsToSelector:@selector(searchFriend:name:)])
    {
        [self.delegate searchFriend:self name:self.inputName.text];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.editing) {
        return;
    }
    

    
  //  [reorderControl setBackgroundColor:[UIColor redColor]];
    
//    void (^enumBlock) (id, NSUInteger, BOOL *) = ^(UIView *subview, NSUInteger idx, BOOL *stop) {
//        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellReorderControl"]) {
////            [subview setHidden:YES];
//            NSLog(@"%@", subview);
//            *stop = YES;
//        }
//    };
//    
//    [self.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:enumBlock];
}

@end
