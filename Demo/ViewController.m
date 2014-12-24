//
//  ViewController.m
//  Demo
//
//  Created by Shaohuan on 12/19/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imagePicker = [[UIImagePickerController alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    [ViSearchAPI initWithAccessKey: @"" andSecretKey:@""];
}
- (IBAction)idSearch:(id)sender {
    SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.imName = idSearchTextField.text;
    // searchParams.fl = @[@"price",@"brand",@"im_url"];
    ViSearchResult *visenzeResult = [[ViSearchAPI search] search:searchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        NSString * result = [[imageList valueForKey:@"im_name"] componentsJoinedByString:@" "];
        dispatch_async(dispatch_get_main_queue(), ^{
            returnedText.text = result;
        });
    // for (NSDictionary *obj in imageList){
    //     NSLog(@"im_name: %@", [obj objectForKey:@"im_name"]);
    //     NSLog(@"value_map: %@", [[obj objectForKey:@"value_map"] objectForKey:@"im_url"]);
    // }
    }else{
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                         message: @"Not Found"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}
- (IBAction)colorSearch:(id)sender {
    ColorSearchParams *colorSearchParams = [[ColorSearchParams alloc] init];
    colorSearchParams.color = colorSearchTextField.text;
    ViSearchResult *visenzeResult = [[ViSearchAPI search] colorSearch:colorSearchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        NSString * result = [[imageList valueForKey:@"im_name"] componentsJoinedByString:@" "];
        dispatch_async(dispatch_get_main_queue(), ^{
            returnedText.text = result;
        });
    }else{
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                         message: @"Not Found"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}
- (IBAction)uploadSearchURL:(id)sender {
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.imageUrl = uploadSearchUrlTextField.text;
    ViSearchResult *visenzeResult = [[ViSearchAPI search] uploadSearch:uploadSearchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        NSString * result = [[imageList valueForKey:@"im_name"] componentsJoinedByString:@" "];
        dispatch_async(dispatch_get_main_queue(), ^{
            returnedText.text = result;
        });
    }else{
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                         message: @"Not Found"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}

-(IBAction)pickFromCameraButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to camera"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}

-(IBAction)pickFromLibraryButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to access photo library"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}

// Use ViSearch SDK to find similar images
-(void) detectWithImage: (UIImage*) image {
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.imageFile = UIImageJPEGRepresentation(image, 0.5);
    ViSearchResult *visenzeResult = [[ViSearchAPI search] uploadSearch:uploadSearchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        NSString * result = [[imageList valueForKey:@"im_name"] componentsJoinedByString:@" "];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            returnedText.text = result;
        });
    }else{
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                         message: @"Not Found"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    UIImage *imageToDisplay = [self fixOrientation:sourceImage];
    // perform detection in background thread
    [self performSelectorInBackground:@selector(detectWithImage:) withObject: imageToDisplay];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end