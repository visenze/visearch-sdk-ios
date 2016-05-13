//
//  ViSearchHandler.h
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViSearchResult.h"
#import "BaseSearchParams.h"

@protocol ViSearchNetWorkDelegate<NSObject>

- (NSString *)getAccessKey;
- (NSString *)getSecretKey;
- (NSString *)getHost;
- (NSOperationQueue *)getOperationQ;

@end

@interface ViSearchHandler : NSObject

@property NSString *searchType;
@property id<ViSearchNetWorkDelegate> delegate;
/**
 Executing a searching operation
 
 @param params Params required by the searching operation
 @param success Block handling the successful response
 @param failure Block handling the failing response
 
 @warning Abstract method to be extended by subclass
 */
- (void)handleWithParams:(BaseSearchParams *)params
                 success:(void (^)(NSInteger, id, NSError *)) success
                 failure:(void (^)(NSInteger, id, NSError *)) failure;
- (ViSearchResult*)generateResultWithResponseData:(NSData*)responseData error:(NSError*)error httpStatusCode:(int)httpStatusCode;
- (NSString*)generateRequestUrlPrefixWithParams:(NSDictionary*)params;
- (NSString *)getAuthParams;
@end
