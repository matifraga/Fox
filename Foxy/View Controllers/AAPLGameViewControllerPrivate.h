/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

 */

@import simd;
@import SceneKit;
@import GameController;

#import "AAPLGameViewController.h"
#import "AAPLPlayer.h"
#import "AAPLEnemy.h"
#import "AAPLPowerUp.h"
#import "AAPLWeapon.h"

@interface AAPLGameViewController ()
@property (nonatomic, strong) SCNNode *ground;
@property (nonatomic, strong) AAPLPlayer *player;
@property (nonatomic, strong) NSMutableArray <AAPLEnemy *> *enemies;
@property (nonatomic, strong) NSMutableArray <AAPLPowerUp *> *collectables;
@property (nonatomic, strong) NSMutableArray <AAPLWeapon *> *weapons;
@property (nonatomic) vector_float2 controllerDirection;
@property (nonatomic) BOOL holdingTrigger;
@property (nonatomic) CGFloat maxPenetrationDistance;
@property (nonatomic) BOOL replacementPositionIsValid;
@property (nonatomic, strong) NSMutableArray <AAPLCharacter *> *characterReplacement;
@property (nonatomic) CGFloat reachToFlee;
@property (nonatomic) NSUInteger numberOfWaves;
@end

@interface AAPLGameViewController (GameControls) <AAPLKeyboardEventDelegate>

- (void)setupGameControllers;

@property (nonatomic, readonly) vector_float2 controllerDirection;
@end
