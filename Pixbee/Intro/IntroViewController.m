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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 487, 260, 53)];
    [button addTarget:self action:@selector(action:) forControlEvents: UIControlEventTouchUpInside];

    
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:nil description:nil image:@"image1.jpg" button:button];
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:nil description:nil image:@"image2.jpg" button:button];
    IntroModel *model3 = [[IntroModel alloc] initWithTitle:nil description:nil image:@"image3.jpg" button:button];
    IntroModel *model4 = [[IntroModel alloc] initWithTitle:nil description:nil image:@"image4.jpg" button:button];
    IntroModel *model5 = [[IntroModel alloc] initWithTitle:nil description:nil image:@"image5.jpg" button:button];
    
    self.view = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) pages:@[model1, model2, model3, model4, model5]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)action:(id)sender {
    if(!IsEmpty(callerID)){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        PBAppDelegate *appdelegate = (PBAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate goMainView];
    }

}

@end
