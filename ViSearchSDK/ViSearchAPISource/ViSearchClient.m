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
#import "ViTrackHandler.h"

@interface ViSearchClient()<ViSearchNetWorkDelegate>

@property (nonatomic) NSString *host;
@property NSOperationQueue *operationQ;

@end

@implementation ViSearchClient
@synthesize host = _host;

#pragma mark LifeCycle

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

- (ViSearchClient *)initWithBaseUrl:(NSString *)baseUrl accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    if (self = [super init]) {
        self.host = baseUrl;
        self.accessKey = accessKey;
        self.secretKey = secretKey;
        self.operationQ = [NSOperationQueue new];
    }
    
    return self;
}

#pragma mark Customized Accessors

- (NSString *)host{
    if (_host) {
        return _host;
    }else {
        return @"https://visearch.visenze.com";
    }
}

- (void)setHost:(NSString *)host {
    _host = host;
}

#pragma mark Search API

- (void)searchWithColor:(ColorSearchParams *)params
                success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.searchType = @"colorsearch";
    handler.delegate = self;
    
    [handler handleWithParams:params success:success failure:failure];
}

- (void)searchWithImageData:(UploadSearchParams *)params
                    success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                    failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;
{
    ViSearchHandler *handler = [ViSearchImageUploadHandler new];
    handler.searchType = @"uploadsearch";
    handler.delegate = self;

    [handler handleWithParams:params success:success failure:failure];
}

- (void)searchWithImageUrl:(UploadSearchParams *)params
                   success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))success
                   failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))failure
{
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.searchType = @"uploadsearch";
    handler.delegate = self;

    [handler handleWithParams:params success:success failure:failure];
}

- (void)searchWithImageId:(SearchParams *)params
                  success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                  failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.searchType = @"search";
    handler.delegate = self;

    [handler handleWithParams:params success:success failure:failure];
}

#pragma makr Track
- (void)track:(TrackParams *)trackParams completion:(void (^)(BOOL))completion {
    ViSearchHandler *handler = [ViTrackHandler new];
    handler.searchType = @"__aq.gif";
    handler.delegate = self;
    
    [handler handleWithParams:trackParams completion:completion];
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

- (NSOperationQueue *)getOperationQ {
    if (!self.operationQ) {
        self.operationQ = [NSOperationQueue new];
    }
    return self.operationQ;
}
@end
