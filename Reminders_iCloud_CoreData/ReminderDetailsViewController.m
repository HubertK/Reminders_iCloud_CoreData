//
//  ReminderDetailsViewController.m
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/11/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import "ReminderDetailsViewController.h"
#import "Reminders.h"


@interface ReminderDetailsViewController ()
@property (strong, nonatomic) NSMutableArray *content;
@end

@implementation ReminderDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

   
}
- (void)viewDidAppear:(BOOL)animated{
    _content = [self localNotificationsForEvent:_event];
    [self setTitle:_event.eventName];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
    UILocalNotification *notif = _content[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", notif.fireDate];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


//Here I'll only load actual Reminder's that are in the app's Scheduled UILocalNotification's Array
//This will confirm the insertion and deletion's are actually occurring with my iCloud Notification's
- (NSMutableArray*)localNotificationsForEvent:(Event*)anEvent{
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventName == %@",anEvent.eventName];
    [fetchRequest setPredicate:predicate];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventName" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
     NSLog(@"Results:%@",results);
    Event *event = [results lastObject];
    NSArray *reminders = [event.reminders allObjects];
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:[reminders count]];
 NSLog(@"Reminders:%@",reminders);
    for (Reminders *rem in reminders) {
        NSString *unique = rem.uniqueIDString;
        UILocalNotification *note = rem.reminderData;
         NSLog(@"Unique:%@",unique);
        for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
        {
            if ([aNotif isEqual:note]) {
                [all addObject:aNotif];
            }
        }

    }
     NSLog(@"ALL :%@",all);
    return all;
}














@end
