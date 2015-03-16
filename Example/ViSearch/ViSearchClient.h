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

@class ViSearchClient;

@interface ViSearchClient : NSObject

@property NSString *accessKey;
@property NSString *secretKey;
@property(readonly) NSString *host;

+ (ViSearchClient *)sharedInstance;

- (void)searchWithProductId:(SearchParams *)params
                    success:(void (^)(NSInteger, id, NSError *)) success
                    failure:(void (^)(NSInteger, id, NSError *)) failure;
- (void)searchWithColor:(ColorSearchParams *)params
                    success:(void (^)(NSInteger, id, NSError *)) success
                    failure:(void (^)(NSInteger, id, NSError *)) failure;
- (void)searchWithImageData:(UploadSearchParams *)params
                    success:(void (^)(NSInteger, id, NSError *)) success
                    failure:(void (^)(NSInteger, id, NSError *)) failure;
- (void)searchWithImageUrl:(UploadSearchParams *)params
                   success:(void (^)(NSInteger, id, NSError *))success
                   failure:(void (^)(NSInteger, id, NSError *))failure;
@end
