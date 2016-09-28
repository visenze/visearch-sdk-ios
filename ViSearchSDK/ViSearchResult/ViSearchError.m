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
    if([dict[@"status"] isEqualToString:@"OK"]){
        return nil;
    }
    
    if( dict[@"error"]!=nil){
        NSArray* errArr = dict[@"error"];
        NSString* errMsg = [errArr componentsJoinedByString:@","];
        int errCode = -1; // may not available
        if(dict[@"error_code"]!= nil){
            errCode = [dict[@"error_code"] intValue];
        }
        return [ViSearchError errorWithErrorMsg:errMsg andHttpStatusCode:httpCode andErrorCode:errCode];
    }
    
    
    return nil;
}


@end
