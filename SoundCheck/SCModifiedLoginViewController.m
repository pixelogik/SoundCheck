//
//  SCModifiedLoginViewController.m
//  SoundCheck
//
//  Created by Ole Krause-Sparmann on 18.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCModifiedLoginViewController.h"

#import "SCLoginView.h"

@interface SCModifiedLoginViewController ()

@end

@implementation SCModifiedLoginViewController

- (void)dealloc;
{
    // Make sure the scroll view's delegate is nil
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[SCLoginView class]]) {
            ((SCLoginView*)subview).delegate = nil;
        }
    }
    
    [super dealloc];
}

@end
