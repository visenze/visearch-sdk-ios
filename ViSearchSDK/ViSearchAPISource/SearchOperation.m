//
//  SearchOperation.m
//  Demo
//
//  Created by Shaohuan on 12/19/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import "SearchOperation.h"
#import "ViSearchClient.h"

@implementation SearchOperation

-(ViSearchResult*) search: (SearchParams*) params{
    return [ViSearchClient requestWithMethod:@"search" params:params.toDict];
}
-(ViSearchResult*) colorSearch: (ColorSearchParams*) params{
    return [ViSearchClient requestWithMethod:@"colorsearch" params:params.toDict];
}
-(ViSearchResult*) uploadSearch: (UploadSearchParams*) params{
    if (params.imageFile!=nil)
        return [ViSearchClient requestWithMethod:@"uploadsearch" image:params.imageFile params:params.toDict];
    else
        return [ViSearchClient requestWithMethod:@"uploadsearch" params:params.toDict];
}

@end
