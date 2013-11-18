//
//  SCSearchTextField.m
//  SoundCheck
//
//  Created by Ole Krause-Sparmann on 18.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCSearchTextField.h"

@implementation SCSearchTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.tintColor = [UIColor whiteColor];
        
        self.font = [UIFont fontWithName:@"Sintony-Bold" size:16.0];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds,  UIEdgeInsetsMake(0, 5, 0, 0))];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 5, 0, 0))];
}

@end
