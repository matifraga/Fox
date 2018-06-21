//
// AAPLPowerUp.m
// Fox OS X (Objective-C)
//
// Created by matifraga on 10/6/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLPowerUp.h"
#import "AAPLNodeManager.h"

@interface AAPLPowerUp ()
@property (nonatomic) PowerUpProperty property;
@end

@implementation AAPLPowerUp

- (instancetype)initWithProperty:(PowerUpProperty)property
{
	self = [self init];
	if (self) {
		self.property = property;
	}
	return self;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		SCNScene *scene = [SCNScene sceneNamed:@"game.scnassets/pearl.scn"];
		[self setUpNodeWithScene:scene];
	}

	return self;
}

- (void)setUpNodeWithScene:(SCNScene *)scene
{
	self.node = [SCNNode node];

	SCNScene *characterScene = scene;
	SCNNode *characterTopLevelNode = characterScene.rootNode.childNodes[0];

	characterTopLevelNode.physicsBody = [SCNPhysicsBody staticBody];
	characterTopLevelNode.physicsBody.categoryBitMask = AAPLBitmaskCollectable;

	[self.node addChildNode:characterTopLevelNode];

    //This works as a global game table to asociate game elements with theirs view nodes
	[[AAPLNodeManager sharedManager] associateNode:self.node withModel:self];
	[[AAPLNodeManager sharedManager] associateNode:characterTopLevelNode withModel:self];
}

- (void)applyPowerUpToPlayer:(AAPLPlayer *)player
{
	self.property(player);
}

- (void)setItemColor:(NSColor *)color
{
	SCNNode *pearl = self.node.childNodes[0];
	pearl.geometry.firstMaterial.diffuse.contents = color;
}

+ (AAPLPowerUp *)findPowerUpWithNode:(SCNNode *)node
{
	NSObject *model = [[AAPLNodeManager sharedManager] modelForAssociatedNode:node];

	if ([model isKindOfClass:[AAPLPowerUp class]]) {
		return (AAPLPowerUp *)model;
	}

	return nil;
}

+ (AAPLPowerUp *)recoveryPowerUpWithLife:(CGFloat)life
{
    AAPLPowerUp *powerUp = [[AAPLPowerUp alloc] initWithProperty: ^(AAPLPlayer *player) {
        [player heal:life];
    }];
    
    [powerUp setItemColor:[NSColor greenColor]];
    
    return powerUp;
}

+ (AAPLPowerUp *)speedPowerUpWith:(CGFloat)speed forInterval:(NSTimeInterval)interval
{
    AAPLPowerUp *powerUp = [[AAPLPowerUp alloc] initWithProperty: ^(AAPLPlayer *player) {
        [player speedMultiplier:speed forInterval:interval];
    }];
    
    [powerUp setItemColor:[NSColor yellowColor]];
    
    return powerUp;
}

+ (AAPLPowerUp *)shieldPowerUpForInterval:(CGFloat)interval
{
    AAPLPowerUp *powerUp = [[AAPLPowerUp alloc] initWithProperty: ^(AAPLPlayer *player) {
        [player makeInmortalFor:interval];
    }];
    
    [powerUp setItemColor:[NSColor blueColor]];
    
    return powerUp;
}

+ (AAPLPowerUp *)berserkModeForReach:(CGFloat)reach
{
    AAPLPowerUp *powerUp = [[AAPLPowerUp alloc] initWithProperty: ^(AAPLPlayer *player) {
        [player.delegate activeBerserkModeForReach:reach];
    }];
    
    [powerUp setItemColor:[NSColor redColor]];
    
    return powerUp;
}

+ (AAPLPowerUp *)generateRandomPowerUp
{
    AAPLPowerUpType randomTypeOfPowerUp = arc4random_uniform(4);
    NSLog(@"Random power up of type %lu", randomTypeOfPowerUp);
    switch (randomTypeOfPowerUp) {
        case AAPLSpeed: {
            return [AAPLPowerUp speedPowerUpWith:(arc4random_uniform(4)) forInterval:(arc4random_uniform(3) + 3)];
        }
            
        case AAPLShield: {
            return [AAPLPowerUp shieldPowerUpForInterval:(arc4random_uniform(4) + 4)];
        }
            
        case AAPLRecovery: {
            return [AAPLPowerUp recoveryPowerUpWithLife:(arc4random_uniform(30) + 10)];
        }
            
        case AAPLBerserk: {
            return [AAPLPowerUp berserkModeForReach:(arc4random_uniform(8) + 10)];
        }
    }
    
    return nil;
}

@end
