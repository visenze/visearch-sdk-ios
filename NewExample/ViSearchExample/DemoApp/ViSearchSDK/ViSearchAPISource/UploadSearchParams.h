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
#import "ImageSettings.h"

@interface UploadSearchParams : BaseSearchParams

@property (atomic) NSString *imageUrl;
@property (atomic) UIImage *imageFile;
@property (atomic) NSString *imId;
@property (atomic) Box *box;
@property (atomic) UIImage *compressedImage;
@property (atomic) ImageSettings *settings;

// discover search
@property (nonatomic, assign) int detectionLimit;
@property (nonatomic, assign) int resultLimit;
@property (nonatomic, strong) NSString *detectionSensitivity;


@end
