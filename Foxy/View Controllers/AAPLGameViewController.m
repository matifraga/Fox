/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    This class manages most of the game logic.
 */

@import SpriteKit;
@import QuartzCore;
@import AVFoundation;

#import <SceneKit/SceneKit.h>
#import "AAPLGameViewControllerPrivate.h"

@interface AAPLGameViewController () <AAPLCharacterDelegate>
@property (nonatomic) NSTimeInterval pastTime;
@end

@implementation AAPLGameViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.gameView.scene = [SCNScene sceneNamed:@"game.scnassets/level.scn"];
    self.gameView.playing = YES;
    self.gameView.loops = YES;

}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self setupScene];
}

- (void)setupScene
{
    [self cleanGame];
	[self setupCamera];
	[self setupGround];
	[self setupGameControllers];
	[self subscribe];
}

- (void)cleanGame
{
    [self removeElementsFromScreen];
    
    self.gameView.playing = YES;
    self.gameView.loops = YES;
    self.pastTime = 0.0f;

    [self.gameView resetGameView];
    [self initializeScreenElements];
}

- (void)removeElementsFromScreen
{
    [self.gameView.scene.rootNode enumerateChildNodesUsingBlock: ^(SCNNode *node, BOOL *stop) {
        [node removeFromParentNode];
    }];
}

- (void)playerDie
{
    self.gameView.playing = NO;
    [self removeElementsFromScreen];
    [self setupGround];
    [self.gameView setGameOverScreenVisible:YES];
}

- (void)subscribe
{
	self.gameView.scene.physicsWorld.contactDelegate = self;
	self.gameView.delegate = self;
}

- (void)initializeScreenElements
{
	self.maxPenetrationDistance = 0.0f;

    [self loadPlayer];

    //Reference all other non-player objects on the game
    self.collectables = [NSMutableArray new];
    [self loadPowerUps];
    
    self.enemies = [NSMutableArray new];
    self.gameView.wave = 0;
    [self nextWave];
    
    self.weapons = [NSMutableArray new];
    [self loadWeapons];
    
    self.characterReplacement = [NSMutableArray new];
}

- (void)loadPlayer
{
    self.player = [AAPLPlayer new];
    self.player.node.position = SCNVector3Make(1.0f, 0.0f, 1.0f);
    self.player.delegate = self;
    [self.gameView.scene.rootNode addChildNode:self.player.node];
}

- (void)loadPowerUps
{
    int amountOfPowerUps = 2;//arc4random_uniform(20) + 5;
    NSLog(@"amount of power ups = %d", amountOfPowerUps);
    
    for (int i = 0; i < amountOfPowerUps; i++) {
        AAPLPowerUp *powerUp = [AAPLPowerUp generateRandomPowerUp];
        powerUp.node.position = SCNVector3Make(arc4random_uniform(40) - 20.0f, 0.0f, arc4random_uniform(40) - 20.0f);
        [self.gameView.scene.rootNode addChildNode:powerUp.node];
        [self.collectables addObject:powerUp];
    }
}

- (void)nextWave
{
    // Wait for it!
    __weak typeof(self)weakSelf = self;
    
    id wait = [SCNAction waitForDuration:1.0f];
    id run = [SCNAction runBlock: ^(SCNNode *node) {
        weakSelf.gameView.wave ++;
        int numberOfEnemies = arc4random_uniform(5 * (int)weakSelf.gameView.wave) + 5;
        
        for (int i = 0; i < numberOfEnemies; i++) {
            AAPLEnemy *enemy = [AAPLEnemy randomEnemyWithMaxLife:(50.0f * ((int)weakSelf.gameView.wave + 1)) 
                                                    andHitDamage:(2.0f * ((int)weakSelf.gameView.wave + 1)) at:
                                SCNVector3Make(arc4random_uniform(40) - 20.0f, 0.0f, arc4random_uniform(40) - 20.0f)];
            enemy.delegate = weakSelf;
            [weakSelf.gameView.scene.rootNode addChildNode:enemy.node];
            
            [weakSelf.enemies addObject:enemy];
        }
    }];

    [self.gameView.scene.rootNode runAction:[SCNAction sequence:@[wait, run]]];
}

