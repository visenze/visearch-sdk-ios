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
#import "ViSearchObjectType.h"
#import "ViSearchObjectResult.h"

@interface ViSearchResult : NSObject

@property (nonatomic, readonly) BOOL success;
@property (nonatomic, readonly) ViSearchError *error;
@property (nonatomic, readonly) NSDictionary *content;
@property (nonatomic, readonly) NSArray *imageResultsArray;
@property (nonatomic, readonly) NSString *reqId;
@property (nonatomic, readonly) NSString *imId;
@property (nonatomic, readonly) NSArray *productTypes;
@property (nonatomic, readonly) NSArray *productTypesList;
@property (nonatomic, readonly) NSArray *facets;

// discover search
@property (nonatomic, readonly) NSArray *objectTypesList;
@property (nonatomic, readonly) NSArray *objects;

-(id) initWithSuccess: (BOOL) success withError: (ViSearchError*) error;
-(id) initWithSuccess:(BOOL)success withError:(ViSearchError *)error andContent:(NSDictionary *)content;
+(id) resultWithSuccess: (BOOL) success withError: (ViSearchError*) error;
+(id) resultWithSuccess:(BOOL)success withError:(ViSearchError *)error andContent:(NSDictionary *)content;

@end
