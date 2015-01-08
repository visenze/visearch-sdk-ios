//
//  ViSearchResult.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "ViSearchError.h"

@interface ViSearchResult : NSObject

@property BOOL success;

@property (nonatomic, strong) ViSearchError *error;

@property (nonatomic, strong) NSDictionary *content;

-(id) initWithSuccess: (BOOL) success withError: (ViSearchError*) error;
+(id) resultWithSuccess: (BOOL) success withError: (ViSearchError*) error;

@end