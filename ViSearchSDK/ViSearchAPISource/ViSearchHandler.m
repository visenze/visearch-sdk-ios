//
//  ViSearchHandler.m
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ViSearchHandler.h"
#import "NSString+HMAC_SHA1.h"

static NSInteger const NonceLength = 8;

@interface ViSearchHandler()

- (NSDictionary*)getAuthParams;

@end

@implementation ViSearchHandler

#pragma mark abstract method

- (void)handleWithParams:(BaseSearchParams *)params success:(void (^)(NSInteger, id, NSError *))success failure:(void (^)(NSInteger, id, NSError *))failure {}

#pragma mark Preprocess Network Help Functions
- (ViSearchResult*)generateResultWithResponseData:(NSData*)responseData error:(NSError*)error httpStatusCode:(int)httpStatusCode {
    
    ViSearchResult *result;

    if (!responseData) {
        result = [ViSearchResult resultWithSuccess:false
            withError:[ViSearchError errorWithErrorMsg:@"no response data" andHttpStatusCode:httpStatusCode andErrorCode:0]];
        return result;
    }
    
    NSError *jsonError = nil;
    NSDictionary *dict;
    dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError) {
        if (error) {
            return [ViSearchResult resultWithSuccess:false
                withError:[ViSearchError errorWithErrorMsg:[error description] andHttpStatusCode:httpStatusCode andErrorCode:0]];
        } else {
            return [ViSearchResult resultWithSuccess:false
                withError:[ViSearchError errorWithErrorMsg:[jsonError description] andHttpStatusCode:httpStatusCode andErrorCode:0]];
        }
    }
    
    ViSearchError *viSearchError = [ViSearchError checkErrorFromJSONDictionary:dict andHttpStatusCode:httpStatusCode];
    if (viSearchError) {
        return [ViSearchResult resultWithSuccess:false withError:viSearchError];
    }
    result = [ViSearchResult resultWithSuccess:true withError:nil];
    result.content = dict;
    
    if (error) {
        return [ViSearchResult resultWithSuccess:false
            withError:[ViSearchError errorWithErrorMsg:[error description] andHttpStatusCode:httpStatusCode andErrorCode:0]];
    }
    
    return result;
}

- (NSString*)generateRequestUrlPrefixWithParams:(NSDictionary*)params {
    //assert(method != nil);
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@?access_key=%@", [self.delegate getHost], self.searchType, [self.delegate getAccessKey]];
    NSDictionary* authParams = [self getAuthParams];
    for (NSString* key in authParams.allKeys) {
        [urlString appendFormat:@"&%@=%@", key, [authParams objectForKey:key]];
    }
    if (params != nil) {
        for (NSString* key in params.allKeys) {
            if([[params objectForKey:key] isKindOfClass:[NSArray class]]){
                for (NSString* value in [params objectForKey:key]) {
                    [urlString appendFormat:@"&%@=%@", key, value];
                }
            }
            [urlString appendFormat:@"&%@=%@", key, [params objectForKey:key]];
        }
    }
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary*)getAuthParams {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSString* nonce = [self generateNonce: NonceLength];
    NSString* date = [NSString stringWithFormat:@"%d",(int)round([[NSDate date] timeIntervalSince1970])];
    NSString* sigStr = [NSString stringWithFormat:@"%@%@%@", [self.delegate getSecretKey], nonce, date];
    [dict setObject:nonce forKey:@"nonce"];
    [dict setObject:date forKey:@"date"];
    [dict setObject:[sigStr HmacSha1WithSecret:[self.delegate getSecretKey]] forKey:@"sig"];
    return dict;
}

- (NSString *)generateNonce:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    NSData *data = [randomString dataUsingEncoding:NSUTF8StringEncoding];
    const unsigned char *buffer = (const unsigned char *)[data bytes];
    NSString *nonce = [NSMutableString stringWithCapacity:data.length * 2];
    
    for (int i = 0; i < data.length; ++i)
        nonce = [nonce stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    return nonce;
}

@end
