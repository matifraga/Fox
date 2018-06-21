//
// AAPLPowerUp.h
// Fox OS X (Objective-C)
//
// Created by matifraga on 10/6/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "AAPLCollisionMask.h"
#import "AAPLPlayer.h"

typedef void (^PowerUpProperty)(AAPLPlayer *);

@interface AAPLPowerUp : NSObject

typedef NS_OPTIONS(NSUInteger, AAPLPowerUpType) {
    AAPLRecovery         = 0,
    AAPLSpeed            = 1,
    AAPLShield           = 2,
    AAPLBerserk          = 3
};

@property (nonatomic, strong) SCNNode *node;

- (instancetype)initWithProperty:(PowerUpProperty)property;
- (void)applyPowerUpToPlayer:(AAPLPlayer *)player;
- (void)setItemColor:(NSColor *)color;
+ (AAPLPowerUp *)findPowerUpWithNode:(SCNNode *)node;
+ (AAPLPowerUp *)recoveryPowerUpWithLife:(CGFloat)life;
+ (AAPLPowerUp *)speedPowerUpWith:(CGFloat)speed forInterval:(NSTimeInterval)interval;
+ (AAPLPowerUp *)shieldPowerUpForInterval:(CGFloat)interval;
+ (AAPLPowerUp *)generateRandomPowerUp;

@end
