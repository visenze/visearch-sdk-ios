//
//  SearchOperation.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/19/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//
#import "ViSearchResult.h"
#import "ColorSearchParams.h"
#import "SearchParams.h"
#import "UploadSearchParams.h"

@interface SearchOperation : NSObject

-(ViSearchResult*) search: (SearchParams*) params;
-(ViSearchResult*) colorSearch: (ColorSearchParams*) params;
-(ViSearchResult*) uploadSearch: (UploadSearchParams*) params;

@end
