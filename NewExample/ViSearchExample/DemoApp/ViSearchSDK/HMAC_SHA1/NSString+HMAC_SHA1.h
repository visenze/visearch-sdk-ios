//
//  NSString+HMAC_SHA1.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/22/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HMAC_SHA1)

- (NSString *)HmacSha1WithSecret:(NSString *)key;

@end
