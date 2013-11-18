//
//  SCBubbleScene.h
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 16.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// This sprite kit scene is in the background of the application, showing little bubbles going up
@interface SCBubbleScene : SKScene

// Frequency for bubble emission (in Hz), each time three bubbles are emitted
@property (readwrite, nonatomic) double bubbleEmissionFrequency;

// Emits one background bubble
- (void)emitBackgroundBubble;

@end
