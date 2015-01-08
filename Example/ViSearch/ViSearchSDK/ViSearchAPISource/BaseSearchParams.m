//
//  BaseSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/17/14.
//
//

#import "BaseSearchParams.h"

@implementation BaseSearchParams

@synthesize limit, page, facet, facetSize, facetField, score, fq, fl, queryInfo, custom;
- (id)init
{
    if( self = [super init] )
    {
        self.limit = 10;
        self.page = 1;
        self.facet = false;
        self.facetSize = 10;
        self.facetField = nil;
        self.score = false;
        self.fq = nil;
        self.fl = nil;
        self.queryInfo = false;
        self.custom = nil;
        
    }
    return self;
}

- (NSDictionary *)toDict{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if (limit > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    }
    
    if (page> 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    if (facet && facetSize > 0) {
        [dict setValue:facet? @"true":@"false" forKey:@"facet"];
        [dict setValue:[NSString stringWithFormat:@"%d", facetSize] forKey:@"facet_size"];
        if (facetField!= nil) {
            NSMutableString* builder = [@"" mutableCopy];
            
            for (int i=0; i<[facetField count]; i++) {
                [builder appendString:[facetField objectAtIndex: i]];
                if(i < [facetField count]-1)
                    [builder appendString:@","];
            }
            [dict setValue:builder forKey:@"facet_field"];
        }
    }
    
    if (score > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", score] forKey:@"score"];
    }
    
    if (fq!= nil) {
        NSMutableString* builder = [@"" mutableCopy];
        NSArray *keys=[fq allKeys];
        for (int i=0; i<[keys count]; i++) {
            [builder appendString:[NSMutableString stringWithFormat: @"%@:%@",[keys objectAtIndex:i], [fq objectForKey:[keys objectAtIndex:i]]] ];
            if(i < [fq count]-1)
                [builder appendString:@","];
        }
        [dict setValue:builder forKey:@"fq"];
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