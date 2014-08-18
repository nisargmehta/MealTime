//
//  ReviewsView.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/16/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface ReviewsView : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Restaurant *rest;
@property (nonatomic, retain) IBOutlet UISlider *ratingSlider;
@property (nonatomic, retain) IBOutlet UIButton *addReview;
@property (nonatomic, retain) IBOutlet UITextView *enterReviewTextView;
@property (nonatomic, retain) IBOutlet UITextView *reviewsTextView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (retain) IBOutlet UILabel *ratingLabel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction) addReviewPressed;
- (IBAction) sliderValueChanged;

@end
