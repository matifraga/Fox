//
// AAPLEnemy.m
// Fox OS X (Objective-C)
//
// Created by matifraga on 10/6/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLEnemy.h"
#import "AAPLNodeManager.h"

@implementation AAPLEnemy

- (instancetype)initWithScene:(SCNScene *)scene andAnimation:(SCNScene *)animation andDamage:(CGFloat)damage
               andMaxVelocity:(CGFloat)velocity andMaxLife:(CGFloat)life andSteering:(AAPLSteering)steering withDefaultTarget:(AAPLCharacter *)target
{
    self = [super initWithScene:scene andAnimation:animation andDamage:damage andMaxVelocity:velocity andMaxLife:life andSteering:
            //arc4random_uniform(4) withDefaultTarget:target];
            AAPLSeek withDefaultTarget:target];
	if (self) {
		[self setupCollisions];
	}
	return self;
}

- (void)setupCollisions
{
	SCNVector3 min, max;
	[self.node getBoundingBoxMin:&min max:&max];
	CGFloat collisionCapsuleRadius = (max.x - min.x) * 0.4;
	CGFloat collisionCapsuleHeight = (max.y - min.y);

	SCNNode *collisionNode = [SCNNode node];
	collisionNode.name = @"enemy_collider";
	collisionNode.position = SCNVector3Make(0.0, collisionCapsuleHeight * 0.5, 0.0);
	collisionNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic
	                                                   shape:[SCNPhysicsShape shapeWithGeometry:
	                                                          [SCNCapsule capsuleWithCapRadius:collisionCapsuleRadius
	                                                                                    height:collisionCapsuleHeight]
	                                                                                    options:nil]];
	[self.node addChildNode:collisionNode];
    collisionNode.physicsBody.contactTestBitMask = AAPLBitmaskEnemy;
	collisionNode.physicsBody.categoryBitMask = AAPLBitmaskEnemy;

	collisionNode.physicsBody.mass = 1.0f;
	collisionNode.physicsBody.restitution = 0.2f;

	[[AAPLNodeManager sharedManager] associateNode:collisionNode withModel:self];
	[[AAPLNodeManager sharedManager] associateNode:self.node withModel:self];
}

- (void)attackCharacter:(AAPLCharacter *)character
{
	[character takeLife:self.damage];
}

+ (AAPLEnemy *)findEnemyWithNode:(SCNNode *)node
{
	NSObject *model = [[AAPLNodeManager sharedManager] modelForAssociatedNode:node];

	if ([model isKindOfClass:[AAPLEnemy class]]) {
		return (AAPLEnemy *)model;
	}

	return nil;
}

+ (AAPLEnemy *)randomEnemyWithMaxLife:(CGFloat)maxLife andHitDamage:(CGFloat)damage at:(SCNVector3)position
{
    NSUInteger steering = AAPLSeek;
    AAPLEnemy *target = nil;
    
    if (steering == 2) {
        target = [[AAPLEnemy alloc] initWithScene:nil andAnimation:nil andDamage:0.0f andMaxVelocity:0.0f andMaxLife:0.0f
                                      andSteering: 0 withDefaultTarget:nil];
        target.node.position = SCNVector3Make(position.x + 10.0f, 0.0f, position.z);
        target.node.scale = SCNVector3Make(0.65f, 0.65f, 0.65f);
    }
    
    AAPLEnemy *enemy = [[AAPLEnemy alloc] initWithScene:[SCNScene sceneNamed:@"game.scnassets/mummy.dae"]
                                          andAnimation:[SCNScene sceneNamed:@"game.scnassets/mummy_walk.dae"]
                                          andDamage:damage andMaxVelocity:1.5f andMaxLife:maxLife
                                          andSteering: steering withDefaultTarget:target];
    enemy.node.position = position;
    enemy.node.scale = SCNVector3Make(0.65f, 0.65f, 0.65f);
    return enemy;
}

@end
