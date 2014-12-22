//
//  BaseSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/17/14.
//
//

#import "BaseSearchParams.h"

@implementation BaseSearchParams

@synthesize limit, page, facet, facetSize, score, fq, fl, queryInfo, custom;
- (id)init
{
    if( self = [super init] )
    {
        self.limit = 10;
        self.page = 1;
        self.facet = false;
        self.facetSize = 10;
        self.score = false;
        self.fq = nil;
        self.fl = nil;
        self.queryInfo = nil;
        self.custom = nil;
        
    }
    return self;
}

- (NSDictionary *)toDict{
    NSDictionary * dict = [[NSDictionary alloc] init];
    if (limit > 0) {
        [dict setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    }
    
    if (page> 0) {
        [dict setValue:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    }
    
    if (facet && facetSize > 0) {
        [dict setValue:facet? @"true":@"false" forKey:@"facet"];
        [dict setValue:[NSString stringWithFormat:@"%ld", (long)facetSize] forKey:@"facetSize"];
    }
    
    if (score > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", score] forKey:@"score"];
    }
    
    if (fq!= nil) {
        for (NSString* key in fq.allKeys) {
            [dict setValue:[NSMutableString stringWithFormat: @"%@:%@",key, [fq objectForKey:key]] forKey:@"fq"];
        }
    }
    
    if (fl!= nil) {
        NSMutableString* builder = [@"" mutableCopy];
        
        for (int i=0; i<[fl count]; i++) {
            [builder appendString:[fl objectAtIndex: i]];
            if(i < [fl count]-1)
                [builder appendString:@","];
        }
        [dict setValue:builder forKey:@"fl"];
    }
    
    if (queryInfo) {
        [dict setValue:@"true" forKey:@"qinfo"];
    }
    
    for (NSString* key in custom.allKeys) {
        [dict setValue:[NSMutableString stringWithFormat: @"%@:%@",key, [custom objectForKey:key]] forKey:key];
    }
    
    return dict;
}

@end