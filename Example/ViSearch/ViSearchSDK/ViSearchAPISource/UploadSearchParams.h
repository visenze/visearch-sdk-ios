//
//  UploadSearchParams.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "BaseSearchParams.h"
#import "Box.h"

@interface UploadSearchParams : BaseSearchParams

@property (atomic) NSString *imageUrl;
@property (atomic) NSData *imageFile;
@property (atomic) Box *box;

@end