//
//  SCBackgroundBubbleNode.h
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 16.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// Bubbles in the background sprite kit scene are instances of this node class
@interface SCBackgroundBubbleNode : SKSpriteNode

// Time left
@property (readwrite, nonatomic) double timeToLive;

// The lifetime implicitly defines the bubble's velocity
@property (readwrite, nonatomic) double lifeTime;

@end
