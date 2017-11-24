//
//  ViSearchObjectType.h
//  ViSearchExample
//
//  Created by Hung on 24/11/17.
//  Copyright © 2017 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box.h"

@interface ViSearchObjectType : NSObject

@property Box *box;
@property double score;
@property NSDictionary *attributes;
@property NSString *type;

@end
