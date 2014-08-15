//
//  Restaurant.m
//  MealTime
//
//  Created by Nisarg Mehta on 8/10/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        _address = [jsonDictionary valueForKeyPath:@"location.address"];
        _city = [jsonDictionary valueForKeyPath:@"location.city"];
        _state = [jsonDictionary valueForKeyPath:@"location.state"];
        _name = [jsonDictionary valueForKeyPath:@"name"];
        _categoryName = [jsonDictionary valueForKeyPath:@"categories.name"][0];
        _phoneNumber = [jsonDictionary valueForKeyPath:@"contact.formattedPhone"];
        _latitude = [jsonDictionary valueForKeyPath:@"location.lat"];
        _longitude = [jsonDictionary valueForKeyPath:@"location.lng"];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    
    }
    return self;
}

@end
