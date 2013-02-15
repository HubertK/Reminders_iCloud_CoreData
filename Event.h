//
//  Event.h
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/10/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Reminders;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSSet *reminders;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addRemindersObject:(Reminders *)value;
- (void)removeRemindersObject:(Reminders *)value;
- (void)addReminders:(NSSet *)values;
- (void)removeReminders:(NSSet *)values;

@end
