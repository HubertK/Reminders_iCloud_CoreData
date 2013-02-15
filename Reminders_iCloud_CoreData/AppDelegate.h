//
//  AppDelegate.h
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/10/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CoreDataController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CoreDataController *coreDataController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
