/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    This class manages the main character, including its animations, sounds and direction.
 */

@import SceneKit;

#import "AAPLCharacter.h"
#import "SCNScene+LoadAnimation.h"

@interface AAPLCharacter ()

@property (nonatomic, strong) CAAnimation *walkAnimation;
@property (nonatomic) NSTimeInterval previousUpdateTime;
@property (nonatomic) CGFloat walkSpeed;
@property (nonatomic) BOOL isWalking;
@property (nonatomic) vector_float3 velocity;
@property (nonatomic) BOOL inmortal;
@property (nonatomic, strong) AAPLCharacter *randomTarget;

@end

@implementation AAPLCharacter

#pragma mark - Initialization

- (instancetype)initWithScene:(SCNScene *)scene andAnimation:(SCNScene *)animation andDamage:(CGFloat)damage
               andMaxVelocity:(CGFloat)velocity andMaxLife:(CGFloat)life andSteering:(AAPLSteering)steering withDefaultTarget:(AAPLCharacter *)target
{
	self = [super init];
	if (self) {
		self.maxLife = life;
		self.life = life;
		self.walkSpeed = velocity;
		_damage = damage;
		self.velocity = (vector_float3) {0.0f, 0.0f, 0.0f};
        self.steeringBehavour = steering;
        self.randomTarget = target;
        self.weapons = [NSMutableArray new];
        
		[self setUpScene:scene];
        [self setupWalkAnimationWithScene:animation];
	}
	return self;
}

- (void)reset
{
    self.isWalking = NO;
    self.inmortal = NO;
}

- (void)setUpScene:(SCNScene *)scene
{
    SCNMaterial *firstMaterial = [SCNMaterial new];
    firstMaterial.diffuse.contents = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:0];
    
    SCNGeometry *geometry = [SCNGeometry geometry];
    geometry.firstMaterial = firstMaterial;
    
	self.node = [SCNNode nodeWithGeometry:geometry];
	SCNScene *characterScene = scene;
	SCNNode *characterTopLevelNode = characterScene.rootNode.childNodes[0];
	[self.node addChildNode:characterTopLevelNode];
}

#pragma mark - Handle character movements

- (void)changeDirectionWithAngle:(CGFloat)angle
{
	[self.node runAction:[SCNAction rotateByX:0.0f y:(angle * M_PI / 80) z:0.0f duration:0.1f]];
}

- (void)walkInDirection:(vector_float3)direction time:(NSTimeInterval)time scene:(SCNScene *)scene
{
	NSTimeInterval deltaTime = MIN(time, 1.0 / 60.0);
	CGFloat characterSpeed = deltaTime * self.walkSpeed;

	if (direction.x != 0.0 || direction.z != 0.0) {
		vector_float3 position = SCNVector3ToFloat3(self.node.position);
		self.node.position = SCNVector3FromFloat3(position + direction * characterSpeed);
		self.walking = YES;
	} else {
		self.walking = NO;
	}
}

- (void)setWalking:(BOOL)walking
{
    if (self.isWalking != walking) {
        self.isWalking = walking;
        
        // Update node animation.
        if (self.isWalking) {
            [self.node addAnimation:self.walkAnimation forKey:@"walk"];
        } else {
            [self.node removeAnimationForKey:@"walk" fadeOutDuration:0.2];
        }
    }
}

- (void)setWalkSpeed:(CGFloat)walkSpeed
{
    _walkSpeed = walkSpeed;
    
    BOOL wasWalking = self.isWalking;
    
    if (wasWalking) {
        self.walking = NO;
    }
    
    //Setter call
    self.walkAnimation.speed = self.walkSpeed;
    
    if (wasWalking) {
        self.walking = YES;
    }
}

#pragma mark - Steering behavours

- (void)applySteeringBehavourTo:(AAPLCharacter *)character withTime:(NSTimeInterval)time andReach:(CGFloat) reach
{
    switch(self.steeringBehavour) {
            
        case AAPLNone: {
            //Nothing to be done here.
            return;
        }
            
        case AAPLSeek: {
            [self seek:character withTime:time];
            return;
        }
            
        case AAPLWander: {
            [self wanderUntil:character getsOnReach:reach withTime:time];
            return;
        }
            
        case AAPLFlee: {
            [self flee:character withReach:reach andTime:time];
            return;
        }
    }
}

- (void)seek:(AAPLCharacter *)character withTime:(NSTimeInterval)time
{
	NSTimeInterval deltaTime = MIN(time, 1.0 / 60.0);

	vector_float3 target = SCNVector3ToFloat3(character.node.position);
	vector_float3 position = SCNVector3ToFloat3(self.node.position);

	CGFloat distance = vector_distance(target, position);

	vector_float3 desiredVelocity = vector_normalize(target - position) * self.walkSpeed * deltaTime;

	if (distance <= 1) {
		desiredVelocity *= distance;
	}

	vector_float3 steering = desiredVelocity - self.velocity;

	self.velocity = self.velocity + steering;

	self.node.position = SCNVector3Make(position.x + self.velocity.x, position.y + self.velocity.y, position.z + self.velocity.z);

	CGFloat angle = atan2(self.velocity.x, self.velocity.z);

	[self.node runAction:[SCNAction rotateToX:0.0f y:angle z:0.0f duration:0.1f]];
}

