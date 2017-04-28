//
//  ViSearchImageUploadHandler.m
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ViSearchImageUploadHandler.h"

@interface ViSearchImageUploadHandler()

- (NSString *)generateBoundaryString;

@end

@implementation ViSearchImageUploadHandler

- (void)handleWithParams:(BaseSearchParams *)params
                 success:(void (^)(NSInteger, id, NSError *))success
                 failure:(void (^)(NSInteger, id, NSError *))failure
{
    //upload
    NSString *boundary = [self generateBoundaryString];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:self.timeoutInterval];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:[params httpPostBodyWithObject:@{@"boundary":boundary}]];
    
    // old way of authentication
    NSMutableDictionary* paramDict = [[params toDict] mutableCopy];
    
    if(self.delegate!=nil && [self.delegate getAppKey] == nil)
    {
        [request addValue:self.getAuthParams forHTTPHeaderField:@"Authorization"];
    }
    else {
        
        // add in the access key
        paramDict[@"access_key"] = [self.delegate getAppKey];
    }
    
    NSString *urlString = [self generateRequestUrlPrefixWithParams: paramDict];
    
    [request setURL: [NSURL URLWithString:urlString]];

    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    if(self.userAgent != nil )
        [request addValue:self.userAgent forHTTPHeaderField:kVisenzeUserAgentHeader];
    else
        [request addValue:kVisenzeUserAgentValue forHTTPHeaderField:kVisenzeUserAgentHeader];

    // set URL
    [request setURL: [NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [self.delegate getOperationQ];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            NSHTTPURLResponse *res = ((NSHTTPURLResponse *)response);
            NSInteger statusCode = res.statusCode;
            ViSearchResult *result = [self generateResultWithResponseData:data error:error httpStatusCode:(int)statusCode httpHeaders:res.allHeaderFields];
          
            if (!error) {//error not nil
                if(success!=nil)
                    success(statusCode, result, error);
           } else {
                if(failure!=nil)
                    failure(statusCode, result, error);
           }
        }];
}

- (NSString *)generateBoundaryString {
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


@end
