//
//  CameraViewController.m
//  DemoApp
//
//  Created by ViSenze on 7/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "CameraViewController.h"
#import <ImageIO/ImageIO.h>
@import MobileCoreServices;

@interface CameraViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CameraViewController {
    AVCaptureSession *session;
    AVCaptureDevice *device;
    UIImagePickerController *picker;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    AVCaptureDeviceInput *sessionInput;
    
    BOOL isTorchOn;
    BOOL isCameraFront;
    BOOL isFromCamera;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    picker = [[UIImagePickerController alloc] init];
    isTorchOn = NO;
    isCameraFront = NO;
    
    [self setCameraWithPosition:AVCaptureDevicePositionBack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Camera
- (void)setCameraWithPosition:(AVCaptureDevicePosition)position {
    if (session) {
        [session removeInput:sessionInput];
        [session removeOutput:self.stillImageOutput];
    }
    
    if (captureVideoPreviewLayer) {
        [captureVideoPreviewLayer removeFromSuperlayer];
    }
    
    session = [[AVCaptureSession alloc] init];

    session.sessionPreset = AVCaptureSessionPresetPhoto;
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureVideoPreviewLayer.frame = self.view.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:captureVideoPreviewLayer];
    
    device = [self cameraWithPosition:position];
    [device lockForConfiguration:nil];
    NSError *error = nil;
    sessionInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!sessionInput) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    } else {
        [session addInput:sessionInput];
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc]
                                    initWithObjectsAndKeys:
                                    AVVideoCodecJPEG,
                                    AVVideoCodecKey,
                                    nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:self.stillImageOutput];
    
    [session startRunning];
    
    for (UIView *subview in [self.view subviews]) {
        [self.view bringSubviewToFront:subview];
    }
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    
    return nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - IBActions
- (IBAction)cameraClicked:(id)sender {
    
    if (isCameraFront) {
        if ([self cameraWithPosition:AVCaptureDevicePositionBack]) {
            [self setCameraWithPosition:AVCaptureDevicePositionBack];
        }
    } else {
        if ([self cameraWithPosition:AVCaptureDevicePositionFront]) {
            [self setCameraWithPosition:AVCaptureDevicePositionFront];
        }
    }
    
    isCameraFront = !isCameraFront;
}

- (IBAction)lightClicked:(id)sender {
    if ( ![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        /* Device is not iPad */
        if (isTorchOn) {
            device.torchMode = AVCaptureTorchModeOff;
        } else {
            device.torchMode = AVCaptureTorchModeOn;
        }
        
        isTorchOn = !isTorchOn;
    }
}

- (IBAction)albumButtonClicked:(id)sender {
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)shootClicked:(id)sender {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *originalImage = [[UIImage alloc] initWithData:imageData];
        
        if (originalImage) {
            UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
            
            if (isCameraFront) {
                self.capturedImage = [UIImage imageWithCGImage:originalImage.CGImage
                                                         scale:originalImage.scale
                                                   orientation:UIImageOrientationLeftMirrored];
            } else {
                self.capturedImage = originalImage;
            }
            
            isFromCamera = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:SEGUE_PREVIEW sender:self];
            });
        }
    }];
}

#pragma mark image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        self.capturedImage = originalImage;
        isFromCamera = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:SEGUE_PREVIEW sender:self];
        });
    }
}

#pragma mark - Navigation
- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:SEGUE_HOME sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:SEGUE_PREVIEW]) {
        PreviewViewController *vc = [segue destinationViewController];
        vc.uploadImage = self.capturedImage;
        vc.isFromCamera = isFromCamera;
    }
}

@end
