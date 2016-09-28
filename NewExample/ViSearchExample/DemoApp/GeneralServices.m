//
//  GeneralServices.m
//  VisenzeDemo
//
//  Created by ViSenze on 24/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralServices.h"

@implementation GeneralServices {
    NSArray *orientations;
    dispatch_queue_t imgLoadQ;
}

+ (GeneralServices*)sharedInstance
{
    static GeneralServices *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GeneralServices alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (GeneralServices*) init {
    self = [super init];
    
    if (self) {
        orientations = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInt:0],
                        [NSNumber numberWithUnsignedInt:3],
                        [NSNumber numberWithUnsignedInt:1],
                        [NSNumber numberWithUnsignedInt:2],
                        nil];
        
        imgLoadQ = dispatch_queue_create("img_load", DISPATCH_QUEUE_CONCURRENT);

    }
    return self;
}

- (BOOL) hasInternetConnection {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

- (void) showAlertViewOnViewController:(id)controller
                             withTitle:(NSString *)title
                           withMessage:(NSString *)messge
                            withButton:(NSString *)button
                             withSegue:(NSString *)segue {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:messge
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:button
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 if (segue) {
                                     [controller performSegueWithIdentifier:segue sender:self];
                                 }
                             }];
    
    [alert addAction:action];
    [controller presentViewController:alert animated:YES completion:nil];
}

- (void) showAlertViewOnViewController:(UIViewController*)controller
                             withTitle:(NSString*)title
                           withMessage:(NSString*)messge
                            withButton:(NSString*)button
                           withDismiss:(BOOL)dismiss {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:messge
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:button
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 if (dismiss) {
                                     [controller dismissViewControllerAnimated:YES completion:nil];
                                 }
                             }];
    
    [alert addAction:action];
    [controller presentViewController:alert animated:YES completion:nil];
}

- (void) showErrAlertViewOnViewController:(UIViewController*)controller
                            withButton:(NSString*)button
                            withDismiss:(BOOL)dismiss
                            withSearchResult:(ViSearchResult *)data
                            {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:(data.error == nil ? @"An error has occured" : [NSString stringWithFormat:@"An error has occured: \n%@", data.error.message ])
                                  preferredStyle:UIAlertControllerStyleAlert];
                                
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:button
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 if (dismiss) {
                                     [controller dismissViewControllerAnimated:YES completion:nil];
                                 }
                             }];
    
    [alert addAction:action];
    [controller presentViewController:alert animated:YES completion:nil];
}

- (UIImage*) rotateImage:(UIImage *)image withAngle :(CGFloat)rotationAngle {
    int index = ([orientations indexOfObject:[NSNumber numberWithUnsignedInt:image.imageOrientation]] + 1) % 4;
    UIImageOrientation orient = [[orientations objectAtIndex:index] integerValue];
    
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:image.scale
                          orientation:UIImageOrientationUp];
    
    if (rotationAngle == 0) {
        image = [UIImage imageWithCGImage:image.CGImage
                                    scale:image.scale
                              orientation:orient];
    } else if (rotationAngle == 90) {
        image = [UIImage imageWithCGImage:image.CGImage
                                    scale:image.scale
                              orientation:orient];
    } else if (rotationAngle == 180) {
        image = [UIImage imageWithCGImage:image.CGImage
                                    scale:image.scale
                              orientation:orient];
    } else if (rotationAngle == 270) {
        image = [UIImage imageWithCGImage:image.CGImage
                                    scale:image.scale
                              orientation:orient];
    }
    
    return image;
}

- (UIImage *) defaultImage {
    CGRect rect = CGRectMake(0, 0, 512, 512);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)uploadSearchWithImage:(UIImage*)image
                 andDetection:(NSString*)detection
                       andBox:(Box*)box
                completionBlock:(void (^)(BOOL succeeded, ViSearchResult *result))completionBlock {
        
    UploadSearchParams *uploadParams = [[UploadSearchParams alloc] init];
    uploadParams.fl = @[@"im_url", @"brand", @"im_title", @"price", @"product_url"];
    uploadParams.limit = IMG_QUERY_LIMIT;
    uploadParams.imageFile = image;
    uploadParams.detection = detection;
    uploadParams.score = YES;
    uploadParams.settings = [ImageSettings highqualitySettings];
    
    if (box) {
        uploadParams.box = box;
    }
    
    [[ViSearchClient sharedInstance] searchWithImageData:uploadParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        
        NSString *status = [data.content objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, data);
        }
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        completionBlock(NO, data);
    }];
}

- (void)idSearchWithImageName:(NSString*)imageName
              completionBlock:(void (^)(BOOL succeeded, ViSearchResult *result))completionBlock {
    
    SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.imName = imageName;
    searchParams.fl = @[@"price",@"brand",@"im_url"];
    searchParams.limit = IMG_QUERY_LIMIT;
    searchParams.score = YES;
    
    [[ViSearchAPI defaultClient] searchWithImageId:searchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        
        NSString *status = [data.content objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, data);
        }
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        completionBlock(NO, data);
    }];
}

- (void)trackClickWithImgName:(NSString*)imageName
             reqId:(NSString*) reqId
{
    TrackParams* params = [TrackParams createWithAccessKey:[ViSearchAPI defaultClient].accessKey reqId:reqId andAction:@"click"];
    [[ViSearchAPI defaultClient] track:params completion:nil];
}

@end
