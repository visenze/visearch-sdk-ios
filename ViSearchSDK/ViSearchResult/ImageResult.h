//
//  ImageResult.h
//  ViSearch
//
//  Created by Yaoxuan on 3/16/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageResult : NSObject

@property NSString *im_name;
@property NSString *url;
@property CGFloat score;
@property NSDictionary *metadataDictionary;

@end
