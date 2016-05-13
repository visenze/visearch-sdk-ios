//
//  ViSearchViewController.m
//  ViSearch
//
//  Created by Shaohuan Li on 01/08/2015.
//  Copyright (c) 2014 Shaohuan Li. All rights reserved.
//

#import "ViSearchViewController.h"

@interface ViSearchViewController ()

@end

@implementation ViSearchViewController {
    NSMutableDictionary *imageCache;
    dispatch_queue_t concurrerntQ;
    UIActivityIndicatorView *spinner;
}

static NSString* ACCESS_KEY=  @"";
static NSString* SECRET_KEY=  @"";
static int IMAGE_CELL_TAG = 1234;
static int LABEL_CELL_TAG = 2345;

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imagePicker = [[UIImagePickerController alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    [ViSearchAPI setupAccessKey:@"" andSecretKey:@""];
    
    imageCollectionView.delegate = self;
    imageCollectionView.dataSource = self;
    imageList = [NSMutableArray array];
    imageCache = [NSMutableDictionary dictionary];
    
    concurrerntQ = dispatch_queue_create("concurrentQ", DISPATCH_QUEUE_CONCURRENT);
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, 24, 24);
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
  
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Search Example

// Image Id Search Example
- (IBAction)idSearch:(id)sender {
    [spinner startAnimating];
    
    SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.imName = idSearchTextField.text;
    searchParams.fl = @[@"price",@"brand",@"im_url"];
    
    [[ViSearchAPI defaultClient] searchWithImageId:searchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        imageList = data.imageResultsArray;
        [imageCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                                 message: @"Not Found"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles: nil];
                [alert addButtonWithTitle:@"OK"];
                [alert show];
        [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];

    }];
}

// Color Search Example
- (IBAction)colorSearch:(id)sender {
    [spinner startAnimating];
    
    ColorSearchParams *colorSearchParams = [[ColorSearchParams alloc] init];
    colorSearchParams.color = colorSearchTextField.text;
    colorSearchParams.fl = @[@"price",@"brand",@"im_url"];
    
    [[ViSearchAPI defaultClient]
        searchWithColor:colorSearchParams
        success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
            imageList = data.imageResultsArray;
            [imageCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                             message: @"Not Found"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles: nil];
            [alert addButtonWithTitle:@"OK"];
            [alert show];
            [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];

        }];
}

// Image url Search Example
- (IBAction)uploadSearchURL:(id)sender {
    [spinner startAnimating];
    
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.imageUrl = uploadSearchUrlTextField.text;
    uploadSearchParams.fl = @[@"price",@"brand",@"im_url"];
    
    [[ViSearchAPI defaultClient]
        searchWithImageUrl:uploadSearchParams
        success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
            imageList = data.imageResultsArray;
            [imageCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                             message: @"Not Found"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles: nil];
            [alert addButtonWithTitle:@"OK"];
            [alert show];
            [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        }];
}

// Image search Example
-(void) detectWithImage: (UIImage*) image {
    [spinner startAnimating];
    
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.fl = @[@"price",@"brand",@"im_url"];
    uploadSearchParams.imageFile = image;
    uploadSearchParams.settings = [ImageSettings highqualitySettings];
    
    [[ViSearchAPI defaultClient]
     searchWithImageData:uploadSearchParams
     success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
         imageList = data.imageResultsArray;
         [imageCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
         [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
     } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
         UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Result"
                                                          message: @"Not Found"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles: nil];
         [alert addButtonWithTitle:@"OK"];
         [alert show];
         [spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
     }];
}

#pragma mark Others

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

#pragma mark collectionview delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imageList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    ImageResult *r = [imageList objectAtIndex:indexPath.row];
    
    UIImageView *resultImageView = (UIImageView *)[cell viewWithTag:IMAGE_CELL_TAG];
    
    UIImage *img = [imageCache objectForKey:r.url];
    if (img) { // image is cached
        resultImageView.image = img;
    }else {
        NSURL *imageURL = [NSURL URLWithString:r.url];
        resultImageView.image = nil;
        
        dispatch_async(concurrerntQ, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *im = [UIImage imageWithData:imageData];
                resultImageView.image = im;
                [imageCache setObject:im forKey:r.url];
            });
        });
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL_CELL_TAG];
    label.text = r.im_name;
    
    return cell;
}

@end
