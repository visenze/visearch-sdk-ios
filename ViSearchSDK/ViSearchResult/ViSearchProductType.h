//
//  ViSearchProductType.h
//  VisenzeDemo
//
//  Created by ViSenze on 5/1/16.
//  Copyright © 2016 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box.h"

@interface ViSearchProductType : NSObject

@property Box *box;
@property double score;
@property NSDictionary *attributes;
@property NSString *type;

@end
