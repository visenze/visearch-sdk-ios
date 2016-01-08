//
//  Applications+CoreDataProperties.h
//  DemoApp
//
//  Created by ViSenze on 8/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Applications.h"

NS_ASSUME_NONNULL_BEGIN

@interface Applications (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access_key;
@property (nullable, nonatomic, retain) NSNumber *account_id;
@property (nullable, nonatomic, retain) NSString *account_name;
@property (nullable, nonatomic, retain) NSNumber *app_id;
@property (nullable, nonatomic, retain) NSString *app_name;
@property (nullable, nonatomic, retain) NSNumber *is_in_use;
@property (nullable, nonatomic, retain) NSString *secret_key;
@property (nullable, nonatomic, retain) NSNumber *is_new;

@end

NS_ASSUME_NONNULL_END
