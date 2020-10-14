//
//  ViSearchClient.m
//  ViSearch
//
//  Created by Yaoxuan on 3/10/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ViSearchClient.h"
#import "ViSearchBasicHandler.h"
#import "ViSearchImageUploadHandler.h"
#import "UidHelper.h"
#import "StringUtils.h"

@interface ViSearchClient()<ViSearchNetWorkDelegate>

@property (nonatomic) NSString *host;
@property NSOperationQueue *operationQ;

@end

@implementation ViSearchClient
@synthesize host = _host;
@synthesize osv, appId, appName, appVersion;

#pragma mark LifeCycle

+ (ViSearchClient *)sharedInstance {
    static ViSearchClient *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ViSearchClient alloc] init];
        sharedInstance.accessKey = @"";
        sharedInstance.secretKey = @"";
        sharedInstance.isAppKeyEnabled = YES;
        sharedInstance.timeoutInterval = 10;
        sharedInstance.userAgent = kVisenzeUserAgentValue ;
        [sharedInstance setupAnalyticsParam];
        
    });
    
    return sharedInstance;
}

- (ViSearchClient *)initWithBaseUrl:(NSString *)baseUrl accessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    if (self = [super init]) {
        self.host = baseUrl;
        self.accessKey = accessKey;
        self.secretKey = secretKey;
        self.timeoutInterval = 10;
        self.operationQ = [NSOperationQueue new];
        self.userAgent = kVisenzeUserAgentValue ;
        self.isAppKeyEnabled = NO;
        [self setupAnalyticsParam];
    }
    
    return self;
}

- (ViSearchClient *)initWithBaseUrl:(NSString *)baseUrl appKey:(NSString *)appKey {
    if (self = [super init]) {
        self.host = baseUrl;
        self.accessKey = appKey;
        self.secretKey = @"";
        self.isAppKeyEnabled = YES;
        self.timeoutInterval = 10;
        self.operationQ = [NSOperationQueue new];
        self.userAgent = kVisenzeUserAgentValue ;
        [self setupAnalyticsParam];
    }
    
    return self;
}

- (void) setupAnalyticsParam {
    NSOperatingSystemVersion osv = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    self.osv = [NSString stringWithFormat:@"%d.%d.%d", osv.majorVersion, osv.minorVersion, osv.patchVersion];
    
    NSString* bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    self.appId = [StringUtils limitMaxString:bundleId limit:32];
    self.appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
    self.appName = [StringUtils limitMaxString:self.appName limit:32];
      
    self.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.appVersion = [StringUtils limitMaxString:self.appVersion limit:32];
}

#pragma mark Customized Accessors

- (NSString *)host{
    if (_host) {
        return _host;
    } else {
        return @"https://visearch.visenze.com";
    }
}

- (void)setHost:(NSString *)host {
    _host = host;
}

#pragma mark Search API

// call the API and then track this end point
- (void)handleAndTrackWithHandler: (ViSearchHandler*) handler
                          params:(BaseSearchParams *)params
                          success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) successCallback
                          failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    handler.userAgent = self.userAgent ;
    
    // add analytics params
    if (params.uid == nil) {
        params.uid = [UidHelper uniqueDeviceUid];
    }
    
    if (params.sid == nil) {
        params.sid = [UidHelper getSessionId];
    }
    
    params.platform = @"Mobile" ;
    params.deviceBrand = @"Apple";
    params.os = @"iOS";
    params.osv = self.osv;
    
    params.appId = self.appId;
    params.appName = self.appName;
    params.appVersion = self.appVersion;
    
    if (params.deviceModel == nil) {
        params.deviceModel = [StringUtils limitMaxString:[[UIDevice currentDevice] model]  limit:32 ];
    }
    
    if (params.language == nil) {
        params.language = [[NSLocale currentLocale] languageCode] ;
    }
    
    [handler handleWithParams:params
                      success:^(NSInteger statusCode, ViSearchResult *data, NSError *error){
                          successCallback(statusCode, data, error);
                          
                       }
                      failure:failure];
}


