#import "IntroViewController.h"
#import "IntroControll.h"
#import "PBAppDelegate.h"

@implementation IntroViewController
@synthesize callerID;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    self.wantsFullScreenLayout = YES;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

- (void) loadView {
    [super loadView];
    
//    IntroModel *model1 = [[IntroModel alloc] initWithTitle:@"Example 1" description:@"Hi, my name is Dmitry" image:@"image1.jpg"];
//    
//    IntroModel *model2 = [[IntroModel alloc] initWithTitle:@"Example 2" description:@"Several sample texts in Old, Middle, Early Modern, and Modern English are provided here for practice, reference, and reading." image:@"image2.jpg"];
//    
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 487, 260, 53)];
//    [button addTarget:self action:@selector(action:) forControlEvents: UIControlEventTouchUpInside];
//    
//    IntroModel *model3 = [[IntroModel alloc] initWithTitle:@"Example 3" description:@"The Tempest is the first play in the First Folio edition (see the signature) even though it is a later play (namely 1610) than Hamlet (1600), for example. The first page is reproduced here" image:@"image3.jpg" button:button];
    
    NSString *Title[5] = {@"Welcome to pixbee", @"Register or Tag the face", @"Organize", @"Share", @"Smart and Fun"};
    NSString *Message[5] = {@"Redefined the camera \nfrom the human face", @"Pixbee detects face \nautomatically", @"Manage your memories \nby your friends or family", @"Share your memories with \nyour friends and family", @"With pixbee \nyou can enjoy photo-taking \nwith your friends and family \nin simpler and smater way"};
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 487, 260, 53)];
    button.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Intro_start_bg"]];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [button setTitle:@"Start pixbee" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blackColor];
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor clearColor].CGColor;
    button.clipsToBounds = YES;
    
    [button addTarget:self action:@selector(action:) forControlEvents: UIControlEventTouchUpInside];

    
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:Title[0] description:Message[0] image:@"image1.jpg" button:nil];
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:Title[1] description:Message[1] image:@"image2.jpg" button:nil];
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:Title[2] description:Message[2] image:@"image3.jpg" button:nil];
    IntroModel *model4 = [[IntroModel alloc] initWithTitle:Title[3] description:Message[3] image:@"image4.jpg" button:nil];
    IntroModel *model5 = [[IntroModel alloc] initWithTitle:Title[4] description:Message[4] image:@"image5.jpg" button:button];
    
    self.view = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) pages:@[model1, model2, model3, model4, model5]];
}

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)action:(id)sender {
    self.navigationController.navigationBar.hidden = NO;
    if(!IsEmpty(callerID)){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        PBAppDelegate *appdelegate = (PBAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate goLoginView];
    }

}

@end
