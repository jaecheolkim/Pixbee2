//
//  NavigationControllerDelegate.m
//  NavigationTransitionController
//
//  Created by Chris Eidhof on 09.10.13.
//  Copyright (c) 2013 Chris Eidhof. All rights reserved.
//

#import "NavigationControllerDelegate.h"
#import "Animator.h"

@interface NavigationControllerDelegate ()

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) Animator* animator;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition* interactionController;

@end

@implementation NavigationControllerDelegate

- (void)awakeFromNib
{
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.navigationController.view addGestureRecognizer:panRecognizer];
    
    self.animator = [Animator new];
}

- (void)pan:(UIPanGestureRecognizer*)recognizer
{
    UIView* view = self.navigationController.view;
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint location = [recognizer locationInView:view];
        if (location.x <  CGRectGetMidX(view.bounds) && self.navigationController.viewControllers.count > 1) { // left half
            self.interactionController = [UIPercentDrivenInteractiveTransition new];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        else if(location.x >  CGRectGetMidX(view.bounds) && self.navigationController.viewControllers.count == 1) { //right half
            self.interactionController = [UIPercentDrivenInteractiveTransition new];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CameraGallery"];
            [self.navigationController pushViewController:vc animated:YES ];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:view];
        CGFloat d = fabs(translation.x / CGRectGetWidth(view.bounds));
        [self.interactionController updateInteractiveTransition:d];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"animator.operation = %d / x = %d", (int)(self.animator.operation), (int)[recognizer velocityInView:view].x);
        if(self.animator.operation == UINavigationControllerOperationPush){
            if ([recognizer velocityInView:view].x <= 0) {
                [self.interactionController finishInteractiveTransition];
            } else {
                [self.interactionController cancelInteractiveTransition];
            }
        } else if(self.animator.operation == UINavigationControllerOperationPop){
            if ([recognizer velocityInView:view].x > 0) {
                [self.interactionController finishInteractiveTransition];
            } else {
                [self.interactionController cancelInteractiveTransition];
            }
        }

        self.interactionController = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    self.animator.operation = operation;
    
    if (operation == UINavigationControllerOperationPop) {
         
        return self.animator;
        
    } else if(operation == UINavigationControllerOperationPush) {
        
        return self.animator;
        
    } else {
        return nil;
    }
    
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactionController;
}




@end
