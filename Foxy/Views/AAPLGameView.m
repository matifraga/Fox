/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    The view displaying the game scene, including the 2D overlay.
 */

@import SpriteKit;

#import "AAPLGameView.h"

@interface AAPLGameView ()
@property (nonatomic, strong) SKSpriteNode *overlayNode;
@property (nonatomic, strong) SKLabelNode *numberOfWaves;
@property (nonatomic, strong) SKLabelNode *amountOfLife;
@property (nonatomic, strong) SKSpriteNode *lifeBar;
@property (nonatomic, strong) SKLabelNode *selectedWeapon;
@end

@implementation AAPLGameView

#pragma mark - 2D Overlay

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	[self setup2DOverlay];
}

- (void)setup2DOverlay
{
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;

	self.overlayNode = [[SKSpriteNode alloc] init];

    //Add scene and overlay node to the scene
	SKScene *skScene = [SKScene sceneWithSize:CGSizeMake(width, height)];
	skScene.anchorPoint = CGPointMake(0.0f, 0.0f);
	[skScene addChild:self.overlayNode];

	self.overlayNode.position = CGPointMake(0.0f, 0.0f);
	self.overlayNode.anchorPoint = CGPointMake(0.0f, 0.0f);
    
    //Display elements on the screen
    [self displayWaveNumberLabelAt:width And:height];
    [self displayLifeBarAt:280.0f And:(height - 40.f)];
    [self displayWeaponLabelAt: 150.0f And:height];

	self.overlaySKScene = skScene;
	skScene.userInteractionEnabled = NO;
}

- (void)displayWaveNumberLabelAt:(CGFloat)x And:(CGFloat)y
{
    self.numberOfWaves = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.numberOfWaves.fontSize = 32.0f;
    self.numberOfWaves.position = CGPointMake(x - 10.0f, y - 20.0f);
    self.numberOfWaves.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.numberOfWaves.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [self.overlayNode addChild:self.numberOfWaves];
    self.wave = 1;
}

- (void)displayWeaponLabelAt:(CGFloat)x And:(CGFloat)y
{
    self.selectedWeapon = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.selectedWeapon.text = @"no weapon";
    self.selectedWeapon.fontSize = 20.0f;
    self.selectedWeapon.position = CGPointMake(x, y - 25.0f);
    self.selectedWeapon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.selectedWeapon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [self.overlayNode addChild:self.selectedWeapon];
}


- (void)displayLifeBarAt:(CGFloat)x And:(CGFloat)y
{
    self.lifeBar = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(300.0f, 30.0f)];
    self.lifeBar.position = CGPointMake(x, y);
    self.lifeBar.anchorPoint = CGPointMake(0.0f, 0.0f);
    [self.overlayNode addChild:self.lifeBar];
    
    [self addLifeLabelAt:x And:y];
}

- (void)addLifeLabelAt:(CGFloat)x And:(CGFloat)y
{
    self.amountOfLife = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.amountOfLife.text = @"100";
    self.amountOfLife.fontSize = 20.0f;
    self.amountOfLife.position = CGPointMake(x + 130.0f, y + 15.0f);
    self.amountOfLife.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.amountOfLife.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [self.overlayNode addChild:self.amountOfLife];
}

- (void)setInmortal:(BOOL)inmortal
{
	_inmortal = inmortal;

	if (inmortal) {
		self.amountOfLife.color = [NSColor blackColor];
	} else {
        self.amountOfLife.color = [NSColor whiteColor];
	}
}

- (void)setLife:(CGFloat)life
{
    _life = life; 
	self.amountOfLife.text = [NSString stringWithFormat:@"%.0f", life * 100.0f];
	self.lifeBar.xScale = life;

    [self updateLifeBarColor];
}

- (void)updateLifeBarColor
{
    if (self.life <= 0.25f) {
        self.lifeBar.color = [NSColor redColor];
    } else if (self.life <= 0.5f) {
        self.lifeBar.color = [NSColor orangeColor];
    } else if (self.life <= 0.75f) {
        self.lifeBar.color = [NSColor yellowColor];
    } else {
        self.lifeBar.color = [NSColor greenColor];
    }
}

