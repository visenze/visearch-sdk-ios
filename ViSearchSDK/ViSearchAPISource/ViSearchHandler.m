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

-(id)init {
    if (self = [super init])  {
        self.timeoutInterval = 10;
    }
    return self;
}

#pragma mark abstract method

- (void)handleWithParams:(BaseSearchParams *)params success:(void (^)(NSInteger, id, NSError *))success failure:(void (^)(NSInteger, id, NSError *))failure {}
- (void)handleWithParams:(BaseSearchParams *)params completion:(void (^)(BOOL))completion {}

#pragma mark Preprocess Network Help Functions
- (ViSearchResult*)generateResultWithResponseData:(NSData*)responseData error:(NSError*)error httpStatusCode:(int)httpStatusCode {
    return [self generateResultWithResponseData:responseData error:error httpStatusCode:httpStatusCode httpHeaders:nil];
}

- (ViSearchResult*)generateResultWithResponseData:(NSData*)responseData error:(NSError*)error
    httpStatusCode:(int)httpStatusCode httpHeaders:(NSDictionary*) headers
{
  
    ViSearchResult *result;
    
    if (!responseData) {
      result = [ViSearchResult resultWithSuccess:false
                                       withError:[ViSearchError errorWithErrorMsg:@"no response data" andHttpStatusCode:httpStatusCode andErrorCode:0]];
      return result;
    }
    
    NSError *jsonError = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:
            [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError]];
    
    if (headers) {
        [dict addEntriesFromDictionary:headers];
    }
    
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
    result = [ViSearchResult resultWithSuccess:true withError:nil andContent:dict];
    
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
    return [self generateRequestUrlPrefixWithParams:params andDomainUrl:nil];
}

- (NSString*)generateRequestUrlPrefixWithParams:(NSDictionary*)params andDomainUrl:(NSString *)domain {
    NSString *baseUrl;
    
    if (!domain) {
        baseUrl = [self.delegate getHost];
    } else {
        baseUrl = domain;
    }
        
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@?", baseUrl, self.searchType];
    
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
