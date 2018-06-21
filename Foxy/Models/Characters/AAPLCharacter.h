/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    This class manages the main character, including its animations and direction.
 */

@import Foundation;

#import <SceneKit/SceneKit.h>
#import "AAPLCollisionMask.h"
#import "AAPLWeapon.h"

@class AAPLCharacter;

@protocol AAPLCharacterDelegate

- (void)updateLife:(CGFloat)newLife toCharacter:(AAPLCharacter *)character;
- (void)becameInvulnerable;
- (void)becameVulnerable;
- (void)activeBerserkModeForReach:(CGFloat)reach;
- (void)changeWeaponTo:(NSString *)weaponName;

@end

@interface AAPLCharacter : NSObject

typedef NS_OPTIONS(NSUInteger, AAPLSteering) {
    AAPLNone        = 0,
    AAPLWander      = 1,
    AAPLSeek        = 2,
    AAPLFlee        = 3
};

@property (nonatomic, strong) SCNNode *node;
@property (nonatomic, strong) SCNScene *characterScene;
@property (nonatomic, strong) SCNScene *walkAnimationScene;
@property (nonatomic) CGFloat damage;
@property (nonatomic) CGFloat maxVelocity;
@property (nonatomic) CGFloat maxLife;
@property (nonatomic) CGFloat life;
@property (nonatomic) AAPLSteering steeringBehavour;
@property (nonatomic, strong) NSMutableArray <AAPLWeapon *> *weapons;
@property (nonatomic) NSUInteger mainWeapon;
@property (nonatomic) SCNVector3 replacementPosition;
@property (nonatomic) BOOL shouldReplace;
@property (nonatomic, weak) id <AAPLCharacterDelegate> delegate;

- (instancetype)initWithScene:(SCNScene *)scene andAnimation:(SCNScene *)animation andDamage:(CGFloat)damage
               andMaxVelocity:(CGFloat)velocity andMaxLife:(CGFloat)life andSteering:(AAPLSteering)steering withDefaultTarget:(AAPLCharacter *)target;
- (void)walkInDirection:(vector_float3)direction time:(NSTimeInterval)time scene:(SCNScene *)scene;
- (void)changeDirectionWithAngle:(CGFloat)angle;
- (void)takeLife:(CGFloat)life;
- (void)heal:(CGFloat)life;
- (void)speedMultiplier:(CGFloat)multiplier forInterval:(NSTimeInterval)interval;
- (void)makeInmortalFor:(NSTimeInterval)time;
- (void)applySteeringBehavourTo:(AAPLCharacter *)character withTime:(NSTimeInterval)time andReach:(CGFloat) reach;
- (void)applyReplacementPosition;
- (void)reset;

@end
