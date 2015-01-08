//
//  SearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/19/14.
//
//

#import "SearchParams.h"

@implementation SearchParams

@synthesize imName;

- (NSDictionary *)toDict{
    NSDictionary * dict = [super toDict];
    [dict setValue:imName forKey:@"im_name"];
    return dict;
}

@end