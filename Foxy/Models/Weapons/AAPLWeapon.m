//
//  AAPLWeapon.m
//  Fox OS X (Objective-C)
//
//  Created by matias fraga on 10/6/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLNodeManager.h"
#import "AAPLWeapon.h"
#import "AAPLEnemy.h"

@implementation AAPLWeapon

- (instancetype)initWithName:(NSString *)name andDamage:(CGFloat)damage andType:(AAPLWeaponTypes)type
{
    self = [super init];
    if (self) {
        self.weaponName = name;
        self.damage = damage;
        self.type = type;
        
        SCNScene *scene = [SCNScene sceneNamed:@"game.scnassets/flower.scn"];
        [self setUpNodeWithScene:scene];
        
        self.node.position = SCNVector3Make(arc4random_uniform(60) - 30.0f, 0.0f, arc4random_uniform(60) - 30.0f);
    }
    return self;
}

- (void)setUpNodeWithScene:(SCNScene *)scene
{
    self.node = [SCNNode node];
    
    SCNScene *characterScene = scene;
    SCNNode *characterTopLevelNode = characterScene.rootNode.childNodes[0];
    
    characterTopLevelNode.physicsBody = [SCNPhysicsBody staticBody];
    characterTopLevelNode.physicsBody.categoryBitMask = AAPLBitmaskWeapon;
    
    [self.node addChildNode:characterTopLevelNode];
    
    // This works as a global game table to asociate game elements with theirs view nodes
    [[AAPLNodeManager sharedManager] associateNode:self.node withModel:self];
    [[AAPLNodeManager sharedManager] associateNode:characterTopLevelNode withModel:self];
}

- (void)attackFromPosition:(SCNVector3)position withAngle:(CGFloat)angle andPlayerScene:(SCNScene *)scene andEnemiesInScene:(NSArray <AAPLEnemy *> *)enemies
{
    //self.type = AAPLFlamethrower;
    
    switch (self.type) {
        case AAPLGun: {
            [self gunAttackFromPosition:position withAngle:angle andPlayerScene:scene];
            break;
        }
            
        case AAPLGranade: {
            [self granadeAttackFromPosition:SCNVector3Make(position.x, position.y + 1.0f, position.z) withAngle:angle andPlayerScene:scene andEnemiesInScene:enemies];
            break;
        }
            
        case AAPLFlamethrower: {
            //[self flameFromPosition:SCNVector3Make(position.x, position.y + 1.0f, position.z) withAngle:angle andPlayerScene:scene andEnemiesInScene:enemies];
            break;
        }
    }
}

- (void)gunAttackFromPosition:(SCNVector3)position withAngle:(CGFloat)angle andPlayerScene:(SCNScene *)scene
{
    // Bullets represented as raycasts
    NSArray<SCNHitTestResult *> *results = [scene.physicsWorld rayTestWithSegmentFromPoint:position toPoint: SCNVector3Make(position.x + 20 * sin(angle), 0.0f, position.z + 20 * cos(angle)) options:@{SCNPhysicsTestSearchModeKey : SCNPhysicsTestSearchModeClosest, SCNPhysicsTestCollisionBitMaskKey : @(AAPLBitmaskEnemy)}];
    
    for (SCNHitTestResult *result in results) {
        AAPLEnemy *enemy = [AAPLEnemy findEnemyWithNode:result.node];
        [enemy takeLife:self.damage];
        NSLog(@"Enemy suffer: %g damage, remaining life: %g", self.damage, enemy.life);
    }
}

- (void)granadeAttackFromPosition:(SCNVector3)position withAngle:(CGFloat)angle andPlayerScene:(SCNScene *)scene andEnemiesInScene:(NSArray <AAPLEnemy *> *)enemies
{
    // Granade represented as a physics body
    SCNScene* s = [SCNScene sceneNamed:@"game.scnassets/granade.dae"];
    SCNNode* node = [SCNNode node];
    for (SCNNode* n in s.rootNode.childNodes) {
        [node addChildNode:n];
    }
    
    node.position = position;
    node.scale = SCNVector3Make(1.0f, 1.0f, 1.0f);
    
    node.physicsBody = [self generateGranadePhysicsBody];
    [node.physicsBody applyForce:SCNVector3Make(4.0f * sin(angle), 7.0f, 4.0f * cos(angle)) impulse:YES];
    
    [scene.rootNode addChildNode:node];
    
    __weak typeof(self)weakSelf = self;
    
    id wait = [SCNAction waitForDuration:2.0f];
    id run = [SCNAction runBlock: ^(SCNNode *n) {
        [node removeFromParentNode];
        int count = 0;
        for (AAPLEnemy *enemy in enemies) {
            if ([weakSelf enemy:enemy withInReach: node.position]) {
                [enemy takeLife:weakSelf.damage];
                count++;
            }
        }
        NSLog(@"%d enemies took damage", count);
    }];
    
    [scene.rootNode runAction:[SCNAction sequence:@[wait, run]]];
}

