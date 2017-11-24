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
@synthesize reqId = _reqId;
@synthesize imId = _imId;
@synthesize productTypes = _productTypes;
@synthesize productTypesList = _productTypesList;
@synthesize objectTypesList = _objectTypesList;
@synthesize facets = _facets;
@synthesize objects = _objects;

- (id)initWithSuccess: (BOOL) succ withError: (ViSearchError*) err {
    return [self initWithSuccess:succ withError:err andContent:nil];
}

- (id)initWithSuccess:(BOOL)succ withError:(ViSearchError *)err andContent:(NSDictionary *)cnt {
    if ((self = [super init]) ) {
        success = succ;
        content = cnt;
        if (err != nil)
            error = err;
        }
    return self;
}

+ (id)resultWithSuccess: (BOOL) success withError: (ViSearchError*) error {
    return [[ViSearchResult alloc] initWithSuccess:success withError:error];
}

+ (id)resultWithSuccess:(BOOL)success withError:(ViSearchError *)error andContent:(NSDictionary *)content {
    return [[ViSearchResult new] initWithSuccess:success withError:error andContent:content];
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

- (NSString *)reqId {
    return [self.content objectForKey:@"X-Log-ID"];
}

- (NSString *)imId {
    return [self.content objectForKey:@"im_id"];
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

- (NSArray*) facets {
    if (!_facets) {
        _facets = [self.content objectForKey:@"facets"];
    }
    
    return _facets;
}

- (NSArray*) objectTypesList {
    if (!_objectTypesList) {
        NSArray *list = [self.content objectForKey:@"object_types_list"];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in list) {
            ViSearchObjectType *object = [[ViSearchObjectType alloc] init];
            
            if ([dict isKindOfClass:[NSDictionary class]]) {
                object.type = [dict objectForKey:@"type"];
                object.attributes = [dict objectForKey:@"attributes_list"];
            } else {
                object.type = [NSString stringWithFormat:@"%@", dict];
            }
            
            [temp addObject:object];
        }
        
        _objectTypesList = temp;
    }
    
    return _objectTypesList;
}

- (NSArray *)objects {
    if (!_objects) {
        _objects = [NSArray array];
        NSMutableArray *r = [NSMutableArray array];
        
        NSArray* objectValues = [self.content objectForKey:@"objects"];
        for(NSDictionary *data in objectValues) {
            ViSearchObjectResult* object = [[ViSearchObjectResult alloc]init];
            
            NSArray *result = [data objectForKey:@"result"];
            object.imageResultsArray = [self extractImageResults:result];
            
            object.type = [data objectForKey:@"type"];
            object.attributes = [data objectForKey:@"attributes"];
            object.score = [[data objectForKey:@"score"] doubleValue];
            object.total = [[data objectForKey:@"total"] intValue];
            
            NSArray *coordinates = [data objectForKey:@"box"];
            if (coordinates!=nil && coordinates.count > 3) {
                object.box = [[Box alloc] initWithX1:[[coordinates objectAtIndex:0] intValue]
                                                   y1:[[coordinates objectAtIndex:1] intValue]
                                                   x2:[[coordinates objectAtIndex:2] intValue]
                                                   y2:[[coordinates objectAtIndex:3] intValue]];
            }
            
            object.facets =  [data objectForKey:@"facets"];
        
            [r addObject:object];
        }
        
        _objects = r;
    }
    
    return _objects;
}

- (NSArray*) extractImageResults:(NSArray*) values {
    NSMutableArray *r = [NSMutableArray array];
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
    return r;
}

@end
