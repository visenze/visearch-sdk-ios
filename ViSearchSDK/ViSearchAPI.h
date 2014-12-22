//
//  ViSearchAPI.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "SearchParams.h"
#import "ColorSearchParams.h"
#import "UploadSearchParams.h"
#import "SearchOperation.h"

@interface ViSenzeAPI : NSObject

+(void)initWithAccessKey:(NSString*) accessKey andSecretKey:(NSString*)secretSecret;

+(SearchOperation*) search;

@end