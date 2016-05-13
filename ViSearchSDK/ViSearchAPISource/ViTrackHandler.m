//
//  ViTrackHandler.m
//  ViSearch
//
//  Created by Yaoxuan on 5/12/16.
//  Copyright © 2016 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViTrackHandler.h"

@implementation ViTrackHandler

- (void)handleWithParams:(BaseSearchParams *)params completion:(void (^)(BOOL))completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSString *urlString = [self generateRequestUrlPrefixWithParams: params.toDict andDomainUrl:@"https://track.visenze.com"];
    [request setURL: [NSURL URLWithString:urlString]];
    [request addValue:self.getAuthParams forHTTPHeaderField:@"Authorization"];
    
    NSOperationQueue *queue = [self.delegate getOperationQ];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                               if (!error && statusCode == 200) {//error not nil
                                   completion(YES);
                               } else {
                                   completion(NO);
                               }
                           }];
}

@end