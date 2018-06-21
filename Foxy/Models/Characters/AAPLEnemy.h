//
// AAPLEnemy.h
// Fox OS X (Objective-C)
//
// Created by matifraga on 10/6/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLCharacter.h"

@interface AAPLEnemy : AAPLCharacter

- (void)attackCharacter:(AAPLCharacter *)character;
+ (AAPLEnemy *)findEnemyWithNode:(SCNNode *)node;
+ (AAPLEnemy *)randomEnemyWithMaxLife:(CGFloat)maxLife andHitDamage:(CGFloat)damage at:(SCNVector3)position;

@end
