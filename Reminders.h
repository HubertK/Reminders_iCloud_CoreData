//
//  Reminders.h
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/10/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Reminders : NSManagedObject

@property (nonatomic, retain) id reminderData;
@property (nonatomic, retain) NSString * uniqueIDString;
@property (nonatomic, retain) Event *event;

@end
