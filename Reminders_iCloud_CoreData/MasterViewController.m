//
//  MasterViewController.m
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/10/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "AppDelegate.h"

#import "CoreDataController.h"

#import "ReminderDetailsViewController.h"

#import "Event.h"
#import "Reminders.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    }
    else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        _detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    }
   
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(detailviewManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFetchedResults:)
                                                 name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                               object:appDelegate.coreDataController.psc];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFetchedResults:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:appDelegate.coreDataController.psc];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         [self.navigationController pushViewController:_detailViewController animated:YES];
     }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
     Reminders *reminderObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return reminderObject.event.eventName;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Reminders"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Reminders *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setEvent:object.event];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reminders" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"event.eventName" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"event.eventName" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}


// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Reminders *reminderObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILocalNotification *notif = (UILocalNotification*)reminderObject.reminderData;
    cell.textLabel.text = [NSString stringWithFormat:@"%@", notif.fireDate];
    cell.detailTextLabel.text = reminderObject.uniqueIDString;
}

#pragma -mark
#pragma mark ManagedObjectContextSaveNotification
- (void)detailviewManagedObjectContextDidSave:(NSNotification*)note{
    //I seem to have registered for the ManagedObjectContextSaveNotification
    //and passing this MOC to the next and the next.... Seem to
    //All send notifications to this Event. I'll need to catch "DELETIONS" here because otherwise,
    //the ManagedObject is already gone by the time the PSC notification comes through. All the other Edit's
    //(Insert and Update) can be taken care of in the PSC notification because theyre not being deleted and
    //stick around while I make the pending changes.
    
     NSLog(@"Did Recieve MOC Save Notification:%@",note);
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appdel.coreDataController.mainThreadContext;
    NSMergePolicy *mergePolicy = [[NSMergePolicy alloc]initWithMergeType:NSOverwriteMergePolicyType];
    [self.managedObjectContext setMergePolicy:mergePolicy];
    NSArray *keys = [note.userInfo allKeys];
    for (NSString *key in keys) {
        //The Added User Info KEY is called when the Store is "ADDED" for the MOC
        if ([key isEqualToString:@"added"]) {
            //I Usually Set the MOC here but considering the FetchedResultsController, I needed it
            //before it is created. I suppose we could try and delay the fetchedResultsController
            //from being instantiated untill the MOC is decided. -(TODO)
        }
        if ([key isEqualToString:@"deleted"]) {
            //The KEY "delete" holds aan NSSet of ManagedObjects qued-up for deletion
             NSLog(@"Getting a deletion message");
            NSArray *allobjects = [[note.userInfo valueForKey:@"deleted"]allObjects];
            for (NSManagedObject *obj in allobjects) {
             // I found it's important to check which Entity we are recieving before doing anything
            //with it.
            if ([obj.entity.name isEqualToString:@"Reminders"]) {
                Reminders *reminder = (Reminders*)obj;
                UILocalNotification *notif = reminder.reminderData;
                 NSLog(@"Notif to delete ;%@",notif);
                [self.managedObjectContext deleteObject:reminder];
                [self deletNotifications:notif];
            }
                
            }
        }
    }
    //Do I really need this? Since I'm already handling the editing manually
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
    
    //Don't forget to reload here. Without it, the FetchedResultsController will throw exceptions
    // It won't know the tableview's real datasource values
        [self.tableView reloadData];
}

#pragma -mark
#pragma mark PersistantStore iCloud Notifications
#pragma -mark

//
- (void)reloadFetchedResults:(NSNotification*)note{
    //These Notifications come from the CoreDataController's PSC
    //Since I need finer grained control over the incoming notifications I'll need to parse
    //the the results looking for insertions and updates to the ManagedObject's using their
    //ManagedObjectID's.
    //See the ManagedObjectContextDidSave for Deletions
    if ([note.name isEqualToString:@"NSPersistentStoreCoordinatorStoresDidChangeNotification"]) {
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //OK here i"ll actually set the MOC to whatever the Notification is sending..(iCloud or Local from CoreDataController)
    //And do some maintenance....
    self.managedObjectContext = appdel.coreDataController.mainThreadContext;
    NSMergePolicy *mergePolicy = [[NSMergePolicy alloc]initWithMergeType:NSOverwriteMergePolicyType];
    [self.managedObjectContext setMergePolicy:mergePolicy];
    NSError *error = nil;
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
    [self.managedObjectContext save:&error];
    [self.fetchedResultsController performFetch:&error];
         NSLog(@"Set ManagedObjectContext and Refetched");
    }
    
    //Since this notification MIGHT be coming from another thread....
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSError *error = nil;
        // we can now allow for inserting new names and editing
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        NSLog(@"NAME:%@",[note name]);
        NSArray *keys = [note.userInfo allKeys];
        for (NSString *key in keys) {
            if ([key isEqualToString:@"added"]) {
                
            }
            if ([key isEqualToString:@"deleted"]) {
              //Do nothing, It's already been done
            }
            else if ([key isEqualToString:@"inserted"]) {
                [self enemuerateChangesInDictionary:[note.userInfo valueForKey:key] for:@"Insertion"];;
            }
            else if ([key isEqualToString:@"updated"]) {
                [self enemuerateChangesInDictionary:[note.userInfo valueForKey:key] for:@"Update"];
            }
            [self.managedObjectContext save:&error];
            
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
            
        }
        
    });

}
- (void)enemuerateChangesInDictionary:(NSDictionary*)changesDictionary for:(NSString*)changeType{
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appdel.coreDataController.mainThreadContext;
    for (id obj in changesDictionary) {
        NSLog(@"%@ Changes:%@",changeType,obj);
        
        //Again we're in a new thread and ManagedObject's are NOT thread safe
        //But ManagedObjectID's ARE.. Hurray! Luckily Apple engineer's gave us this little helper....
        NSManagedObject *managedObject = (NSManagedObject*)[moc objectWithID:obj];
        
        if ([changeType isEqualToString:@"Deletion"]) {
            NSLog(@"OBJECT:%@",[obj description]);
            //Delete the object to avoid faulting errors..I'm still not sure why this happens
            //But the Core Data Stack will get confused if we dont delete it here
            [self.managedObjectContext deleteObject:managedObject];
            }
        if ([changeType isEqualToString:@"Insertion"]) {
            //Set a new UILocalNotification matching this Object if it has one
            [self insertNewLocalNotificationForObject:managedObject];
            
        }
        if ([changeType isEqualToString:@"Update"]) {
            NSLog(@"Update ManagedObject Method");
            //Update? Not so sure. Deletions come as updates for ManagedObject relationships
            //But, If its gone it's gone before it get's here
            [self.managedObjectContext refreshObject:managedObject mergeChanges:YES];
            [self parseInsertionResultFromIcloudForNotificationsObject:managedObject];
            
        }
       //The Maintenance
        NSError *error;
        [self.managedObjectContext save:&error];
        if (![self.managedObjectContext hasChanges]) {
            [self.fetchedResultsController performFetch:&error];
        }
        
    }
    
}

