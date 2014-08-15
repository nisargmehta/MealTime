//
//  VisitedRestaurants.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/12/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitedRestaurants : UITableViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain) IBOutlet UITableView *tableView;

@end
