//
//  ViSearchHandler.m
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ViSearchHandler.h"
#import "NSString+HMAC_SHA1.h"

@interface ViSearchHandler()

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

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
    return result;
}

- (NSString*)generateRequestUrlPrefixWithParams:(NSDictionary*)params {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@?", [self.delegate getHost], self.searchType];
    
    if (params != nil) {
        for (NSString* key in params.allKeys) {
            NSString* encodeKey = [self urlEncodeValue:key];
            if([[params objectForKey:key] isKindOfClass:[NSArray class]]){
                for (NSString* value in [params objectForKey:key]) {
                    NSString* encodeValue = [self urlEncodeValue:value];
                    [urlString appendFormat:@"&%@=%@", encodeKey, encodeValue];
                }
            } else {
                NSString* encodeParam =[self urlEncodeValue:[params objectForKey:key]];
                [urlString appendFormat:@"&%@=%@", encodeKey, encodeParam];
            }
        }
    }
    return urlString;
}

- (NSString *)getAuthParams {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [self.delegate getAccessKey], [self.delegate getSecretKey]];
    
    NSData *encodeData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeString = [encodeData base64EncodedStringWithOptions:0];
    NSString *authEncodeString = [@"Basic " stringByAppendingString:encodeString];
    
    return authEncodeString;
}

@end
