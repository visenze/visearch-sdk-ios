//
//  BaseSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/17/14.
//
//

#import "BaseSearchParams.h"

@implementation BaseSearchParams {
    NSArray *VALUES_DETECTION;
}

@synthesize limit, page, score, fq, fl, queryInfo, custom, scoreMax, scoreMin, getAllFl, detection , facets, facetShowCount, facetsLimit, dedup, uid, sid, os, osv, source, platform, deviceBrand, deviceModel, language, appId, appName, appVersion;

- (id)init
{
    if( self = [super init] )
    {
        self.limit = 10;
        self.page = 1;
        self.score = false;
        self.fq = [NSMutableDictionary dictionary];
        self.fl = nil;
        self.queryInfo = false;
        self.custom = nil;
        self.scoreMin = 0;
        self.scoreMax = 1;
        self.getAllFl = false;
        self.detection = nil;
        
        self.facets = nil ;
        self.facetsLimit = 10;
        self.facetShowCount = false;
        self.dedup = false;
        
    }
    return self;
}

- (NSDictionary *)toDict{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if (limit > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    }
    
    if (page> 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    
    if (score > 0) {
        [dict setValue:@"true" forKey:@"score"];
    }
    
    [dict setValue: [NSString stringWithFormat:@"%f", scoreMax] forKey: @"score_max"];
    [dict setValue: [NSString stringWithFormat:@"%f", scoreMin] forKey: @"score_min"];
    
    [dict setValue:getAllFl?@"true":@"false" forKey:@"get_all_fl"];
    
    if (detection) {
        [dict setValue:detection forKey:@"detection"];
    }
    
    // analytics
    if (self.uid) {
        [dict setValue:self.uid forKey:@"va_uid"];
    }
    
    if (self.sid) {
        [dict setValue:self.sid forKey:@"va_sid"];
    }
    
    if (self.source) {
        [dict setValue:self.source forKey:@"va_source"];
    }
    
    if (self.platform) {
        [dict setValue:self.platform forKey:@"va_platform"];
    }
    
    if (self.os) {
        [dict setValue:self.os forKey:@"va_os"];
    }
    
    if (self.osv) {
        [dict setValue:self.osv forKey:@"va_osv"];
    }
    
    if (self.appId) {
        [dict setValue:self.appId forKey:@"va_app_bundle_id"];
    }
    
    if (self.appName) {
        [dict setValue:self.appName forKey:@"va_app_name"];
    }
    
    if (self.appVersion) {
        [dict setValue:self.appVersion forKey:@"va_app_version"];
    }
    
    if (self.deviceBrand) {
        [dict setValue:self.deviceBrand forKey:@"va_device_brand"];
    }
    
    if (self.deviceModel) {
        [dict setValue:self.deviceModel forKey:@"va_device_model"];
    }
    
    if (self.language) {
        [dict setValue:self.language forKey:@"va_language"];
    }
    
    if (fq) {
        NSMutableArray* builder = [[NSMutableArray alloc]init];
        NSArray *keys=[fq allKeys];
        
        for (int i=0; i<[keys count]; i++) {
            [builder addObject:[NSMutableString stringWithFormat: @"%@:%@",[keys objectAtIndex:i], [fq objectForKey:[keys objectAtIndex:i]]]];
        }
        
        if (builder.count > 0) {
            [dict setValue:builder forKey:@"fq"];
        }
    }
    if (fl!= nil) {
        NSMutableString* builder = [@"" mutableCopy];
        
        for (int i=0; i<[fl count]; i++) {
            [builder appendString:[fl objectAtIndex: i]];
            if(i < [fl count]-1)
                [builder appendString:@","];
        }
        [dict setValue:builder forKey:@"fl"];
    }
    
    if (self.facets != nil) {
        dict[@"facets"] = [self.facets componentsJoinedByString:@"," ];
        dict[@"facets_limit"] = [NSString stringWithFormat:@"%d", self.facetsLimit]  ;
        dict[@"facets_show_count"] = self.facetShowCount ? @"true" : @"false" ;
    }
    
    if (queryInfo) {
        [dict setValue:@"true" forKey:@"qinfo"];
    }
    
    if (self.dedup) {
        [dict setValue:@"true" forKey:@"dedup"];
    }
    
    for (NSString* key in custom.allKeys) {
        [dict setValue:[NSMutableString stringWithFormat: @"%@", [custom objectForKey:key]] forKey:key];
    }
    
    return dict;
}

- (NSData *)httpPostBodyWithObject:(id)object {return nil;}

@end