// TODO: fix me
- (void)wanderUntil:(AAPLCharacter *)character getsOnReach:(CGFloat) reach withTime:(NSTimeInterval)time
{
    // Once the player gets on reach, enemies will always follow him.
    if (vector_distance(SCNVector3ToFloat3(character.node.position), SCNVector3ToFloat3(self.node.position)) <= reach) {
        self.steeringBehavour = AAPLSeek;
        return [self seek:character withTime:time];
    }
    
    if((arc4random_uniform(10) < 4)) {
        [self seek:[self generateRandomWanderPointWithReach:reach] withTime:time];
    }
}

- (AAPLCharacter *)generateRandomWanderPointWithReach:(CGFloat) reach
{
    if (!self.randomTarget) {
        CGFloat rand = (arc4random_uniform(11)) / 100.0f;
        if (arc4random_uniform(2)) {
            rand = -rand;
        }
        
        vector_float3 position = SCNVector3ToFloat3(self.node.position);
        vector_float3 direction = position - SCNVector3ToFloat3(self.randomTarget.node.position);
        self.randomTarget.node.position = SCNVector3FromFloat3(position + direction * self.walkSpeed);
        self.randomTarget.node.position = SCNVector3FromFloat3((vector_float3){self.randomTarget.node.position.x * (1 + rand),self.randomTarget.node.position.y, self.randomTarget.node.position.z * (1 + rand)});
        return self.randomTarget;
    }
    
    return nil;
}

- (void)flee:(AAPLCharacter *)character withReach:(CGFloat)reach andTime:(NSTimeInterval)time
{
    vector_float3 target = SCNVector3ToFloat3(character.node.position);
    vector_float3 position = SCNVector3ToFloat3(self.node.position);
    
    CGFloat distance = vector_distance(target, position);
    
    if (distance > reach) {
        self.steeringBehavour = AAPLSeek;
        [self seek:character withTime:time];
        return;
    }
    
    NSTimeInterval deltaTime = MIN(time > 1.0f/60.0f ? time : 1.0/60.0, 1.0 / 60.0);
    
    vector_float3 desiredVelocity = vector_normalize(position - target) * self.walkSpeed * deltaTime;
    
    if (distance <= 1) {
        desiredVelocity *= distance;
    }
    
    vector_float3 steering = desiredVelocity - self.velocity;
    
    self.velocity = self.velocity + steering;
    
    self.node.position = SCNVector3Make(position.x + self.velocity.x, position.y + self.velocity.y, position.z + self.velocity.z);
    
    CGFloat angle = atan2(self.velocity.x, self.velocity.z);
    
    [self.node runAction:[SCNAction rotateToX:0.0f y:angle z:0.0f duration:0.1f]];
}

#pragma mark - Weapon manager

- (void)setMainWeapon:(NSUInteger)mainWeapon
{
    if (self.weapons.count > mainWeapon) {
        _mainWeapon = mainWeapon;
        [self.delegate changeWeaponTo:[[self.weapons objectAtIndex:mainWeapon] description]];
    }
}

#pragma mark - Animating the character

- (void)setupWalkAnimationWithScene:(SCNScene *)scene
{
	self.walkAnimation = [scene loadAnimation];
	self.walkAnimation.usesSceneTimeBase = NO;
	self.walkAnimation.fadeInDuration = 0.3;
	self.walkAnimation.fadeOutDuration = 0.3;
	self.walkAnimation.repeatCount = FLT_MAX;
    
    [self loadEmbeddedAnimations];
}

- (void)loadEmbeddedAnimations
{
    SCNNode *characterTopLevelNode = [self.node.childNodes firstObject];
    [characterTopLevelNode enumerateChildNodesUsingBlock: ^(SCNNode *child, BOOL *stop) {
        for (NSString *key in child.animationKeys) {
            CAAnimation *animation = [child animationForKey:key];
            animation.usesSceneTimeBase = NO;
            animation.repeatCount = FLT_MAX;
            [child addAnimation:animation forKey:key];
        }
    }];
}

- (void)applyReplacementPosition
{
    if (self.shouldReplace) {
        self.node.position = self.replacementPosition;
        self.shouldReplace = NO;
    }
}


#pragma mark - Handle power ups

- (void)setLife:(CGFloat)life
{
    if (life > self.maxLife && life < 0) {
        return;
    }
    
    _life = life;
    NSLog(@"New life: %g", life); 
    [self.delegate updateLife:life toCharacter:self];
}

- (void)takeLife:(CGFloat)points
{
    if (self.inmortal) {
        return;
    }
        
	self.life -= points;

	if (self.life < 0) {
		self.life = 0;
    }
}

- (void)heal:(CGFloat)life
{
	self.life += life;

	if (self.life > self.maxLife) {
		self.life = self.maxLife;
	}
}

- (void)makeInmortalFor:(NSTimeInterval)time
{
    self.inmortal = YES;
    [self.delegate becameInvulnerable];

    __weak typeof(self)weakSelf = self;
    
    id wait = [SCNAction waitForDuration:time];
    id run = [SCNAction runBlock: ^(SCNNode *node) {
        weakSelf.inmortal = NO;
        [weakSelf.delegate becameVulnerable];
    }];
    
    [self.node runAction:[SCNAction sequence:@[wait, run]]];
}

- (void)speedMultiplier:(CGFloat)multiplier forInterval:(NSTimeInterval)interval
{
    CGFloat boost = (self.walkSpeed * multiplier);
    self.walkSpeed += boost;
    
    __weak typeof(self)weakSelf = self;
    
    id wait = [SCNAction waitForDuration:interval];
    id run = [SCNAction runBlock: ^(SCNNode *node) {
        weakSelf.walkSpeed -= boost;
    }];
    
    [self.node runAction:[SCNAction sequence:@[wait, run]]];
}

@end