- (void)loadWeapons
{
    AAPLWeapon *granade = [AAPLWeapon generateGranade];
    [self.gameView.scene.rootNode addChildNode:granade.node];
    [self.weapons addObject:granade];
    
    AAPLWeapon *gun = [AAPLWeapon generateGun];
    [self.gameView.scene.rootNode addChildNode:gun.node];
    [self.weapons addObject:gun];
    
    AAPLWeapon *flamethrower = [AAPLWeapon generateFlamethrower];
    [self.gameView.scene.rootNode addChildNode:flamethrower.node];
    [self.weapons addObject:flamethrower];
}

- (void)setupCamera
{
	SCNNode *cameraNode = [SCNNode new];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(0.0f, 2.0f, -6.0f);
	cameraNode.rotation = SCNVector4Make(0.0f, 1.0f, 0.0f, M_PI);
    
    // Set the camera as a child of player's node to make the camera follow the player
	self.gameView.pointOfView = cameraNode;
	[self.player.node addChildNode:cameraNode];
}

- (void)setupGround
{
	//TODO: add walls and refactor to setup enviroment?
	SCNMaterial *groundMaterial = [SCNMaterial new];
	groundMaterial.diffuse.contents = [NSImage imageNamed:@"grass_normal"];
	groundMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(32, 32, 0);
	groundMaterial.diffuse.wrapS = SCNWrapModeRepeat;
	groundMaterial.diffuse.wrapT = SCNWrapModeRepeat;
	groundMaterial.specular.contents = [NSImage imageNamed:@"grass_specular"];
	groundMaterial.specular.contentsTransform = SCNMatrix4MakeScale(32, 32, 0);
	groundMaterial.specular.wrapS = SCNWrapModeRepeat;
	groundMaterial.specular.wrapT = SCNWrapModeRepeat;

	SCNFloor *floor = [SCNFloor floor];
	floor.reflectivity = 0.0f;
	floor.firstMaterial = groundMaterial;

	self.ground = [SCNNode nodeWithGeometry:floor];
    
    [self initializeGroundCollisionHandler];
	[self.gameView.scene.rootNode addChildNode:self.ground];
}

- (void)initializeGroundCollisionHandler
{
    SCNNode *collider = [SCNNode node];
    collider.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape
                             shapeWithGeometry:[SCNBox boxWithWidth:1000.0f height:1.0f length:1000.0f chamferRadius:0.0f] options:nil]];
    collider.physicsBody.allowsResting = YES;
    collider.physicsBody.friction = 10.0f;
    collider.position = SCNVector3Make(0.0f, -0.5f, 0.0f);
    
    [self.ground addChildNode:collider];
}

#pragma mark - SCNSceneRendererDelegate Conformance (Game Loop)

// SceneKit calls this method exactly once per frame, so long as the SCNView object (or other SCNSceneRenderer object) displaying the scene is not paused.
// Implement this method to add game logic to the rendering loop. Any changes you make to the scene graph during this method are immediately reflected in the displayed scene.

- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    //Skip first iteration (time = 0, we don't want to do anything here)
	if (!self.pastTime) {
		self.pastTime = time;
		return;
	}

    SCNVector3 from = [self.player.node convertPosition:SCNVector3Zero toNode:nil];
    SCNVector3 to = [self.player.node convertPosition:SCNVector3Make(0.0f, 0.0f, self.controllerDirection.y) toNode:nil];
    vector_float3 playerDirection = (vector_float3) {to.x - from.x, 0.0, to.z - from.z};
    
	//Reset frame state
	self.replacementPositionIsValid = NO;
	self.maxPenetrationDistance = 0;
    
	[self.player walkInDirection:playerDirection time:time - self.pastTime scene:self.gameView.scene];
	[self.player changeDirectionWithAngle:self.controllerDirection.x];

    for (AAPLEnemy *enemy in self.enemies) {
        CGFloat steeringReach = 1.0f;
        if (enemy.steeringBehavour == AAPLFlee) {
            steeringReach = _reachToFlee;
        }
        
		[enemy applySteeringBehavourTo:_player withTime:time andReach:steeringReach];
	}
    
    if (self.holdingTrigger && self.player.weapons.count != 0) {
        [self.player attackAtLevel:self.gameView.scene andAgainstEnemies:[self.enemies copy]];
        self.holdingTrigger = NO;
    }

	self.pastTime = time;
}

