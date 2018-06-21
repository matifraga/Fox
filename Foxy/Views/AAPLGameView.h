/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    The view displaying the game scene, including the 2D overlay.
 */

@import simd;
@import SceneKit;
@import SpriteKit;

@protocol AAPLKeyboardEventDelegate <NSObject>
@required
- (BOOL)keyDown:(NSView *)view event:(NSEvent *)event;
- (BOOL)keyUp:(NSView *)view event:(NSEvent *)event;
@end

@interface AAPLGameView : SCNView

@property (nonatomic) CGFloat life;
@property (nonatomic) NSUInteger wave;
@property (nonatomic) BOOL inmortal;
@property (nonatomic) NSString *weapon;
@property (nonatomic, weak) id <AAPLKeyboardEventDelegate> eventsDelegate;
@property (nonatomic, strong) SKSpriteNode *dimensions;

- (void)hurtEnemy:(SCNNode *)enemyNode;
- (void)resetGameView;
- (void)setGameOverScreenVisible:(BOOL)visible;

@end
