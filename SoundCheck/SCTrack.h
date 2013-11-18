//
//  SCTrack.h
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 15.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "SCTrackUser.h"

// We need this for JSONModel's embedding mechanism (NSArray<SCTrack>)
@protocol SCTrack <NSObject>
@end

// Tracks as coming from the API
@interface SCTrack : JSONModel

// These fields are coming from the API listing call
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *waveform_url;
@property (copy, nonatomic) NSString *artwork_url;
@property (copy, nonatomic) NSString *permalink_url;
@property (strong, nonatomic) SCTrackUser *user;

// This is NOT coming from the API listing call but set later by the image loading code
@property (copy, nonatomic) NSString<Optional> *accountId;

// This is NOT coming from the API listing call but set later by the image loading code
@property (copy, nonatomic) NSString<Optional> *queryString;

// These are also NOT coming from the API listing call, they are loaded afterwards
@property (strong, nonatomic) UIImage<Optional> *artworkImage;
@property (strong, nonatomic) UIImage<Optional> *waveImage;

// Loads synchronously images from source URLs. Call this on a background thread
- (void)loadImagesSynchronously;

@end
