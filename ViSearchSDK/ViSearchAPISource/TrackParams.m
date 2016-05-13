//
//  TrackParams.m
//  ViSearch
//
//  Created by Yaoxuan on 5/12/16.
//  Copyright © 2016 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackParams.h"

@interface TrackParams()

- (NSString *)cuid;
- (TrackParams *)initWithCID:(NSString *)cid ReqId:(NSString *)reqId andAction:(NSString *)action;

@end



@implementation TrackParams

@synthesize imName = _imName;
@synthesize cid = _cid;
@synthesize reqId = _reqId;
@synthesize action = _action;

- (TrackParams *)initWithCID:(NSString *)cid ReqId:(NSString *)reqId andAction:(NSString *)action {
    self = [super init];
    if (self) {
        _cid = cid;
        _reqId = reqId;
        _action = action;
    }
    
    return self;
}

- (TrackParams *)withImName:(NSString *)imName {
    _imName = imName;
    
    return self;
}

+ (TrackParams *)createWithCID:(NSString *)cid ReqId:(NSString *)reqId andAction:(NSString *)action {
    return [[TrackParams new] initWithCID:cid ReqId:reqId andAction:action];
}

- (NSDictionary *)toDict {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setValue:self.action forKey:@"action"];
    [dic setValue:self.imName forKey:@"im_name"];
    [dic setValue:self.reqId forKey:@"reqid"];
    [dic setValue:self.cid forKey:@"cid"];
    
    [dic setValue:[self cuid] forKey:@"cuid"];
    
    return dic;
}

- (NSString *)cuid {
    return [UIDevice.currentDevice.identifierForVendor UUIDString];
}

@end