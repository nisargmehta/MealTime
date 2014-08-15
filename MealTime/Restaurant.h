//
//  Restaurant.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/10/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@property (copy) NSString *address;
@property (copy) NSString *city;
@property (copy) NSString *state;
@property (copy) NSString *name;
@property (copy) NSString *categoryName;
@property (copy) NSString *phoneNumber;
@property (copy) NSNumber *latitude;
@property (copy) NSNumber *longitude;

@end
