//
//  coreDataModel.m
//  Test
//
//  Created by ViSenze on 3/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "CoreDataModel.h"

@implementation CoreDataModel {
    NSArray *fetchedObjects;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (CoreDataModel*)sharedInstance
{
    static CoreDataModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreDataModel alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

#pragma mark - core data operations
- (Applications*) getApplicationInUse {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME];
    [request setPredicate:[NSPredicate predicateWithFormat:@"is_in_use = %@", [NSNumber numberWithBool:YES]]];
    
    NSError *error;
    fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (fetchedObjects.count > 0) {
        return [fetchedObjects objectAtIndex:0];
    }
    
    return nil;
}

- (void) insertApplication:(NSDictionary*)json {
    if (json) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME];
        
//        [request setPredicate:[NSPredicate predicateWithFormat:@"access_key = %@ and secret_key = %@", [json objectForKey:@"access_key"],[json objectForKey:@"secret_key"]]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"app_key = %@", [json objectForKey:@"app_key"] ]];
        
        
        [request setFetchLimit:1];
        
        NSError *error;
        NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
        
        
        if (count == NSNotFound) { // some error occurred
            NSLog(@"Has error: %@", [error localizedDescription]);
        } else if (count == 0) { // no matching object
            Applications *app = [NSEntityDescription
                                 insertNewObjectForEntityForName:ENTITY_NAME
                                 inManagedObjectContext:self.managedObjectContext];
            
            app.access_key = [json objectForKey:@"access_key"];
            app.account_id = [NSNumber numberWithInteger:[[json objectForKey:@"account_id"] integerValue]];
            app.account_name = [json objectForKey:@"account_name"];
            app.app_id = [NSNumber numberWithInteger:[[json objectForKey:@"app_id"] integerValue]];
            app.app_name = [json objectForKey:@"app_name"];
            app.secret_key = [json objectForKey:@"secret_key"];
            
            app.app_key = [json objectForKey:@"app_key"];
            
            NSLog(@"app_key : %@" , app.app_key);
            
            [self updateUseStatus:[self getApplicationInUse] withBool:NO];
            [self updateUseStatus:app withBool:YES];
            
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Cannot save: %@", [error localizedDescription]);
            }
        }
    }
}

- (void) updateUseStatus:(Applications*)app withBool:(BOOL)val{
    if (app) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME];
//        [request setPredicate:[NSPredicate predicateWithFormat:@"access_key = %@ and secret_key = %@", app.access_key, app.secret_key]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"app_key = %@", app.app_key ]];
        
        
        NSError *error;
        fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (fetchedObjects.count > 0) {
            Applications *newApp = [fetchedObjects objectAtIndex:0];
            newApp.is_in_use = [NSNumber numberWithBool:val];
            
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Cannot save: %@", [error localizedDescription]);
            }
        }
    }
}

#pragma mark - Core Data stack
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.visenze.DemoApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DemoApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DemoApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
