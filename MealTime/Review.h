//
//  Reviews.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/16/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Review : NSManagedObject

@property (nonatomic,retain) NSNumber *stars;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *date;

@end
