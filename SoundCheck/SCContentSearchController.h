//
//  SCContentSearchController.h
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 15.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCTrackResponse;

// Type for response handlers
typedef void (^SCContentSearchResponseHandler)(SCTrackResponse *response, NSError *error);

// This controller requests content form the SC API
@interface SCContentSearchController : NSObject

// Requests a track listing for the specified search term
+ (void)requestTracksForSearchTerm:(NSString*)searchTerm responseHandler:(SCContentSearchResponseHandler)responseHandler;

@end
