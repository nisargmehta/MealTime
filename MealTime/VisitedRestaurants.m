//
//  VisitedRestaurants.m
//  MealTime
//
//  Created by Nisarg Mehta on 8/12/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "VisitedRestaurants.h"
#import "Restaurant.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "RestaurantDetails.h"

@interface VisitedRestaurants ()

@end

@implementation VisitedRestaurants
{
    NSArray *_restaurants;
}

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
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *restaurants = [[NSMutableArray alloc] init];
    for (NSManagedObject *info in fetchedObjects)
    {
        Restaurant *visited = [[Restaurant alloc] init];
        visited.name = [info valueForKey:kName];
        visited.categoryName = [info valueForKey:kCategoryName];
        visited.address = [info valueForKey:kAddress];
        visited.phoneNumber = [info valueForKey:kPhoneNumber];
        visited.city = [info valueForKey:kCity];
        visited.state = [info valueForKey:kState];
        visited.latitude = [info valueForKey:kLatitude];
        visited.longitude = [info valueForKey:kLongitude];
        [restaurants addObject:visited];
    }
    _restaurants = restaurants;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *CellIdentifier = @"visitedRestaurant";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Restaurant *rest = [_restaurants objectAtIndex:indexPath.row];
    cell.textLabel.text = rest.name;
    cell.detailTextLabel.text = rest.categoryName;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        // http://stackoverflow.com/questions/10482311/delete-an-object-in-core-data
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Selected %@",indexPath);
    [self performSegueWithIdentifier:kVisitedToDetails sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kVisitedToDetails])
    {
        RestaurantDetails *detail = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        Restaurant *rest = [_restaurants objectAtIndex:indexPath.row];
        detail.rest = rest;
    }
}

@end
