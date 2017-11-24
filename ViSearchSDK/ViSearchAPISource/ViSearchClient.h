//
//  ViSearchClient.h
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchParams.h"
#import "ColorSearchParams.h"
#import "UploadSearchParams.h"
#import "ViSearchResult.h"
#import "TrackParams.h"

@class ViSearchClient;

@interface ViSearchClient : NSObject

@property NSString *accessKey;
@property NSString *secretKey;
@property BOOL isAppKeyEnabled;
@property(readonly) NSString *host;
@property (nonatomic, assign) int timeoutInterval; // add time out interval for search client, default to 10s

@property NSString *userAgent;

+ (ViSearchClient *)sharedInstance;

- (ViSearchClient *)initWithBaseUrl:(NSString *)baseUrl accessKey:(NSString *)accessKey secretKey:(NSString *) secretKey;
- (ViSearchClient *)initWithBaseUrl:(NSString *)baseUrl appKey:(NSString *)appKey ;


- (void)searchWithImageId:(SearchParams *)params
                  success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                  failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;
- (void)searchWithColor:(ColorSearchParams *)params
                success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;

- (void)searchWithImageData:(UploadSearchParams *)params
                    success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                    failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;
- (void)searchWithImageUrl:(UploadSearchParams *)params
                   success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))success
                   failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))failure;

- (void)searchWithImage:(UploadSearchParams *)params
                    success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                    failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;

- (void)recommendWithImageName:(SearchParams *)params
                       success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                       failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;

- (void)track:(TrackParams *) trackParams
     completion:(void (^)(BOOL success))completion;

// discover search
- (void)discoverSearchWithImageData:(UploadSearchParams *)params
                    success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                    failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;

- (void)discoverSearchWithImageUrl:(UploadSearchParams *)params
                   success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))success
                   failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))failure;

- (void)discoverSearchWithImage:(UploadSearchParams *)params
                success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;

@end
