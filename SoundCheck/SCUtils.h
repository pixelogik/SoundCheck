//
//  SCUtils.h
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 14.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <UIKit/UIKit.h>

// These methods are used for random bubble placement
double randF();
double randR(double center, double radius);

// Some helper methods
@interface SCUtils : NSObject

// Returns color accoring to specified hex code
+ (UIColor*)colorFromHEX:(NSUInteger)hexColor;

// Returns color accoring to specified hex code and alpha value
+ (UIColor*)colorFromHEX:(NSUInteger)hexColor withAlpha:(double)alpha;

// Returns scaled image
+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size;

@end

