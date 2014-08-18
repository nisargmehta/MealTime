//
//  UINavigationItem+MultipleButtonsAddition.h
//  MealTime
//
//  Created by Nisarg Mehta on 8/17/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem(MultipleButtonsAddition)
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* rightBarButtonItemsCollection;
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* leftBarButtonItemsCollection;
@end
