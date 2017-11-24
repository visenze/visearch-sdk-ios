//
//  ViSearchObjectResult.h
//  ViSearchExample
//
//  Created by Hung on 24/11/17.
//  Copyright © 2017 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box.h"
#import "ImageResult.h"

@interface ViSearchObjectResult : NSObject

@property Box *box;
@property double score;
@property NSDictionary *attributes;
@property NSString *type;
@property (nonatomic, assign) int total;
@property (nonatomic, strong) NSArray *imageResultsArray;
@property (nonatomic, strong) NSArray *facets;

@end
