//
//  coreDataModel.h
//  Test
//
//  Created by ViSenze on 3/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "constants.h"
#import "Applications+CoreDataProperties.h"

@interface CoreDataModel : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataModel*) sharedInstance;
- (NSManagedObjectContext*) managedObjectContext;
- (Applications*) getApplicationInUse;
- (void) insertApplication:(NSDictionary*)json;

@end
