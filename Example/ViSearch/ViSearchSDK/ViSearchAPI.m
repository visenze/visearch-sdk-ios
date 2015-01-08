//
//  ViSearchAPI.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchAPI.h"
#import "ViSearchClient.h"

static SearchOperation* searchSharedInstance = nil;

@implementation ViSearchAPI

+(void)initWithAccessKey:(NSString*) accessKey andSecretKey:(NSString*)secretKey{
    [ViSearchClient initWithAccessKey: accessKey andSecretKey: secretKey];
}

+(SearchOperation*) search{
    if(searchSharedInstance == nil)
        searchSharedInstance = [[SearchOperation alloc]init];
    return searchSharedInstance;
}

@end