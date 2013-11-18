//
//  SCUtils.m
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 14.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCUtils.h"

double randF()
{
    return (double)rand()/(double)RAND_MAX;
}

double randR(double center, double radius)
{
    return center + ( randF() - 0.5) * radius;
}

@implementation SCUtils

+ (UIColor*)colorFromHEX:(NSUInteger)hexColor
{
    NSUInteger uiRed   = (hexColor>>16) & 0xff;
    NSUInteger uiGreen = (hexColor>> 8) & 0xff;
    NSUInteger uiBlue  = (hexColor>> 0) & 0xff;
    return [UIColor colorWithRed:((float)uiRed/255.0) green:((float)uiGreen/255.0) blue:((float)uiBlue/255.0) alpha:1.0];
}

+ (UIColor*)colorFromHEX:(NSUInteger)hexColor withAlpha:(double)alpha
{
    NSUInteger uiRed   = (hexColor>>16) & 0xff;
    NSUInteger uiGreen = (hexColor>> 8) & 0xff;
    NSUInteger uiBlue  = (hexColor>> 0) & 0xff;
    return [UIColor colorWithRed:((float)uiRed/255.0) green:((float)uiGreen/255.0) blue:((float)uiBlue/255.0) alpha:alpha];
}

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end

