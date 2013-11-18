//
//  SCBubbleScene.m
//  Soundclouds
//
//  Created by Ole Krause-Sparmann on 16.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCBubbleScene.h"

#import "SCBackgroundBubbleNode.h"

@interface SCBubbleScene ()

// This flag indicates if the content has been created yet
@property (readwrite, nonatomic) BOOL contentCreated;

// Timer used for bubble emission
@property (readwrite, nonatomic) double bubbleEmissionTimer;

// Last frame time
@property (readwrite, nonatomic) double lastFrameTime;

// Creates scene contents
- (void)createSceneContents;

@end

@implementation SCBubbleScene

#pragma mark - Callbacks 

- (void)didMoveToView:(SKView *)view
{
    // We technically do not need this check here, because in this app the scene
    // is only added once. Still, as I took the code from the official Apple documentation
    // I whink it does not hurt here as a reminder that in generall, it might be a good idea
    // (when showing and hiding scenes in a game for example).
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
        self.bubbleEmissionTimer = -1.0;
        self.bubbleEmissionFrequency = 1.0;
        self.lastFrameTime = -1.0;
    }
}

#pragma mark - Content creation

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    // Add background node
    SKSpriteNode *bgNode = [[SKSpriteNode alloc] initWithImageNamed:@"bg.png"];
    bgNode.size = self.view.bounds.size;
    bgNode.position = CGPointMake(0.5*self.view.bounds.size.width, 0.5*self.view.bounds.size.height);
    [self addChild:bgNode];
}

#pragma mark - Simulation

- (void)update:(NSTimeInterval)currentTime
{
    // Make sure that animation time is independent of the app state (foreground, background)
    if (self.lastFrameTime<0.0) {
        self.lastFrameTime = currentTime;
        return;
    }
    
    // Compute time step
    double deltaTime = currentTime - self.lastFrameTime;
    
    // Avoid jumps (happen when the app enters the background and comes back)
    if (deltaTime>0.1) {
        deltaTime = 1.0/30.0;
    }
    
    // Keep last frame time
    self.lastFrameTime = currentTime;
    
    // Descrease step from emission timer
    self.bubbleEmissionTimer = self.bubbleEmissionTimer - deltaTime;
    
    // Emit if timer is done    
    if (self.bubbleEmissionTimer <= 0.0) {
        [self emitBackgroundBubble];
        [self emitBackgroundBubble];
        [self emitBackgroundBubble];
        self.bubbleEmissionTimer = 1.0/self.bubbleEmissionFrequency;
    }
    
    // Update status for each node
    for (SKNode *node in self.children) {
        if ([node isKindOfClass:[SCBackgroundBubbleNode class]]) {
            SCBackgroundBubbleNode *bubbleNode = (SCBackgroundBubbleNode*)node;

            // Reduce time to live
            bubbleNode.timeToLive -= deltaTime;
            
            // If the bubble's lifetime has passed
            if (bubbleNode.timeToLive <= 0.0) {
                // remove it
                [self removeChildrenInArray:@[bubbleNode]];
            }
            else {
                // Otherwise update the bubble's properties
                double f = 1.0-bubbleNode.timeToLive/bubbleNode.lifeTime;
                
                // Set height (y position)
                double height = self.view.bounds.size.height*f;
                
                // Update properties depending on height factor f
                bubbleNode.position = CGPointMake(bubbleNode.position.x, height);
                bubbleNode.size = CGSizeMake(3+f*2,3+f*2);
                bubbleNode.alpha = 0.2+f*0.5;
            }                        
        }
    }
}

#pragma mark - Bubble creation

- (void)emitBackgroundBubble
{
    // Create bubble using bubble image
    SCBackgroundBubbleNode *n = [[SCBackgroundBubbleNode alloc] initWithImageNamed:@"bg_bubble.png"];
    
    // Compute random start position
    double startX = randF()*self.view.bounds.size.width;
    double startY = 0.0;
    n.position = CGPointMake(startX, startY);
    
    // Use random lifetime. Lifetime implicity defines the bubble velocity
    n.lifeTime = 4.0 + 10.0*randF();
    n.timeToLive = n.lifeTime;
    
    // Add node as child to scene
    [self addChild:n];
}

#pragma mark - Setters

- (void)setBubbleEmissionFrequency:(double)bubbleEmissionFrequency
{
    _bubbleEmissionFrequency = bubbleEmissionFrequency;
}

@end
