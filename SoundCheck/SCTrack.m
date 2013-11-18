//
//  SCTrack.m
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 15.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCTrack.h"

@interface SCTrack ()

- (UIImage*)loadImageFromURLString:(NSString*)urlString;

@end

@implementation SCTrack

#pragma mark - Image loading

- (void)loadImagesSynchronously
{
    self.artworkImage = [self loadImageFromURLString:self.artwork_url];
    DLog(@"Loaded artwork image for track %@", self.title);
    
    // I am not using the wave image because I does not look good in my UI.
    // I hope this is enough to show that I know how to retrieve it.
    // self.waveImage = [self loadImageFromURLString:self.waveform_url];
}

- (UIImage*)loadImageFromURLString:(NSString*)urlString
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) return nil;
    return [UIImage imageWithData:data];
}

@end
