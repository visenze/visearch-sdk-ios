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

@implementation ViSenzeAPI

+(void)initWithApiKey:(NSString*) apiKey andApiSecret:(NSString*)apiSecret{
    [ViSearchClient initWithApiKey: apiKey andApiSecret: apiSecret];
}

+(SearchOperation*) search{
    if(searchSharedInstance == nil)
        searchSharedInstance = [[SearchOperation alloc]init];
    return searchSharedInstance;
}

@end