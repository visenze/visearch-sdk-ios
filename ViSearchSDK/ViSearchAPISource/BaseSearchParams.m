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
        self.facet = nil;
        self.facetSize = 10;
        self.fq = nil;
        self.fl = nil;
        self.queryInfo = nil;
        self.custom = nil;
        
    }
    return self;
}

@end

