//
//  ReminderDetailsViewController.h
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/11/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"


@interface ReminderDetailsViewController : UITableViewController
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
