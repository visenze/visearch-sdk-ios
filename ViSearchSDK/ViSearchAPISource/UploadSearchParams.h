//
//  UploadSearchParams.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//
#import <UIKit/UIKit.h>
#import "BaseSearchParams.h"
#import "Box.h"

@interface UploadSearchParams : BaseSearchParams

@property (atomic) NSString *imageUrl;
@property (atomic) UIImage *imageFile;
@property (atomic) Box *box;
@property (atomic) float maxWidth;
@property (atomic) float quality;
@property (atomic) UIImage *compressedImage;

@end