#pragma mark - Game view

- (AAPLGameView *)gameView
{
	return (AAPLGameView *)self.view;
}

#pragma mark - Update Character status on the screen

- (void)updateLife:(CGFloat)newLife toCharacter:(AAPLCharacter *)character
{
    if (character == self.player) {
        if (newLife) {
            [self.gameView setLife:newLife / character.maxLife];
        } else {
            [self playerDie];
        }
    } else {
        if (newLife) {
            // Still alive but hurt!
            [self.gameView hurtEnemy:[self.collectables objectAtIndex:0].node];
        } else {
            // Kill the enemy!
            [character.node removeFromParentNode];
            [self.enemies removeObject:(AAPLEnemy*)character];
            
            // Rockstar! Next wave coming!
            if (self.enemies.count == 0) {
                [self nextWave];
            }
        }
    }
}

- (void)becameInvulnerable
{
    [self.gameView setInmortal:YES];
}

- (void)becameVulnerable
{
    [self.gameView setInmortal:NO];
}

- (void)activeBerserkModeForReach:(CGFloat)reach
{
    for (AAPLEnemy *enemy in self.enemies) {
        enemy.steeringBehavour = AAPLFlee;
        self.reachToFlee = reach;
        [enemy applySteeringBehavourTo:_player withTime:0.0f andReach:reach];
    }
}

- (void)changeWeaponTo:(NSString *)weaponName {
    [self.gameView setWeapon:weaponName];
}

- (void)activeWeaponNumber:(NSUInteger)number
{
    self.player.mainWeapon = number;
}

#pragma mark - SCNPhysicsContactDelegate Conformance

- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact
{
    if (contact.nodeB.physicsBody.categoryBitMask == AAPLBitmaskCollectable) {
        AAPLPowerUp *powerUp = [AAPLPowerUp findPowerUpWithNode:contact.nodeB];
        [powerUp applyPowerUpToPlayer:self.player];
        [powerUp.node removeFromParentNode];
        [self.collectables removeObject:powerUp];
    } else if (contact.nodeB.physicsBody.categoryBitMask == AAPLBitmaskWeapon) {
        AAPLWeapon *weapon = [AAPLWeapon findWeaponWithNode:contact.nodeB];
        [self.player.weapons addObject:weapon];
        [weapon.node removeFromParentNode];
        [self.weapons removeObject:weapon];
    }
}

- (void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact
{
    if (contact.nodeB.physicsBody.categoryBitMask == AAPLBitmaskEnemy) {
        if (contact.nodeA.physicsBody.categoryBitMask == AAPLBitmaskPlayer) {
            [[AAPLEnemy findEnemyWithNode:contact.nodeB] attackCharacter:self.player];
        }
        
        [self characterNode:contact.nodeA withContact:contact];
    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didSimulatePhysicsAtTime:(NSTimeInterval)time
{
    if (self.replacementPositionIsValid) {
        for (AAPLCharacter *character in self.characterReplacement) {
            [character applyReplacementPosition];
        }
        
        [self.characterReplacement removeAllObjects];
    }
}

- (void)characterNode:(SCNNode *)characterNode withContact:(SCNPhysicsContact *)contact
{
    if (self.maxPenetrationDistance > contact.penetrationDistance) {
        return;
    }
    
    AAPLCharacter *character = [AAPLEnemy findEnemyWithNode:contact.nodeA];
    if (!character) { // If no enemy is related to nodeA, then the player is the one colliding
        character = self.player;
    }
    
    self.maxPenetrationDistance = contact.penetrationDistance;
    
    vector_float3 characterPosition = SCNVector3ToFloat3(character.node.position);
    vector_float3 positionOffset = SCNVector3ToFloat3(contact.contactNormal) * contact.penetrationDistance;
    positionOffset.y = 0;
    characterPosition += positionOffset;
    
    character.replacementPosition = SCNVector3FromFloat3(characterPosition);
    character.shouldReplace = YES;
    [self.characterReplacement addObject:character];
    self.replacementPositionIsValid = YES;
}

@end
