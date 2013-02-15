//
//  DetailViewController.m
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/10/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import "DetailViewController.h"
#import "Reminders.h"
#import "Event.h"
#import "AppDelegate.h"
#import "CoreDataController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *intervalControl;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
- (void)configureView;
- (IBAction)setReminder:(id)sender;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
   
}

- (IBAction)setReminder:(id)sender {
    [self addNotification];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = ad.coreDataController.mainThreadContext;
    [self configureView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)addNotification{
    
    NSDate *setDate = _datePicker.date;
    NSString *objectName = _nameField.text;
    
    id appIdObject = [NSUUID UUID];
    NSString *IDString = [appIdObject UUIDString];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = setDate;
    localNotification.repeatInterval = [self repeatInterval];
    NSLog(@"Notification will be shown on: %@",localNotification.fireDate);
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = [NSString stringWithFormat:
                                   @"Notification %@",IDString];
    localNotification.alertAction = NSLocalizedString(@"View details", nil);
    NSDictionary *userInfo = @{objectName : IDString};
    
    localNotification.userInfo = userInfo;
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
     NSLog(@"Scheduale Notification :%@",localNotification);
     NSLog(@"MOC:%@",self.managedObjectContext);
    Event *newEvent = [self eventForName:self.nameField.text];
       
    newEvent.eventName = objectName;
    
    Reminders *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminders" inManagedObjectContext:self.managedObjectContext];
    reminder.uniqueIDString = IDString;
    reminder.reminderData = localNotification;
    
    [newEvent addRemindersObject:reminder];
    
    NSError *saveError;
    [self.managedObjectContext save:&saveError];
    
    if(saveError){
         NSLog(@"ERROR SAVING NEW OBJECT____ERROR:%@",saveError);
    }
    else{
         NSLog(@"SUCCESSFULLY SAVED NEW OBJECT");
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (NSInteger)repeatInterval{
    switch (_intervalControl.selectedSegmentIndex) {
        case 0:
            return 0;
            break;
        case 1:
            return NSDayCalendarUnit;
            break;
        case 2:
            return NSWeekCalendarUnit;
            break;
        case 3:
            return NSMonthCalendarUnit;
            break;
            
        default:
            return 0;
            break;
    }
}

#pragma -mark
#pragma mark UITextField Delegate Methods
#pragma -mark
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)eventExistsForName:(NSString*)name{

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventName == %@",name];
    [request setPredicate:predicate];
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)

    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    if(count == 0) {
        return NO;
    }
    else{
        return YES;
    }

}

- (Event*)eventForName:(NSString*)name{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventName == %@",name];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count]) {
        return [result lastObject];
    }
    else{
       Event* newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        return newEvent;
    }
}
@end