- (BOOL)enemy:(AAPLEnemy *)enemy withInReach:(SCNVector3)reach
{
    NSLog(@"condition %g",(pow(reach.x - enemy.node.position.x, 2) + pow(reach.z - enemy.node.position.z, 2)));
    return (pow(reach.x - enemy.node.position.x, 2) + pow(reach.z - enemy.node.position.z, 2)) < 90.0f;
}

- (SCNPhysicsBody *)generateGranadePhysicsBody
{
    SCNPhysicsBody *body = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                              shape:[SCNPhysicsShape shapeWithGeometry:[SCNSphere sphereWithRadius:0.05f] options:nil]];
    body.mass = 1.0f;
    body.affectedByGravity = YES;
    body.allowsResting = YES;
    body.angularDamping = 1.0f;
    body.friction = 1.0f;
    
    return body;
}

- (void)flameFromPosition:(SCNVector3)position withAngle:(CGFloat)angle andPlayerScene:(SCNScene *)scene andEnemiesInScene:(NSArray <AAPLEnemy *> *)enemies
{
    // Flamethrower represented as a physics body with a particle system
    SCNNode* node = [SCNNode node];
    
    node.position = position;
    node.scale = SCNVector3Make(1.0f, 1.0f, 1.0f);
    node.eulerAngles = SCNVector3Make(M_PI_2, 0.0f, 0.0f);
    
    SCNParticleSystem* particle = [SCNParticleSystem particleSystemNamed:@"confetti.scnp" inDirectory:nil];
    [node addParticleSystem:particle];
    
    node.physicsBody = [self generateParticlePhysicsBody];
    [node.physicsBody applyForce:SCNVector3Make(20.0f * sin(angle), 1.0f, 20.0f * cos(angle)) impulse:YES];
    
    [scene.rootNode addChildNode:node];
    
    __weak typeof(self)weakSelf = self;
    
    id wait = [SCNAction waitForDuration:2.5f];
    id run = [SCNAction runBlock: ^(SCNNode *n) {
        [node removeFromParentNode];
        int count = 0;
        for (AAPLEnemy *enemy in enemies) {
            if ([weakSelf enemy:enemy withInReach: node.position]) {
                [enemy takeLife:weakSelf.damage];
                count++;
            }
        }
        NSLog(@"%d enemies took damage", count);
    }];
    
    [scene.rootNode runAction:[SCNAction sequence:@[wait, run]]];
}

- (SCNPhysicsBody *)generateParticlePhysicsBody
{
    return [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:
                                                         [SCNCone coneWithTopRadius:0.0f bottomRadius:0.75f height:0.5f] options:nil]];
}

+ (AAPLWeapon *)findWeaponWithNode:(SCNNode *)node
{
    NSObject *model = [[AAPLNodeManager sharedManager] modelForAssociatedNode:node];
    
    if ([model isKindOfClass:[AAPLWeapon class]]) {
        return (AAPLWeapon *)model;
    }
    
    return nil;
}

+ (AAPLWeapon *)generateGranade
{
    return [[AAPLWeapon alloc] initWithName:@"Granade" andDamage:55.0f andType:AAPLGranade];
}

+ (AAPLWeapon *)generateGun
{
    return [[AAPLWeapon alloc] initWithName:@"Gun" andDamage:20.0f andType:AAPLGun];
}

+ (AAPLWeapon *)generateFlamethrower
{
    return [[AAPLWeapon alloc] initWithName:@"Flamethrower" andDamage:1.0f andType:AAPLFlamethrower];
}

- (NSString *)description
{
    return self.weaponName;
}
@end
