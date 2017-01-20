//
//  ViSearchBasicHandler.m
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ViSearchBasicHandler.h"

@implementation ViSearchBasicHandler

- (void)handleWithParams:(BaseSearchParams *)params
                 success:(void (^)(NSInteger, id, NSError *))success
                 failure:(void (^)(NSInteger, id, NSError *))failure
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:self.timeoutInterval];
    
    if(self.userAgent != nil )
        [request addValue:self.userAgent forHTTPHeaderField:kVisenzeUserAgentHeader];
    else
        [request addValue:kVisenzeUserAgentValue forHTTPHeaderField:kVisenzeUserAgentHeader];
    
    
    
    NSMutableDictionary* paramDict = [[params toDict] mutableCopy];
    
    // old way of authentication
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
    
    
    NSOperationQueue *queue = [self.delegate getOperationQ];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            
            ViSearchResult *result = [self generateResultWithResponseData:data error:error httpStatusCode:(int)statusCode httpHeaders: ((NSHTTPURLResponse *)response).allHeaderFields];
            if (!error) {//error not nil
                if(success!=nil)
                    success(statusCode, result, error);
            } else {
                if(failure!=nil)
                    failure(statusCode, result, error);
            }
    }];
}

@end