//Useless extra method... Smell that?
- (void)parseInsertionResultFromIcloudForNotificationsObject:(NSManagedObject*)object{

    [self replaceNotifications:object];
}

- (void)replaceNotifications:(NSManagedObject*)object{
    
   //Try to fetch a ManagedObject
    NSLog(@"Replace Notifs");
    NSError *fetchError;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSString *entityName = object.entity.name;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    Reminders *updatedReminder;
    
    [request setEntity:entity];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    
    for (NSManagedObject *newObject in results) {
        NSString *kindOfObject = newObject.entity.name;
        if ([kindOfObject isEqualToString:@"Reminders"]) {
            updatedReminder = (Reminders*)newObject;
        }
    }
     
    //Since this is an UPDATE, I'll need to delete the "OLD" UILocalNotification and then set the "NEW" one
    //I fetched above held in the reminders.reminderData
    
    //I need to know if we deleted anything in order to add something
    BOOL didDelete;
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        //Check for matching UUID Strings...This was the key to getting it right
        if ([aNotif.userInfo valueForKey:updatedReminder.uniqueIDString]) {
            [self deletNotifications:aNotif];
            didDelete = YES;
             NSLog(@"Did Delete Notification for ID:%@",updatedReminder.uniqueIDString);
        }
    }
    if (didDelete == YES) {
        UILocalNotification *notification = updatedReminder.reminderData;
        [[UIApplication sharedApplication]scheduleLocalNotification:notification];
         NSLog(@"Schedual Updated Notification for ID:%@",updatedReminder.uniqueIDString);
    }
    
}

- (void)deletNotifications:(UILocalNotification*)notificationToDelete{
    //////Cancel any old Notifications... "I should be passing the UUID String Here"(TODO)
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if ([aNotif isEqual:notificationToDelete]) {
             NSLog(@"Deleted Notification:%@",notificationToDelete);
            [[UIApplication sharedApplication]cancelLocalNotification:aNotif];
        }
        
    }
    
}
- (void)insertNewLocalNotificationForObject:(NSManagedObject*)object{
    NSString *kindOfObject = object.entity.name;
    Reminders *reminder;
    //Always check the Entity before using it!
    if ([kindOfObject isEqualToString:@"Reminders"]) {

        reminder = (Reminders*)object;
    }
    NSString *ID = reminder.uniqueIDString;
     NSLog(@"ID for Insertion:%@",ID);
    BOOL hasUniqueID = NO;
    //Always, Always validate the ManagedObject, I'll do it by checking the UUID String here.
    if ([ID length]) {
    
        //Check if the UILocalNotification's in our app already have this reminder set
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if ([aNotif.userInfo valueForKey:ID]) {
            hasUniqueID = YES;
             NSLog(@"Notification already set no need to reset");
        }
    }
    //If no Reminder is set for this UUID String, Set it Now.
    if (hasUniqueID == NO) {
        UILocalNotification *newNotif = reminder.reminderData;
        [[UIApplication sharedApplication]scheduleLocalNotification:newNotif];
         NSLog(@"Added New Notification for ID:%@",ID);
    }
        
    }
}


//- (void)deleteLocalNotifFor:(NSManagedObject*)object{
//    
//    
//    NSError *fetchError;
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSString *entityName = object.entity.name;
//    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
//    Reminders *reminder;
//    
//    [request setEntity:entity];
//    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
//   
//    for (NSManagedObject *newObject in results) {
//        NSString *kindOfObject = newObject.entity.name;
//        //I Can't say it enough, check the Entity before using it!
//        if ([kindOfObject isEqualToString:@"Reminders"]) {
//            
//        //Checking against ManagedObjectID's probably isn't the best way to do this, I believe they can differ..Ouch
//            if ([newObject.objectID isEqual:object.objectID]) {
//                 NSLog(@"Found Match for ID:%@",newObject.objectID);
//                 reminder = (Reminders*)newObject;
//            }
//           
//        }
//    }
//    NSLog(@"Reminder ID:%@",[reminder uniqueIDString]);
//    if (reminder) {
//        NSLog(@"Deleting Reminder for ID:%@",reminder.uniqueIDString);
//        if ([[[UIApplication sharedApplication]scheduledLocalNotifications]containsObject:reminder.reminderData]) {
//            [[UIApplication sharedApplication]scheduleLocalNotification:reminder.reminderData];
//        }
//    }
//
//}
//











@end
