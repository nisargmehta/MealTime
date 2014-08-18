//
//  MealTImeTableView.m
//  MealTime
//
//  Created by Nisarg Mehta on 8/10/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "MealTimeTableView.h"
#import "Restaurant.h"
#import "RestaurantDetails.h"
#import "VisitedRestaurants.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface MealTimeTableView ()
{
    NSArray *_restaurants;
    NSDictionary *_jsonDictionary;
    CLLocationDegrees currentLatitude;
    CLLocationDegrees currentLongtitude;
}

@end

@implementation MealTimeTableView

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
    _restaurants = [[NSArray alloc] init];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    
    self.fromSearchBar = false;
    self.fromLocationIcon = false;
    
    currentLatitude = 0; currentLongtitude = 0;
    self.searchBar.delegate = self;
    [self.searchBar setImage:[UIImage imageNamed:@"locationIcon.png"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshTableView:)
                                                 name:kRestaurantRemoved object:nil];
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.hidesWhenStopped = YES;
    CGRect frame = activity.frame;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = self.view.frame.size.height / 2 - frame.size.height / 2;
    activity.frame = frame;
    [self.view addSubview:activity];
    self.tableView.rowHeight = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)RefreshTableView:(NSNotification *)note
{
    Restaurant *removedRest = [[note userInfo] valueForKey:kObjectRestaurant];
    NSMutableArray *array = [_restaurants mutableCopy];
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Restaurant *r, NSUInteger index, BOOL *stop) {
        if ([r.name isEqualToString:removedRest.name] && [r.city isEqualToString:removedRest.city])
        {
            [array removeObjectAtIndex:index];
        }
    }];
    _restaurants = [NSArray arrayWithArray:array];
    [self.tableView reloadData];
}

-(BOOL)checkConnectivity
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)getRestaurantJson:(NSString *)zipcode
{
    if (![self checkConnectivity])
    {
        [self showAlert:@"Sorry, No internet connection!"];
        return;
    }
    _restaurants = [[NSArray alloc] init];
    [activity startAnimating];
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?near='%@, US'&categoryId=4d4b7105d754a06374d81259&intent=browse&radius=800&oauth_token=4VU1PAQWB5FKKJ0TEDUZXCMPOA3ZRQCO0OWIGZLET3VHJLFK&v=20140810",zipcode];
    urlAsString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _restaurants = [self restaurantsFromJsonData:url];
        // sort
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:kDistance ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        _restaurants = [_restaurants sortedArrayUsingDescriptors:descriptors];
        // Now that we have the data, reload the table data on the main UI thread
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_restaurants.count == 0)
            {
                [self showAlert:@"No restaurants found!!"];
            }
            [activity stopAnimating];
        });
    });
}

-(NSArray*)restaurantsFromJsonData:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    // Get the data
    NSHTTPURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if ([response statusCode] >= 400)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showAlert:[NSString stringWithFormat:@"error code: %ld",(long)[response statusCode]]];
        });
        return NULL;
    }
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray *restaurants = [[NSMutableArray alloc] init];
    NSArray *array = [jsonDictionary valueForKeyPath:@"response.venues"];
    // Iterate through the array of dictionaries
    for(NSDictionary *dict in array) {
        // Create a new post object for each one and initialise it with information in the dictionary
        Restaurant *restaurant = [[Restaurant alloc] initWithJSONDictionary:dict];
        // check if its thumbsDown if yes dont add
        if (![self isThumbsDown:restaurant.name restaurantCity:restaurant.city])
        {
            restaurant.distance = [self getDistanceFrom:restaurant.latitude.floatValue longitude:restaurant.longitude.floatValue];
            [restaurants addObject:restaurant];
        }
    }
    return restaurants;
}

-(float) getDistanceFrom:(float)lat longitude:(float)lon
{
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:currentLatitude longitude:currentLongtitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    return distance;
}

-(BOOL)isThumbsDown:(NSString*)name restaurantCity:(NSString*)city 
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND city == %@ AND thumbsDown = true", name, city]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results.count > 0)
        return true;
    else
        return false;
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
    return _restaurants.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"restaurantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Restaurant *rest = [_restaurants objectAtIndex:indexPath.row];
    cell.textLabel.text = rest.name;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",rest.categoryName,[self distanceText:rest.distance]];
    return cell;
}

-(NSString*)distanceText:(float)distance
{
    if (currentLatitude == 0 && currentLongtitude == 0)
        return @"";
    else
        return [NSString stringWithFormat:@"%.0f meters away",distance];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    if ([segue.identifier isEqualToString:kRestaurantDetails])
    {
        RestaurantDetails *detail = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        Restaurant *rest = [_restaurants objectAtIndex:indexPath.row];
        detail.rest = rest;
    }
    else if([segue.identifier isEqualToString:kVisitedRestaurants])
    {
        VisitedRestaurants *visited = segue.destinationViewController;
        visited.isVisitedRestaurant = true;
    }
    else if([segue.identifier isEqualToString:kThumbDownedRestaurants])
    {
        VisitedRestaurants *visited = segue.destinationViewController;
        visited.isVisitedRestaurant = false;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Selected %@",indexPath);
    [self performSegueWithIdentifier:kRestaurantDetails sender:indexPath];
}

#pragma mark - Search Bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    if(![self validateInput:self.searchBar.text])
    {
        [self showAlert:@"Please enter a valid zipcode in the US"];
        return;
    }
    // get the places
    self.fromLocationIcon = false;
    self.fromSearchBar = true;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    currentLatitude =0; currentLongtitude=0;
    [locationManager startUpdatingLocation];
    [self getRestaurantJson:self.searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
}

- (BOOL)validateInput:(NSString *)input
{
    NSString *regex = @"(^[0-9]{5}(-[0-9]{4})?$)";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [test evaluateWithObject:input];
}

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    // get current postal code and call get restaurant Json
    self.fromLocationIcon = true;
    self.fromSearchBar = false;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    currentLongtitude=0;currentLatitude=0;
    [locationManager startUpdatingLocation];
}

-(void)showAlert:(NSString*)message
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - Core location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    NSLog(@"didFailWithError: %@", error);
    if (self.fromLocationIcon)
    {
        [self showAlert:@"Failed to get your location"];
    }
    self.fromLocationIcon = false;
    self.fromSearchBar = false;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    currentLatitude = currentLocation.coordinate.latitude;
    currentLongtitude = currentLocation.coordinate.longitude;
    
    __block NSString *zipcode = @"";
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            zipcode = placemark.postalCode;
        } else {
            NSLog(@"%@", error.debugDescription);
        }
        if ([self validateInput:zipcode] && self.fromLocationIcon)
        {
            [self getRestaurantJson:zipcode];
        }
    } ];
}

@end
