//
//  PBFilterViewController.m
//  Pixbee
//
//  Created by jaecheol kim on 12/28/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "PBFilterViewController.h"

@interface PBFilterViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PBFilterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIImage *image = [[UIImage alloc] initWithData:_imageData];
    [_imageView setImage:image];
    // Dispose of any resources that can be recreated.
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
