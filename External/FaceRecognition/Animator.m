//
//  Animator.m
//  NavigationTransitionTest
//
//  Created by Chris Eidhof on 9/27/13.
//  Copyright (c) 2013 Chris Eidhof. All rights reserved.
//

#import "Animator.h"

@implementation Animator

- (id)init {
    self = [super init];
    if (self) {
        _operation = UINavigationControllerOperationPush;
    }
    return self;
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
//    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    [[transitionContext containerView] addSubview:toViewController.view];
//    toViewController.view.alpha = 0;
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
//        toViewController.view.alpha = 1;
//    } completion:^(BOOL finished) {
//        fromViewController.view.transform = CGAffineTransformIdentity;
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        
//    }];
    
    UIViewController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect screenFrame = fromViewController.view.frame;
    UIView * containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    CGFloat toStartX, fromEndX;
    
    if (_operation == UINavigationControllerOperationPush)
    {
        toStartX = screenFrame.size.width;
        fromEndX = -screenFrame.size.width;
    } else
    {
        toStartX = -screenFrame.size.width;
        fromEndX = screenFrame.size.width;
    }
    
    toViewController.view.frame = CGRectOffset(screenFrame, toStartX, 0);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^
     {
         toViewController.view.frame = screenFrame;
         fromViewController.view.frame = CGRectOffset(screenFrame, fromEndX, 0);
     } completion:^(BOOL finished) {
         //[fromViewController.view removeFromSuperview];
         //[transitionContext completeTransition:YES];
         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
     }];
   
}

@end
