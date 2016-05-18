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
@property (nonatomic, readonly) NSString * imName;
@property (nonatomic, readonly) NSString * reqId;
@property (nonatomic, readonly) NSString * cid;

- (id) init __unavailable;

- (TrackParams *)withImName:(NSString *)imName;

+ (TrackParams *)createWithCID:(NSString *)cid ReqId:(NSString *)reqId andAction:(NSString *)action;

@end

#endif /* TrackParams_h */
