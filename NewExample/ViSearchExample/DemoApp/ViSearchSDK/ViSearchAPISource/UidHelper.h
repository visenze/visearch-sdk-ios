//
//  UidHelper.h
//  ViSearchExample
//
//  Created by Hung on 28/9/16.
//  Copyright © 2016 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UidHelper : NSObject

// retrieve unique device uid
+ (NSString *)uniqueDeviceUid;

// update if necessary
+ (void) updateStoreDeviceUid:(NSString*)newUid;

@end
