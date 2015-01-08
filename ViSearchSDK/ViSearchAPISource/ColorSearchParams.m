//
//  ColorSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "ColorSearchParams.h"

@implementation ColorSearchParams

@synthesize color;


- (NSDictionary *)toDict{
    NSDictionary * dict = [super toDict];
    [dict setValue:color forKey:@"color"];
    return dict;
}

@end