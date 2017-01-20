//
//  ViSearchAPI.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "ViSearchClient.h"


@interface ViSearchAPI : NSObject

+ (void)setupAccessKey:(NSString*) accessKey andSecretKey:(NSString*)secretKey;
+ (void)setupAppKey:(NSString *)appKey;
+ (ViSearchClient *) defaultClient;

@end
