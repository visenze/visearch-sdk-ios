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
@synthesize productTypes = _productTypes;
@synthesize productTypesList = _productTypesList;

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
            
            ImageResult *imgResult = [ImageResult new];
            imgResult.url = [values_map objectForKey:@"im_url"];
            imgResult.im_name = [data objectForKey:@"im_name"];
            imgResult.metadataDictionary = values_map;
            
            id score = [data objectForKey:@"score"];
            if (score) {
                imgResult.score = [score floatValue];
            }
            
            [r addObject:imgResult];

        }
        
        _imageResultsArray = r;
    }
    
    return _imageResultsArray;
}

- (NSArray*) productTypes {
    if (!_productTypes) {
        NSArray *types = [self.content objectForKey:@"product_types"];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in types) {
            ViSearchProductType *product = [[ViSearchProductType alloc] init];
            product.type = [dict objectForKey:@"type"];
            product.score = [[dict objectForKey:@"score"] doubleValue];
            product.attributes = [dict objectForKey:@"attributes"];
            
            NSArray *coordinates = [dict objectForKey:@"box"];
            product.box = [[Box alloc] initWithX1:[[coordinates objectAtIndex:0] intValue]
                                               y1:[[coordinates objectAtIndex:1] intValue]
                                               x2:[[coordinates objectAtIndex:2] intValue]
                                               y2:[[coordinates objectAtIndex:3] intValue]];
            
            [temp addObject:product];
        }
        
        _productTypes = temp;
    }
    
    return _productTypes;
}

- (NSArray*) productTypesList {
    if (!_productTypesList) {
        NSArray *list = [self.content objectForKey:@"product_types_list"];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in list) {
            ViSearchProductType *product = [[ViSearchProductType alloc] init];
                        
            if ([dict isKindOfClass:[NSDictionary class]]) {
                product.type = [dict objectForKey:@"type"];
                product.attributes = [dict objectForKey:@"attributes_list"];
            } else {
                product.type = [NSString stringWithFormat:@"%@", dict];
            }
            
            [temp addObject:product];
        }
        
        _productTypesList = temp;
    }
    
    return _productTypesList;
}

@end