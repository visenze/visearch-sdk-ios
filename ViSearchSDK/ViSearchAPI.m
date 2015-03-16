//
//  ViSearchAPI.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchAPI.h"
#import "ViSearchClient2.h"

static SearchOperation* searchSharedInstance = nil;

@implementation ViSearchAPI

+ (void)initWithAccessKey:(NSString*) accessKey andSecretKey:(NSString*)secretKey{
    [ViSearchClient2 initWithAccessKey: accessKey andSecretKey: secretKey];
}

+ (SearchOperation*) search{
    if(searchSharedInstance == nil)
        searchSharedInstance = [[SearchOperation alloc]init];
    return searchSharedInstance;
}

+ (void)setupAccessKey:(NSString *)accessKey andSecretKey:(NSString *)secretKey {
    [ViSearchClient sharedInstance].accessKey = accessKey;
    [ViSearchClient sharedInstance].secretKey = secretKey;
}

+ (ViSearchClient *)defaultClient {
    return [ViSearchClient sharedInstance];
}

@end