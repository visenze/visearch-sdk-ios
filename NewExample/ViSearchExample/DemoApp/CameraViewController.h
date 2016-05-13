//
//  CameraViewController.h
//  DemoApp
//
//  Created by ViSenze on 7/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PreviewViewController.h"

@interface CameraViewController : UIViewController

@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) UIImage *capturedImage;

- (IBAction)albumButtonClicked:(id)sender;
- (IBAction)shootClicked:(id)sender;
- (IBAction)backClicked:(id)sender;

@end
