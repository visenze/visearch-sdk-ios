//
//  TrackParams.h
//  ViSearch
//
//  Created by Yaoxuan on 5/12/16.
//  Copyright © 2016 Shaohuan Li. All rights reserved.
//

#ifndef TrackParams_h
#define TrackParams_h

#import <Foundation/Foundation.h>
#import "BaseSearchParams.h"

@interface TrackParams : BaseSearchParams

@property (nonatomic, readonly) NSString * action;
@property (nonatomic) NSString * imName;
@property (nonatomic, readonly) NSString * reqId;
@property (nonatomic) NSString * cid; // set to access key
@property (nonatomic) NSString * cuid;


- (id) init __unavailable;

- (TrackParams *)withImName:(NSString *)imName;

+ (TrackParams *)createWithCID:(NSString *)cid ReqId:(NSString *)reqId andAction:(NSString *)action __deprecated_msg("use createWithAccessKey:accessKey:reqId:andAction method instead");
+ (TrackParams *)createWithAccessKey:(NSString *)accessKey reqId:(NSString *)reqId andAction:(NSString *)action;
+ (TrackParams *)createWithAppKey:(NSString *)appKey reqId:(NSString *)reqId andAction:(NSString *)action;
+ (TrackParams *)createWithReqId:(NSString *)reqId andAction:(NSString *)action;


@end

#endif /* TrackParams_h */
