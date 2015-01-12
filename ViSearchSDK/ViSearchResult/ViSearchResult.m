//
//  ViSearchResult.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchResult.h"

@implementation ViSearchResult

@synthesize error;
@synthesize success;
@synthesize content;

-(id) initWithSuccess: (BOOL) succ withError: (ViSearchError*) err {
    if ((self = [super init]) ) {
        success = succ;
        if (err != nil)
            error = err;
    }
    return self;
}

+(id) resultWithSuccess: (BOOL) success withError: (ViSearchError*) error {
    return [[ViSearchResult alloc] initWithSuccess:success withError:error];
}

@end