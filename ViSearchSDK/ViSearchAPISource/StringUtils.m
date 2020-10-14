//
//  StringUtils.m
//  ViSearchExample
//
//  Created by Hung on 14/10/20.
//  Copyright © 2020 ViSenze. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils

+ (NSString*) limitMaxString:(NSString*)s limit:(int) limit {
    if (s && s.length > limit) {
        return [s substringWithRange:NSMakeRange(0, limit)];
    }
    
    return s;
}

@end
