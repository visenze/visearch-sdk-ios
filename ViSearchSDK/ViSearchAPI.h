//
//  ViSearchAPI.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "SearchOperation.h"
#import "ViSearchClient.h"


@interface ViSearchAPI : NSObject

+ (void)initWithAccessKey:(NSString*) accessKey andSecretKey:(NSString*)secretSecret;

+ (SearchOperation*) search;

+ (void)setupAccessKey:(NSString*) accessKey andSecretKey:(NSString*)secretKey;
+ (ViSearchClient *) defaultClient;

@end