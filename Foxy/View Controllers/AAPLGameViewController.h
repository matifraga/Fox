/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    This class manages most of the game logic.
 */

@import SceneKit;

#import "AAPLGameView.h"
#import "AAPLCollisionMask.h"

@interface AAPLGameViewController : NSViewController <SCNSceneRendererDelegate, SCNPhysicsContactDelegate>

@property (nonatomic, readonly) AAPLGameView *gameView;

- (void)activeWeaponNumber:(NSUInteger)number;
- (void)setupScene;

@end