//
//  ViSearchClient.m
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ViSearchClient.h"
#import "ViSearchBasicHandler.h"
#import "ViSearchImageUploadHandler.h"

@interface ViSearchClient()<ViSearchNetWorkDelegate>

@end

@implementation ViSearchClient

+ (ViSearchClient *)sharedInstance {
    static ViSearchClient *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ViSearchClient alloc] init];
        sharedInstance.accessKey = @"";
        sharedInstance.secretKey = @"";
    });
    
    return sharedInstance;
}

- (NSString *)host {
    return @"http://visearch.visenze.com";
}

#pragma mark Search API

- (void)searchWithColor:(ColorSearchParams *)params
                success:(void (^)(NSInteger, id, NSError *))success
                failure:(void (^)(NSInteger, id, NSError *))failure
{
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.searchType = @"colorsearch";
    handler.delegate = self;
    
    [handler handleWithParams:params success:success failure:failure];
}

- (void)searchWithImageData:(UploadSearchParams *)params
                success:(void (^)(NSInteger, id, NSError *))success
                failure:(void (^)(NSInteger, id, NSError *))failure
{
    ViSearchHandler *handler = [ViSearchImageUploadHandler new];
    handler.searchType = @"uploadsearch";
    handler.delegate = self;

    [handler handleWithParams:params success:success failure:failure];
}

- (void)searchWithImageUrl:(UploadSearchParams *)params
                   success:(void (^)(NSInteger, id, NSError *))success
                   failure:(void (^)(NSInteger, id, NSError *))failure
{
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.searchType = @"uploadsearch";
    handler.delegate = self;

    [handler handleWithParams:params success:success failure:failure];
}

- (void)searchWithProductId:(SearchParams *)params
                    success:(void (^)(NSInteger, id, NSError *))success
                    failure:(void (^)(NSInteger, id, NSError *))failure
{
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.searchType = @"search";
    handler.delegate = self;

    [handler handleWithParams:params success:success failure:failure];
}

#pragma mark ViNetworkDelegate

- (NSString *)getAccessKey {
    return self.accessKey;
}

- (NSString *)getSecretKey {
    return self.secretKey;
}

- (NSString *)getHost {
    return self.host;
}

@end
