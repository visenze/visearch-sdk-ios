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
    
    NSString *urlString = [self generateRequestUrlPrefixWithParams: params.toDict];
    [request setURL: [NSURL URLWithString:urlString]];
    [request addValue:self.getAuthParams forHTTPHeaderField:@"Authorization"];

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
