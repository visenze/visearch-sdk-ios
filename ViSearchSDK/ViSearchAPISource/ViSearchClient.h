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
@property(readonly) NSString *host;

+ (ViSearchClient *)sharedInstance;

- (ViSearchClient *)initWithBaseUrl:(NSString *)baseUrl accessKey:(NSString *)accessKey secretKey:(NSString *) secretKey;

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

- (void)track:(TrackParams *) trackParams
     completion:(void (^)(BOOL success))completion;

@end
