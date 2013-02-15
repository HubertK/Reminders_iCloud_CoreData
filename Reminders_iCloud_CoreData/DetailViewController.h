//
//  DetailViewController.h
//  Reminders_iCloud_CoreData
//
//  Created by Hubert Kunnemeyer on 10/10/12.
//  Copyright (c) 2012 Hubert Kunnemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Event *event;
@end
