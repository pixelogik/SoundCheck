//
//  SCTrackResponse.h
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 15.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "SCTrack.h"

// Model class for API track listing JSON
@interface SCTrackResponse : JSONModel

@property (strong, nonatomic) NSArray<SCTrack> *tracks;

@end
