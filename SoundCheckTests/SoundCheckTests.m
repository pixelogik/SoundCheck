//
//  SoundCheckTests.m
//  SoundCheckTests
//
//  Created by Ole Krause-Sparmann on 17.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SCContentSearchController.h"
#import "SCTrackResponse.h"
#import "SCTrack.h"
#import <SCSoundCloud.h>

@interface SoundCheckTests : XCTestCase

@end

@implementation SoundCheckTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSearchResponseParsing
{
    // Load response JSON from file
    NSError *error = nil;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"trackResponse" ofType:@"json"];
    NSString *dataString = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];

    XCTAssertNil(error, @"loading response data caused an error");
    XCTAssertNotNil(dataString, @"test response data could not be loaded");
    
    // Embed track array in JSON dict, otherwise JSONModel can't parse it
    dataString = [NSString stringWithFormat:@"{ \"tracks\": %@ }", dataString];
    
    // Parse JSON
    JSONModelError *jsonError;
    SCTrackResponse *response = [[SCTrackResponse alloc] initWithString:dataString error:&jsonError];
    
    XCTAssertNil(jsonError, @"json error is not nil");
    XCTAssertNotNil(response, @"response is nil");
    XCTAssertNotNil(response.tracks, @"there are no response tracks");
    
    for (SCTrack *track in response.tracks) {
        NSLog(@"Checking %@", track.title);
        XCTAssertTrue(track.id, @"track.id is nil");
        XCTAssertTrue(track.permalink_url, @"track.permalink_url is nil");
        XCTAssertTrue(track.title, @"track.title is nil");
        XCTAssertTrue(track.user, @"track.user is nil");
        XCTAssertTrue(track.artwork_url, @"track.artwork_url is nil");
        XCTAssertNil(track.artworkImage, @"track.artworkImage is not nil");

        // Load images from SC
        [track loadImagesSynchronously];
        
        XCTAssertTrue(track.artworkImage, @"track.artworkImage is still nil");
    }
}

@end