- (void)searchWithColor:(ColorSearchParams *)params
                success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    if( params.color == nil || [params.color length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: color code",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    if( [params.color length] != 6 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Color code parameter length must be 6",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-fA-F|0-9]" options:0 error:NULL];
    NSUInteger noOfMatches = [regex numberOfMatchesInString:params.color  options:NSMatchingReportCompletion range:NSMakeRange(0, [params.color length])];
    
    if (noOfMatches != 0) {
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Invalid color code",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.timeoutInterval = self.timeoutInterval;
    handler.searchType = @"colorsearch";
    handler.delegate = self;
    
    [self handleAndTrackWithHandler:handler params:params success:success failure:failure];
}

- (void)searchWithImage:(UploadSearchParams *)params
                success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    // verify that one of img id, image data or image url is required
    if( (params.imageFile == nil) &&
        ( params.imageUrl == nil || [params.imageUrl length] == 0 ) &&
         ( params.imId == nil || [params.imId length] == 0 )
       ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: image file or image url or image id must be provided",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    ViSearchHandler *handler = [ViSearchImageUploadHandler new];
    handler.timeoutInterval = self.timeoutInterval;
    handler.searchType = @"uploadsearch";
    handler.delegate = self;
    
    [self handleAndTrackWithHandler:handler params:params success:success failure:failure];
}

- (void)searchWithImageData:(UploadSearchParams *)params
                    success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                    failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure;
{
    if( params.imageFile == nil ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing image file",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    [self searchWithImage:params success:success failure:failure];
}


- (void)searchWithImageUrl:(UploadSearchParams *)params
                   success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))success
                   failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))failure
{
    if( params.imageUrl == nil || [params.imageUrl length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: image url",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }

    [self searchWithImage:params success:success failure:failure];
}

- (void)searchWithImageId:(SearchParams *)params
                  success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                  failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    if( params.imName == nil || [params.imName length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: image name",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.timeoutInterval = self.timeoutInterval;
    handler.searchType = @"search";
    handler.delegate = self;    

    [self handleAndTrackWithHandler:handler params:params success:success failure:failure];
}

- (void)discoverSearchWithImageUrl:(UploadSearchParams *)params
                           success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))success
                           failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error))failure
{
    if( params.imageUrl == nil || [params.imageUrl length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: image url",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    [self discoverSearchWithImage:params success:success failure:failure];
}

- (void)discoverSearchWithImageData:(UploadSearchParams *)params
                            success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                            failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    if( params.imageFile == nil ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing image file",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    [self discoverSearchWithImage:params success:success failure:failure];
}

- (void)discoverSearchWithImage:(UploadSearchParams *)params
                        success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                        failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    // verify that one of img id, image data or image url is required
    if( (params.imageFile == nil) &&
       ( params.imageUrl == nil || [params.imageUrl length] == 0 ) &&
       ( params.imId == nil || [params.imId length] == 0 )
       ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: image file or image url or image id must be provided",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    ViSearchHandler *handler = [ViSearchImageUploadHandler new];
    handler.timeoutInterval = self.timeoutInterval;
    handler.searchType = @"discoversearch";
    handler.delegate = self;
    
    [self handleAndTrackWithHandler:handler params:params success:success failure:failure];
}


- (void)recommendWithImageName:(SearchParams *)params
                     success:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) success
                     failure:(void (^)(NSInteger statusCode, ViSearchResult *data, NSError *error)) failure
{
    if( params.imName == nil || [params.imName length] == 0 ){
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ %@]: Missing parameter: image name",  NSStringFromClass([self class]), NSStringFromSelector(_cmd)] ;
    }
    
    ViSearchHandler *handler = [ViSearchBasicHandler new];
    handler.timeoutInterval = self.timeoutInterval;
    handler.searchType = @"recommendation";
    handler.delegate = self;
    
    [self handleAndTrackWithHandler:handler params:params success:success failure:failure];
}


#pragma mark ViNetworkDelegate

- (NSString *)getAccessKey {
    return self.accessKey;
}

- (NSString *)getAppKey {
    if (!self.isAppKeyEnabled)
        return nil;
    
    return self.accessKey;
}

- (NSString *)getSecretKey {
    return self.secretKey;
}

- (NSString *)getHost {
    return self.host;
}

- (NSOperationQueue *)getOperationQ {
    if (!self.operationQ) {
        self.operationQ = [NSOperationQueue new];
    }
    return self.operationQ;
}
@end
