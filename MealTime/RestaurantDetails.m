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
#import "ReviewsView.h"

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
    
    [self.visitedButton setTitle:kMarkVisited forState:UIControlStateNormal];
    [self.thumsDownButton setTitle:kThumbsDownText forState:UIControlStateNormal];
    [self.reviewsButton setTitle:kReviewText forState:UIControlStateNormal];
    self.reviewsButton.hidden = true;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // check if restaurant is marked visited already
    if([self isMarkedVisited])
    {
        [self.visitedButton setTitle:kMarkedVisited forState:UIControlStateNormal];
        self.visitedButton.enabled = false;
        self.reviewsButton.hidden = false;
    }
    self.content.text = [self getContentText];
    
    CLLocationCoordinate2D myCoordinate = {self.rest.latitude.doubleValue, self.rest.longitude.doubleValue};
    //Create your annotation
    MapPin *pin = [[MapPin alloc] initWithCoordinates:myCoordinate placeName:self.rest.name description:self.rest.categoryName];
    
    [self.restaurantLocation addAnnotation:pin];
    
    [self performSelector:@selector(zoomInToMyLocation)
               withObject:nil
               afterDelay:1];
}

-(NSString*)getContentText
{
    NSString *content = [NSString stringWithFormat:@"%@ \n%@, %@, %@\n%@",[self printIfNotNull:self.rest.name], [self printIfNotNull:self.rest.address], [self printIfNotNull:self.rest.city], [self printIfNotNull:self.rest.state], [self printIfNotNull:self.rest.phoneNumber]];
    return content;
}

-(NSString *)printIfNotNull:(NSString*)input
{
    if(input.length == 0)
        return @"";
    else return input;
}

-(void)zoomInToMyLocation
{
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.rest.latitude.doubleValue;
    region.center.longitude = self.rest.longitude.doubleValue;
    region.span.longitudeDelta = 0.05f;
    region.span.latitudeDelta = 0.05f;
    [self.restaurantLocation setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)vistedPressed
{
    [self.visitedButton setTitle:kMarkedVisited forState:UIControlStateNormal];
    self.visitedButton.enabled = false;
    [self saveRestaurant:false];
    // enable reviews
    self.reviewsButton.hidden = false;
}

- (void)thumbsDownPressed
{
    [self.thumsDownButton setTitle:kThumbsDowned forState:UIControlStateNormal];
    self.thumsDownButton.enabled = false;
    self.visitedButton.enabled = false;
    self.reviewsButton.hidden = true;
    [self saveOrUpdateRestaurant];
}

- (void)saveOrUpdateRestaurant
{
    // http://stackoverflow.com/questions/10571786/how-to-update-existing-object-in-core-data/10572134#10572134
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND city == %@", self.rest.name, self.rest.city]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results.count == 0)
    {
        // add the object
        [self saveRestaurant:true];
    }
    else
    {
        NSManagedObject *thumbsDownRest = [results objectAtIndex:0];
        [thumbsDownRest setValue:[NSNumber numberWithBool:true] forKey:kThumbsDown];
    }
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError])
    {
        NSLog(@"Unresolved error %@, %@", saveError, [saveError userInfo]);
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.rest forKey:kObjectRestaurant];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantRemoved object:nil userInfo:dictionary];
}

- (void)saveRestaurant:(BOOL)thumbsDown
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
    [restaurant setValue:[NSNumber numberWithBool:thumbsDown] forKey:kThumbsDown];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"couldn't save: %@", [error localizedDescription]);
    }
}

- (BOOL)isMarkedVisited
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND city == %@", self.rest.name, self.rest.city]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results.count > 0)
        return true;
    else
        return false;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kReviewView])
    {
        ReviewsView *rev = segue.destinationViewController;
        rev.rest = self.rest;
    }
}

@end
