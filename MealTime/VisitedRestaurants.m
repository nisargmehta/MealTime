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
    NSMutableArray *_restaurants;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshTableView:)
                                                 name:kRestaurantRemoved object:nil];
    
    [self getRestaurantList];
}

- (void)RefreshTableView:(NSNotification *)note
{
    Restaurant *removedRest = [[note userInfo] valueForKey:kObjectRestaurant];
    [_restaurants enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Restaurant *r, NSUInteger index, BOOL *stop) {
        if ([r.name isEqualToString:removedRest.name] && [r.city isEqualToString:removedRest.city])
        {
            [_restaurants removeObjectAtIndex:index];
        }
    }];
    [self.tableView reloadData];
}

-(void)getRestaurantList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    if (self.isVisitedRestaurant)
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"thumbsDown != true"]];
        self.navigationItem.title = @"Saved Restaurants";
    }
    else
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"thumbsDown == true"]];
        self.navigationItem.title = @"Disliked Restaurants";
    }
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

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isVisitedRestaurant)
        return @"Delete";
    else
        return kRemove;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // http://stackoverflow.com/questions/10482311/delete-an-object-in-core-data
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext]];
        
        Restaurant *deleteRestaurant = [_restaurants objectAtIndex:indexPath.row];
        NSString *name = deleteRestaurant.name;
        NSString *city = deleteRestaurant.city;
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND city == %@", name, city]];
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *managed in results)
        {
            [self.managedObjectContext deleteObject:managed];
        }
        NSError *saveError = nil;
        if ([self.managedObjectContext save:&saveError] == NO) {
            NSAssert(NO, @"Save should not fail\n%@", [saveError localizedDescription]);
            abort();
            return;
        }
        [_restaurants removeObjectAtIndex:indexPath.row];
        // delete the row
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Selected %@",indexPath);
    if (!self.isVisitedRestaurant)
    {
        return;
    }
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

//-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    
//}

@end
