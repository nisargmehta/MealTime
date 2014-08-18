//
//  ReviewsView.m
//  MealTime
//
//  Created by Nisarg Mehta on 8/16/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "ReviewsView.h"
#import "Review.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface ReviewsView ()

@end

@implementation ReviewsView

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

    self.enterReviewTextView.delegate = self;
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSString *content = [self fetchAllReviews];
    if (content.length != 0)
    {
        self.reviewsTextView.text = content;
    }
    else
    {
        self.statusLabel.text = [NSString stringWithFormat:@"%@%@",kNoReviews,self.rest.name];
    }
    self.ratingLabel.text = [NSString stringWithFormat:@"%d",(int)roundf(self.ratingSlider.value)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)fetchAllReviews
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND city == %@", self.rest.name, self.rest.city]];
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSManagedObject *restaurant = [results objectAtIndex:0];
    NSMutableSet *reviewsSet = [restaurant valueForKey:kReviewForVisited];
    NSString *content = @"";
    NSArray *reviews = [reviewsSet allObjects];
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:kDateAdded ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    reviews = [reviews sortedArrayUsingDescriptors:descriptors];
    for(int i=0; i<reviews.count; i++)
    {
        int rating = [[reviews[i] valueForKey:kstars] intValue];
        NSString *desc = [reviews[i] valueForKey:kdescription];
        NSDate *date = [reviews[i] valueForKey:kDateAdded];
        content = [content stringByAppendingString:[self getReviewText:[NSString stringWithFormat:@"%d",rating] description:desc currentDate:date]];
    }
    self.statusLabel.text = [NSString stringWithFormat:@"%lu reviews for %@",(unsigned long)reviews.count,self.rest.name];
    return content;
}

-(NSString *) getReviewText:(NSString*)rating description:(NSString*)desc currentDate:(NSDate*)date
{
    return [NSString stringWithFormat:@"Rating: %@\t\tDate: %@\nDescription: %@\n\n\n",rating,[[self getDateFormatter] stringFromDate:date],desc];
}

-(void)sliderValueChanged
{
    self.ratingLabel.text = [NSString stringWithFormat:@"%d",(int)roundf(self.ratingSlider.value)];
}

-(void)addReviewPressed
{
    [self.enterReviewTextView resignFirstResponder];
    // save review and add to text view
    NSString *text = self.enterReviewTextView.text;
    if (!([text isEqualToString:kNewReviewPlaceholder] || [text isEqualToString:@""]))
    {
        [self saveReview];
        self.reviewsTextView.text = [self fetchAllReviews];
    }
    else
    {
        [self showAlert:@"Write the review to add it"];
    }
}

-(void)showAlert:(NSString*)message
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Warning" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)saveReview
{
    // update the restaurant entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kRestaurant inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND city == %@", self.rest.name, self.rest.city]];
    NSManagedObject *newReview = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription
                                                                          entityForName:kReview inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    [newReview setValue:[NSNumber numberWithInt:[self.ratingLabel.text intValue]] forKey:kstars];
    [newReview setValue:self.enterReviewTextView.text forKey:kdescription];
    NSDateFormatter *format = [self getDateFormatter];
    [newReview setValue:[format dateFromString:[format stringFromDate:[NSDate date]]] forKey:kDateAdded];
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSManagedObject *restaurant = [results objectAtIndex:0];
    NSMutableSet *reviews = [restaurant valueForKey:kReviewForVisited];
    [reviews addObject:newReview];
    [restaurant setValue:reviews forKey:kReviewForVisited];
    
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"couldn't save: %@", [saveError localizedDescription]);
    }
}

-(NSDateFormatter*)getDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale: usLocale];
    [dateFormatter setDateFormat:kDateFormat];
    return dateFormatter;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.enterReviewTextView)
    {
        self.enterReviewTextView.text = @"";
    }
}

@end
