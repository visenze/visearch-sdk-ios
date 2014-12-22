//
//  ViSearchError.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import "ViSearchError.h"

@implementation ViSearchError

@synthesize httpStatusCode;
@synthesize errorCode;
@synthesize message;

-(id) initWithErrorMsg:(NSString*) msg andHttpStatusCode:(int)httpCode andErrorCode:(int) code {
    if ((self = [super init]) ) {
        self.httpStatusCode = httpStatusCode;
        self.errorCode = code;
        if (msg != nil)
            self.message = [[NSString alloc] initWithString: msg];
    }
    return self;
}

+(id) errorWithErrorMsg:(NSString*) msg andHttpStatusCode:(int)httpCode andErrorCode:(int) code {
    return [[ViSearchError alloc] initWithErrorMsg:msg andHttpStatusCode:httpCode andErrorCode:code];
}

+(id) checkErrorFromJSONDictionary:(NSDictionary*) dict andHttpStatusCode:(int)httpCode{
    if (dict[@"error_code"] != nil)
        return [ViSearchError errorWithErrorMsg:dict[@"error"] andHttpStatusCode:httpCode andErrorCode:[dict[@"error_code"] intValue]];
    
    return nil;
}


@end