//
//  ViSearchClient.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchClient.h"

static bool initilized = false;
static NSString *NOT_INIT_ERROR_MSG = @"ViSearch client has not been initialized yet, please use [ViSearchAPI initWithApiKey: andApiSecret] first";
static NSString *ViSearch_API_KEY = @"";
static NSString *ViSearch_API_SECRET = @"";

static NSString *SERVER_ADDRESS = @"http://visearch.ViSearch.com";
@implementation ViSearchClient

+(void) initWithApiKey:(NSString *)apiKey andApiSecret:(NSString *)apiSecret{
    
    ViSearch_API_KEY = [NSString stringWithFormat: @"%@", apiKey];
    ViSearch_API_SECRET = [NSString stringWithFormat: @"%@", apiSecret];
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

+(NSString*) generateRequestUrlPrefix: (NSString*) method params: (NSArray*) params {
    assert(method != NULL);
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?api_key=%@&api_secret=%@", SERVER_ADDRESS, method, ViSearch_API_KEY, ViSearch_API_SECRET];
    if (params != NULL) {
        assert((params.count%2)==0);
        for (size_t i=0; i<params.count; i+=2) {
            [urlString appendFormat:@"&%@=%@", [params objectAtIndex:i], [params objectAtIndex:i+1]];
        }
    }
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(ViSearchResult*) requestWithMethod: (NSString*) method params: (NSArray*) params {
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
    
    return [ViSearchClient generateResultWithResponseData:responseData error:error httpStatusCode:statusCode];
}

+(ViSearchResult*) requestWithMethod: (NSString*)method image: (NSData*) imageData params: (NSArray*)params {
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
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"img\"; filename=\"image.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
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
    
    return [ViSearchClient generateResultWithResponseData:responseData error:error httpStatusCode:statusCode];
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

@end