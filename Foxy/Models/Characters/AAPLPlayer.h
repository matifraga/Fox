//
// AAPLPlayer.h
// Fox OS X (Objective-C)
//
// Created by matifraga on 10/6/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLCharacter.h"
#import "AAPLEnemy.h"

@interface AAPLPlayer : AAPLCharacter

- (void)attackAtLevel:(SCNScene *)scene andAgainstEnemies:(NSArray <AAPLEnemy *> *)enemies;
- (void)reset;
+ (AAPLPlayer *)playerForNode:(SCNNode *)node;

@end
