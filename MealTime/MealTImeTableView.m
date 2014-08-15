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

@interface MealTimeTableView ()
{
    NSArray *_restaurants;
    NSDictionary *_jsonDictionary;
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
    // AJNotificationView
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    [self.searchBar setImage:[UIImage imageNamed:@"locationIcon.png"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getRestaurantJson:(NSString *)zipcode
{
    /*
     @"https://api.foursquare.com/v2/venues/search?near=%2202472,%20US%22&categoryId=4d4b7105d754a06374d81259&intent=browse&radius=400&oauth_token=4VU1PAQWB5FKKJ0TEDUZXCMPOA3ZRQCO0OWIGZLET3VHJLFK&v=20140810"
     */
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?near='%@, US'&categoryId=4d4b7105d754a06374d81259&intent=browse&radius=800&oauth_token=4VU1PAQWB5FKKJ0TEDUZXCMPOA3ZRQCO0OWIGZLET3VHJLFK&v=20140810",zipcode];
    urlAsString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _restaurants = [self restaurantsFromJsonData:url];
        // Now that we have the data, reload the table data on the main UI thread
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
}

-(NSArray*)restaurantsFromJsonData:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    // Get the data
    NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray *restaurants = [[NSMutableArray alloc] init];
    NSArray *array = [jsonDictionary valueForKeyPath:@"response.venues"];
    // Iterate through the array of dictionaries
    for(NSDictionary *dict in array) {
        // Create a new post object for each one and initialise it with information in the dictionary
        Restaurant *restaurant = [[Restaurant alloc] initWithJSONDictionary:dict];
        // TODO: check if its thumbsDown if yes dont add 
        [restaurants addObject:restaurant];
    }
    return restaurants;
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
    cell.detailTextLabel.text = rest.categoryName;
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kRestaurantDetails])
    {
        RestaurantDetails *detail = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        Restaurant *rest = [_restaurants objectAtIndex:indexPath.row];
        detail.rest = rest;
    }
    else if([segue.identifier isEqualToString:kVisitedRestaurants])
    {
        //VisitedRestaurants *visited = segue.destinationViewController;
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
    [self getRestaurantJson:self.searchBar.text];
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
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

-(void)barButtonPressed
{
    [self performSegueWithIdentifier:kVisitedRestaurants sender:nil];
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
    //NSLog(@"didFailWithError: %@", error);
    [self showAlert:@"Failed to get your location"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    [locationManager stopUpdatingLocation];
    
    __block NSString *zipcode = @"";
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            zipcode = placemark.postalCode;
        } else {
            NSLog(@"%@", error.debugDescription);
        }
        if ([self validateInput:zipcode])
        {
            [self getRestaurantJson:zipcode];
        }
    } ];
}

@end