- (void)hurtEnemy:(SCNNode *)enemyNode
{
    NSColor *oldColor = enemyNode.geometry.firstMaterial.diffuse.contents;
    NSColor *newColor = [NSColor redColor];
    
    __weak typeof(self)weakSelf = self;
    
    SCNAction *action = [SCNAction customActionWithDuration:10 actionBlock:^(SCNNode * _Nonnull node, CGFloat elapsedTime) {
        CGFloat percent = elapsedTime / 5.0f;
        node.geometry.firstMaterial.diffuse.contents = [weakSelf aniColorFromColor:oldColor toColor:newColor withPercentage:percent];
    }];

    [enemyNode runAction:action];
}

- (NSColor *) aniColorFromColor:(NSColor *)from toColor:(NSColor *)to withPercentage:(CGFloat)perc
{
    CGFloat red = from.redComponent + (to.redComponent - from.redComponent) * perc;
    CGFloat green = from.greenComponent + (to.greenComponent - from.greenComponent) * perc;
    CGFloat blue = from.blueComponent + (to.blueComponent - from.blueComponent) * perc;
    CGFloat alpha = from.alphaComponent + (to.alphaComponent - from.alphaComponent) * perc;

    return [NSColor colorWithSRGBRed:red green: green blue: blue alpha: alpha];
}

- (void)setWave:(NSUInteger)wave
{
	_wave = wave;
	self.numberOfWaves.text = [NSString stringWithFormat:@"Wave %ld", wave];
}

- (void)setWeapon:(NSString *)weapon
{
    if (weapon) {
        _weapon = weapon;
        self.selectedWeapon.text = weapon;
    }
}

- (void)setGameOverScreenVisible:(BOOL)visible
{
    if (visible) {
        self.life = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (visible) {
            self.dimensions = [SKSpriteNode spriteNodeWithColor:[[SKColor redColor] colorWithAlphaComponent:
                                                                 self.wave < 5 ? (1.0f - 0.2f * self.wave) : 0.1f] size:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
            self.dimensions.position = CGPointMake(0.0f, 0.0f);
            self.dimensions.anchorPoint = self.dimensions.position;
            
            [self.dimensions addChild:[self gameOver]];
            [self.dimensions addChild:[self wavesMessage]];
            [self.overlayNode addChild:self.dimensions];
        } else {
            [self.dimensions removeFromParent];
            self.dimensions = nil;
        }
    });
}

- (SKLabelNode *)gameOver
{
    SKLabelNode *gameOver = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    if (self.wave < 5) {
        gameOver.text = @"GAME OVER";
    } else {
        gameOver.text = @"YOU CAN SURVIVE IN";
    }
    gameOver.fontSize = 60.0f;
    
    // Center label
    gameOver.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    gameOver.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    gameOver.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    return gameOver;
}

- (SKLabelNode *)wavesMessage
{
    SKLabelNode *wavesMessage = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    if (self.wave == 1) {
        wavesMessage.text = @"Did you even play?";
    } else if (self.wave < 5) {
        wavesMessage.text = [NSString stringWithFormat:@"Just %lu waves..", self.wave];
    } else {
        wavesMessage.text = @"The Walking Dead";
    }
    wavesMessage.fontSize = 30.0f;
    
    // Center label
    wavesMessage.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 90.0f);
    wavesMessage.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    wavesMessage.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    return wavesMessage;
}


- (void)resetGameView
{
    [self setGameOverScreenVisible:NO];
    [self setLife:1.0f];
    [self setInmortal:NO];
    self.wave = 1;
    self.selectedWeapon.text = @"no weapon";
}

#pragma mark - Keyboard Events

- (void)keyDown:(NSEvent *)theEvent
{
	if (!_eventsDelegate || [_eventsDelegate keyDown:self event:theEvent] == NO) {
		[super keyDown:theEvent];
	}
}

- (void)keyUp:(NSEvent *)theEvent
{
	if (!_eventsDelegate || [_eventsDelegate keyUp:self event:theEvent] == NO) {
		[super keyUp:theEvent];
	}
}

@end
