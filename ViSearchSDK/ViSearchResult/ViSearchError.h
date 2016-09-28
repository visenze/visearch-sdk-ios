//
//  ViSearchError.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/4/14.
//
//

#import <Foundation/Foundation.h>

@interface ViSearchError : NSObject

/*!
 *  @brief http status code
 */
@property int httpStatusCode;

/*!
 *  @brief error code which defined by ViSearch API, may not be availble
 */
@property int errorCode;

/*!
 *  @brief error message
 */
@property (nonatomic, strong) NSString* message;


-(id) initWithErrorMsg:(NSString*) msg andHttpStatusCode:(int)httpCode andErrorCode:(int) code;
+(id) errorWithErrorMsg:(NSString*) msg andHttpStatusCode:(int)httpCode andErrorCode:(int) code;
+(id) checkErrorFromJSONDictionary:(NSDictionary*) dict andHttpStatusCode:(int)httpCode;

@end
