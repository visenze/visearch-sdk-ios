//
//  GeneralServices.h
//  VisenzeDemo
//
//  Created by ViSenze on 24/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
#import "Reachability.h"
#import "ViSearchAPI.h"


@interface GeneralServices : NSObject

+ (GeneralServices*) sharedInstance;
// General service
- (BOOL) hasInternetConnection;

// Alert view
- (void) showAlertViewOnViewController:(UIViewController*)controller
                             withTitle:(NSString*)title
                           withMessage:(NSString*)messge
                            withButton:(NSString*)button
                             withSegue:(NSString*)segue;

- (void) showAlertViewOnViewController:(UIViewController*)controller
                             withTitle:(NSString*)title
                           withMessage:(NSString*)messge
                            withButton:(NSString*)button
                           withDismiss:(BOOL)dismiss;

// show error
- (void) showErrAlertViewOnViewController:(UIViewController*)controller
                               withButton:(NSString*)button
                              withDismiss:(BOOL)dismiss
                         withSearchResult:(ViSearchResult *)data;

// Image process
- (UIImage*) rotateImage:(UIImage*)image withAngle:(CGFloat)rotationAngle;
- (UIImage *) defaultImage;

// Search functions
- (void)uploadSearchWithImage:(UIImage*)image
                 andDetection:(NSString*)detection
                       andBox:(Box*)box
              completionBlock:(void (^)(BOOL succeeded, ViSearchResult *result))completionBlock;

- (void)idSearchWithImageName:(NSString*)imageName
              completionBlock:(void (^)(BOOL succeeded, ViSearchResult *result))completionBlock;

- (void)trackClickWithImgName:(NSString*)imageName
                        reqId:(NSString*) reqId;

@end
