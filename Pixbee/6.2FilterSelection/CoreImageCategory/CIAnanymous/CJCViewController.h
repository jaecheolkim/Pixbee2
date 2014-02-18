//
//  CJCViewController.h
//  CJC.FaceMaskingDemo
//
//  Created by Chris Cavanagh on 11/9/13.
//  Copyright (c) 2013 Chris Cavanagh. All rights reserved.
//  From : http://chriscavanagh.wordpress.com/2013/11/12/live-video-face-masking-on-ios/

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CJCViewController : GLKViewController <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic) BOOL isUsingFrontFacingCamera;

@end