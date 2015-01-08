//
//  ViSearchClient.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>

#import "ViSearchResult.h"
#import "ViSearchAPI.h"
#import "ViSearchError.h"

@interface ViSearchClient : NSObject

+(void) initWithAccessKey: (NSString*)accessKey andSecretKey:(NSString*) secretKey;

+(ViSearchResult*) requestWithMethod: (NSString*)method params: (NSDictionary*)params;
+(ViSearchResult*) requestWithMethod: (NSString*)method image: (NSData*)imageData params: (NSDictionary*)params;

@end