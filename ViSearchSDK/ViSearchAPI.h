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

+(void)initWithApiKey:(NSString*) apiKey andApiSecret:(NSString*)apiSecret;

+(SearchOperation*) search;

@end
