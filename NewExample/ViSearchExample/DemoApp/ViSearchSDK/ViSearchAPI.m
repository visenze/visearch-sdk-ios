//
//  ViSearchAPI.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchAPI.h"


@implementation ViSearchAPI

+ (void)setupAccessKey:(NSString *)accessKey andSecretKey:(NSString *)secretKey {
    [ViSearchClient sharedInstance].accessKey = accessKey;
    [ViSearchClient sharedInstance].secretKey = secretKey;
}

+ (ViSearchClient *)defaultClient {
    return [ViSearchClient sharedInstance];
}

@end