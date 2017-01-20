//
//  TrackParams.m
//  ViSearch
//
//  Created by Yaoxuan on 5/12/16.
//  Copyright © 2016 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackParams.h"
#import <UIKit/UIKit.h>

@interface TrackParams()

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

- (TrackParams *)initWithReqId:(NSString *)reqId andAction:(NSString *)action {
    self = [super init];
    if (self) {
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

+ (TrackParams *)createWithAccessKey:(NSString *)accessKey reqId:(NSString *)reqId andAction:(NSString *)action
{
    if( accessKey == nil || [accessKey length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: accessKey",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    if( reqId == nil || [reqId length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: reqId",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    if( action == nil || [action length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: action",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }

    return [[TrackParams new] initWithCID:accessKey ReqId:reqId andAction:action];
}

+ (TrackParams *)createWithAppKey:(NSString *)appKey reqId:(NSString *)reqId andAction:(NSString *)action
{
    if( appKey == nil || [appKey length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: appKey",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    if( reqId == nil || [reqId length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: reqId",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    if( action == nil || [action length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: action",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    return [[TrackParams new] initWithCID:appKey ReqId:reqId andAction:action];
}

// accesskey is now retrieve directly from visearch client
+ (TrackParams *)createWithReqId:(NSString *)reqId andAction:(NSString *)action
{
    if( reqId == nil || [reqId length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: reqId",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    if( action == nil || [action length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: action",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    return [[TrackParams new] initWithReqId:reqId andAction:action];
}

- (NSDictionary *)toDict {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setValue:self.action forKey:@"action"];
    [dic setValue:self.imName forKey:@"im_name"];
    [dic setValue:self.reqId forKey:@"reqid"];
    [dic setValue:self.cid forKey:@"cid"];
    [dic setValue:self.cuid forKey:@"cuid"];
    
    return dic;
}


@end
