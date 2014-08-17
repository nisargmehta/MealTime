//
//  MealTImeTableView.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/10/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MealTimeTableView : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;

//- (IBAction) barButtonPressed;

@end
