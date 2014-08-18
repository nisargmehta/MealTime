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
    UIActivityIndicatorView *activity;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property BOOL fromSearchBar;
@property BOOL fromLocationIcon;

//- (IBAction) barButtonPressed;

@end
