//
//  ViSearchClient.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchClient.h"
#import "NSString+HMAC_SHA1.h"

#define NONCE_LENGTH 8

static bool initilized = false;
static NSString *NOT_INIT_ERROR_MSG = @"ViSearch client has not been initialized yet, please use [ViSearchAPI initWithApiKey: andApiSecret] first";
static NSString *ViSearch_ACCESS_KEY = @"";
static NSString *ViSearch_SECRET_KEY = @"";
static NSString *SERVER_ADDRESS = @"http://visearch.visenze.com";

@implementation ViSearchClient

+(void) initWithAccessKey:(NSString *)accessKey andSecretKey:(NSString *)secretKey{
    
    ViSearch_ACCESS_KEY = [NSString stringWithFormat: @"%@", accessKey];
    ViSearch_SECRET_KEY = [NSString stringWithFormat: @"%@", secretKey];
    initilized = true;
}

+(NSString *)generateBoundaryString {
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    NSString *result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

+(NSString*) generateRequestUrlPrefix: (NSString*) method params: (NSDictionary*) params {
    assert(method != nil);
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@?access_key=%@", SERVER_ADDRESS, method, ViSearch_ACCESS_KEY];
    NSDictionary* authParams = [self getAuthParams];
    for (NSString* key in authParams.allKeys) {
        [urlString appendFormat:@"&%@=%@", key, [authParams objectForKey:key]];
    }
    if (params != nil) {
        for (NSString* key in params.allKeys) {
            [urlString appendFormat:@"&%@=%@", key, [params objectForKey:key]];
        }
    }
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(ViSearchResult*) requestWithMethod: (NSString*) method params: (NSDictionary*) params {
    if (!initilized)
        return [ViSearchResult resultWithSuccess:false withError:[ViSearchError errorWithErrorMsg:NOT_INIT_ERROR_MSG andHttpStatusCode:0 andErrorCode:0]];
    
    NSError *error = nil;
    NSInteger statusCode = 0;
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    
    NSString *urlString = [ViSearchClient generateRequestUrlPrefix: method params: params];
    [request setURL: [NSURL URLWithString:urlString]];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    statusCode = urlResponse.statusCode;
    
    return [ViSearchClient generateResultWithResponseData:responseData error:error httpStatusCode:(int)statusCode];
}

+(ViSearchResult*) requestWithMethod: (NSString*)method image: (NSData*) imageData params: (NSDictionary*)params {
    if (!initilized)
        return [ViSearchResult resultWithSuccess:false withError:[ViSearchError errorWithErrorMsg:NOT_INIT_ERROR_MSG andHttpStatusCode:0 andErrorCode:0]];
    
    NSError *error = NULL;
    NSInteger statusCode = 0;
    
    NSString *boundary = [self generateBoundaryString];
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [[NSMutableData alloc] init];
    
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSString *urlString = [ViSearchClient generateRequestUrlPrefix:method params: params];
    
    // set URL
    [request setURL: [NSURL URLWithString:urlString]];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    statusCode = urlResponse.statusCode;
    
    return [ViSearchClient generateResultWithResponseData:responseData error:error httpStatusCode:(int)statusCode];
}

+(ViSearchResult*) generateResultWithResponseData:(NSData*) responseData error:(NSError*) error httpStatusCode:(int)httpStatusCode {
    
    ViSearchResult *result;
    
    if (responseData == nil) {
        result = [ViSearchResult resultWithSuccess:false withError:[ViSearchError errorWithErrorMsg:@"no response data" andHttpStatusCode:httpStatusCode andErrorCode:0]];
        return result;
    }
    
    NSError *jsonError = nil;
    
    NSDictionary *dict;
    dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError != NULL) {
        if (error != NULL) {
            return [ViSearchResult resultWithSuccess:false withError:[ViSearchError errorWithErrorMsg:[error description] andHttpStatusCode:httpStatusCode andErrorCode:0]];
        } else {
            return [ViSearchResult resultWithSuccess:false withError:[ViSearchError errorWithErrorMsg:[jsonError description] andHttpStatusCode:httpStatusCode andErrorCode:0]];
        }
    }
    ViSearchError *viSearchError = [ViSearchError checkErrorFromJSONDictionary:dict andHttpStatusCode:httpStatusCode];
    if (viSearchError != NULL)
        return [ViSearchResult resultWithSuccess:false withError:viSearchError];
    result = [ViSearchResult resultWithSuccess:true withError:nil];
    result.content = dict;
    
    if (error != NULL)
        return [ViSearchResult resultWithSuccess:false withError:[ViSearchError errorWithErrorMsg:[error description] andHttpStatusCode:httpStatusCode andErrorCode:0]];
    
    return result;
}

+ (NSDictionary*) getAuthParams{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSString* nonce = [self generateNonce: NONCE_LENGTH];
    NSString* date = [NSString stringWithFormat:@"%d",(int)round([[NSDate date] timeIntervalSince1970])];
    NSString* sigStr = [NSString stringWithFormat:@"%@%@%@", ViSearch_SECRET_KEY, nonce, date];
    [dict setObject:nonce forKey:@"nonce"];
    [dict setObject:date forKey:@"date"];
    [dict setObject:[sigStr HmacSha1WithSecret:ViSearch_SECRET_KEY] forKey:@"sig"];
    return dict;
}

+ (NSString *)generateNonce:(int)len {
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