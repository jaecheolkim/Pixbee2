//
//  PBFilterViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "PBFilterViewController.h"

@interface PBFilterViewController ()
{
    UIView *selectedView;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PBFilterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [[UIImage alloc] initWithData:_imageData];
    [_imageView setImage:image];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.98 green:0.96 blue:0.92 alpha:1.0]];
    [self loadFilterImages];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    self.navigationController.title = @"Filter";

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) loadFilterImages {
    _scrollView.backgroundColor = [UIColor blackColor];

    selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 108)];
    [selectedView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.7]];
    [_scrollView addSubview:selectedView];
    
    for(int i = 0; i < 6; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"filter%d", i + 1]] forState:UIControlStateNormal];
        button.frame = CGRectMake(10+i*(76+10), 7.0f, 76.0f, 76.0f);
        button.layer.cornerRadius = 7.0f;
        
        //use bezier path instead of maskToBounds on button.layer
        UIBezierPath *bi = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(7.0,7.0)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = button.bounds;
        maskLayer.path = bi.CGPath;
        button.layer.mask = maskLayer;
        
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [button addTarget:self
                   action:@selector(filterSelected:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [button setTitle:@"*" forState:UIControlStateSelected];
        if(i == 0){
            [button setSelected:YES];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10+i*(76+10), 83.0f, 76.0f, 21.0f)];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:12.0f];
		label.textColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.text = @"filter";
        label.tag = i*100;
        if(i == 0){
            label.textColor = [UIColor yellowColor];
        }
        
		[_scrollView addSubview:button];
        [_scrollView addSubview:label];
	}
	[_scrollView setContentSize:CGSizeMake(10 + 6*(76+10), 108.0)];
}

-(void) filterSelected:(UIButton*)sender {
    for(UIView *view in _scrollView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton *)view setSelected:NO];
            if(view.tag  == sender.tag) [(UIButton *)view setSelected:YES];
        }
        if([view isKindOfClass:[UILabel class]]){
            [(UILabel *)view setTextColor:[UIColor colorWithWhite:0.97f alpha:1.0f]];
            if(view.tag == sender.tag * 100) [(UILabel *)view setTextColor:[UIColor yellowColor]];
        }
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         selectedView.center = CGPointMake(sender.center.x, 108/2);
                         //selectedView.frame = CGRectMake(sender.tag * 90, 0, 88, 108);
                     }
                     completion:nil];



    //[sender setSelected:YES];

    NSLog(@"selectedFilter = %d",(int)sender.tag);

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
