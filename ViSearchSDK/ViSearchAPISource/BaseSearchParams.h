//
//  BaseSearchParams.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/17/14.
//
//
#import <Foundation/Foundation.h>
#import "ViVersion.h"

@interface BaseSearchParams: NSObject

@property (atomic) int limit;
@property (atomic) int page;
@property (atomic) BOOL score;
@property (atomic) NSMutableDictionary *fq;
@property (atomic) NSArray *fl;
@property (atomic) BOOL queryInfo;
@property (atomic) NSDictionary *custom;
@property (atomic) float scoreMin;
@property (atomic) float scoreMax;
@property (atomic) BOOL getAllFl;
@property (atomic) NSString *detection;

@property (atomic) NSArray *facets;
@property (atomic) int facetsLimit;
@property (atomic) BOOL facetShowCount;
@property (atomic) BOOL dedup;



- (id)init;
- (NSDictionary*)toDict;
- (NSData*)httpPostBodyWithObject:(id)object;
@end
