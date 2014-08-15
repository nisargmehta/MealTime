//
//  RestaurantDetails.m
//  MealTime
//
//  Created by Nisarg Mehta on 8/11/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "RestaurantDetails.h"
#import "MapPin.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation RestaurantDetails

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // check if restaurant is marked visited already ..
    
    
    // Do any additional setup after loading the view.
    self.content.text = self.rest.name;
    
    CLLocationCoordinate2D myCoordinate = {self.rest.latitude.doubleValue, self.rest.longitude.doubleValue};
    //Create your annotation
    MapPin *pin = [[MapPin alloc] initWithCoordinates:myCoordinate placeName:self.rest.name description:self.rest.categoryName];
    
    [self.restaurantLocation addAnnotation:pin];
    
    [self performSelector:@selector(zoomInToMyLocation)
               withObject:nil
               afterDelay:1];
}

-(void)zoomInToMyLocation
{
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.rest.latitude.doubleValue;
    region.center.longitude = self.rest.longitude.doubleValue;
    region.span.longitudeDelta = 0.07f;
    region.span.latitudeDelta = 0.07f;
    [self.restaurantLocation setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)vistedPressed
{
    self.visitedButton.titleLabel.text = @"Marked as Visited";
    self.visitedButton.enabled = false;
    [self saveRestaurant];
    // enable reviews
    
}

- (void)thumbsDownPressed
{
    // http://stackoverflow.com/questions/10571786/how-to-update-existing-object-in-core-data/10572134#10572134
}

- (void)saveRestaurant
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *restaurant = [NSEntityDescription insertNewObjectForEntityForName:kRestaurant inManagedObjectContext:context];
    [restaurant setValue:self.rest.name forKey:kName];
    [restaurant setValue:self.rest.categoryName forKey:kCategoryName];
    [restaurant setValue:self.rest.address forKey:kAddress];
    [restaurant setValue:self.rest.phoneNumber forKey:kPhoneNumber];
    [restaurant setValue:self.rest.city forKey:kCity];
    [restaurant setValue:self.rest.state forKey:kState];
    [restaurant setValue:self.rest.latitude forKey:kLatitude];
    [restaurant setValue:self.rest.longitude forKey:kLongitude];
    [restaurant setValue:false forKey:kThumbsDown];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"couldn't save: %@", [error localizedDescription]);
    }
}

@end
