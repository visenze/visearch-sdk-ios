//
//  UidHelper.m
//  ViSearchExample
//
//  Created by Hung on 28/9/16.
//  Copyright © 2016 ViSenze. All rights reserved.
//

#import "UidHelper.h"
#import <UIKit/UIKit.h>

#define kViSearchUidKey @"visearch_uid"

@implementation UidHelper

#pragma mark - general nsuserdefaults methods
+ (NSString*) getSettingProp: (NSString*) propName
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault stringForKey:propName];
    if(value == nil)
        value = @"";
    
    return value;
}

+ (void) setSettingProp: (NSString*) propName newValue: (id) propValue
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:propValue forKey:propName];
    [userDefault synchronize];
}

// generate device id for tracking
// first try to get from property, if do not have , then return identifer vendor
+ (NSString *)uniqueDeviceUid {
    NSString* storedUid = [self getSettingProp:kViSearchUidKey];
    if(storedUid == nil || [storedUid length] == 0){
        NSString* deviceId = [UIDevice.currentDevice.identifierForVendor UUIDString] ;
        
        [self setSettingProp:kViSearchUidKey newValue:deviceId];
        
        return deviceId;
    }

    return storedUid;
}

+ (void) updateStoreDeviceUid:(NSString*)newUid
{
     [self setSettingProp:kViSearchUidKey newValue:newUid];
}

@end
