//
//  ViSearchResult.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import "ViSearchError.h"
#import "ImageResult.h"
#import "ViSearchProductType.h"

@interface ViSearchResult : NSObject

@property (nonatomic, readonly) BOOL success;
@property (nonatomic, readonly) ViSearchError *error;
@property (nonatomic) NSDictionary *content;
@property (nonatomic, readonly) NSArray *imageResultsArray;
@property (nonatomic, readonly) ViSearchProductType *productType;

-(id) initWithSuccess: (BOOL) success withError: (ViSearchError*) error;
+(id) resultWithSuccess: (BOOL) success withError: (ViSearchError*) error;

@end