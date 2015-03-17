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
@synthesize imageResultsArray = _imageResultsArray;

- (id)initWithSuccess: (BOOL) succ withError: (ViSearchError*) err {
    if ((self = [super init]) ) {
        success = succ;
        if (err != nil)
            error = err;
    }
    return self;
}

+ (id)resultWithSuccess: (BOOL) success withError: (ViSearchError*) error {
    return [[ViSearchResult alloc] initWithSuccess:success withError:error];
}

- (NSArray *)imageResultsArray {
    if (!_imageResultsArray) {
        _imageResultsArray = [NSArray array];
        NSMutableArray *r = [NSMutableArray array];
        
        NSArray *values = [self.content objectForKey:@"result"];
        for (NSDictionary *data in values) {
            NSDictionary *values_map = [data objectForKey:@"value_map"];
            NSLog(@"%@", values_map);
            
            ImageResult *imgResult = [ImageResult new];
            imgResult.url = [values_map objectForKey:@"im_url"];
            imgResult.im_name = [data objectForKey:@"im_name"];
            imgResult.metadataDictionary = values_map;
            
            id score = [values_map objectForKey:@"score"];
            if (score) {
                imgResult.score = [score floatValue];
            }
            
            [r addObject:imgResult];

        }
        
        _imageResultsArray = r;
    }
    
    return _imageResultsArray;
}

@end