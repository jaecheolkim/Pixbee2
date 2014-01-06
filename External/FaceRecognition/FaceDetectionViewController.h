//
//  FaceDetectionViewController.h
//  Pixbee
//
//  Created by jaecheol kim on 12/1/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    FaceModeRecognize,
    FaceModeCollect,
} FaceMode;


@interface FaceDetectionViewController : UIViewController
@property (nonatomic, strong) NSString *UserName;
@property (nonatomic) int UserID;
@property (nonatomic) FaceMode faceMode;
@property (nonatomic, strong) NSString *segueid;
@end

