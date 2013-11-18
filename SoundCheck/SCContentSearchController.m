//
//  SCContentSearchController.m
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 15.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCContentSearchController.h"

#import <SCSoundCloud.h>
#import <SCRequest.h>

#import "SCTrackResponse.h"

@implementation SCContentSearchController

+ (void)requestTracksForSearchTerm:(NSString*)searchTerm responseHandler:(SCContentSearchResponseHandler)responseHandler
{        
    [SCRequest performMethod:SCRequestMethodGET onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks.json"] usingParameters:@{@"q": searchTerm} withAccount:[SCSoundCloud account] sendingProgressHandler:nil responseHandler:
     ^(NSURLResponse *response, NSData *responseData, NSError *error) {
         
         // In case of missing data or error just fail
         if (!responseData || error) {
             responseHandler(nil, error);
         }
         
         // Get data as string
         NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         // Embed track array in JSON dict, otherwise JSONModel can't parse it
         dataString = [NSString stringWithFormat:@"{ \"tracks\": %@ }", dataString];
         
         // Parse JSON
         JSONModelError *jsonError;
         SCTrackResponse *tracks = [[SCTrackResponse alloc] initWithString:dataString error:&jsonError];

         // Call response handler. In case of invalid JSON tracks will be nil and jsonError will be set
         responseHandler(tracks, jsonError);
     }];
}

@end

