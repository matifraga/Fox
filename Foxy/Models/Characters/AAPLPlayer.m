//
// AAPLPlayer.m
// Fox OS X (Objective-C)
//
// Created by matifraga on 10/6/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLPlayer.h"
#import "AAPLNodeManager.h"

@implementation AAPLPlayer

- (instancetype)init
{
    self = [super initWithScene:[SCNScene sceneNamed:@"game.scnassets/panda.scn"]
                  andAnimation:[SCNScene sceneNamed:@"game.scnassets/walk.scn"] andDamage:0.0f andMaxVelocity:2.5f
                  andMaxLife:100.0f andSteering:AAPLNone withDefaultTarget:nil];
	if (self) {
		[self setupCollisions];
	}
	return self;
}

- (void)setupCollisions
{
    SCNVector3 min;
    SCNVector3 max;
	[self.node getBoundingBoxMin:&min max:&max];
    
	CGFloat collisionCapsuleRadius = (max.x - min.x) * 0.4;
	CGFloat collisionCapsuleHeight = (max.y - min.y);

	SCNNode *collisionNode = [SCNNode node];
	collisionNode.name = @"player_collider";
	collisionNode.position = SCNVector3Make(0.0, collisionCapsuleHeight * 0.50, 0.0);
	collisionNode.physicsBody = [SCNPhysicsBody
                                 bodyWithType:SCNPhysicsBodyTypeKinematic
                                 shape:[SCNPhysicsShape shapeWithGeometry:
                                              [SCNCapsule
                                               capsuleWithCapRadius:collisionCapsuleRadius
                                               height:collisionCapsuleHeight]
                                               options:nil]];
    
    collisionNode.physicsBody.categoryBitMask = AAPLBitmaskPlayer;
	collisionNode.physicsBody.collisionBitMask = AAPLBitmaskCollectable | AAPLBitmaskEnemy | AAPLBitmaskWeapon;
	collisionNode.physicsBody.contactTestBitMask = AAPLBitmaskCollectable | AAPLBitmaskEnemy | AAPLBitmaskWeapon;

	collisionNode.physicsBody.mass = 1.0f;
	collisionNode.physicsBody.restitution = 0.0f;

	[self.node addChildNode:collisionNode];

	[[AAPLNodeManager sharedManager] associateNode:collisionNode withModel:self];
	[[AAPLNodeManager sharedManager] associateNode:self.node withModel:self];
}

- (void)reset
{
    [super reset];
    self.node.position = SCNVector3Make(1.0f, 0.0f, 1.0f);
    self.life = 100;
    self.replacementPosition = self.node.position;
    self.shouldReplace = NO;
}

- (void)attackAtLevel:(SCNScene *)scene andAgainstEnemies:(NSArray <AAPLEnemy *> *)enemies
{
    [[self.weapons objectAtIndex:self.mainWeapon] attackFromPosition:self.node.position withAngle:self.node.eulerAngles.y andPlayerScene:scene andEnemiesInScene:enemies];
}

+ (AAPLPlayer *)playerForNode:(SCNNode *)node
{
	NSObject *model = [[AAPLNodeManager sharedManager] modelForAssociatedNode:node];

	if ([model isKindOfClass:[AAPLPlayer class]]) {
		return (AAPLPlayer *)model;
	}

	return nil;
}

@end
