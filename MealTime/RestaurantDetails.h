//
//  RestaurantDetails.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/11/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"
#import <MapKit/MapKit.h>

@interface RestaurantDetails : UIViewController <MKMapViewDelegate>

@property (nonatomic,retain) IBOutlet UITextView *content;
@property (strong, nonatomic) Restaurant *rest;
@property (nonatomic,retain) IBOutlet MKMapView *restaurantLocation;
@property (nonatomic, retain) IBOutlet UIButton *visitedButton;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction) vistedPressed;
- (IBAction) thumbsDownPressed;

@end
