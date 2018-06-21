//
//  AAPLWeapon.h
//  Fox OS X (Objective-C)
//
//  Created by matias fraga on 10/6/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

@import SceneKit;

#import <Foundation/Foundation.h>
#import "AAPLCollisionMask.h"

@interface AAPLWeapon : NSObject

typedef NS_OPTIONS(NSUInteger, AAPLWeaponTypes) {
    AAPLGranade              = 0,
    AAPLGun                  = 1,
    AAPLFlamethrower         = 2
};

@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNNode *node;
@property (nonatomic) CGFloat damage;
@property (nonatomic, strong) NSString *weaponName;
@property (nonatomic) AAPLWeaponTypes type;

- (instancetype)initWithName:(NSString *)name andDamage:(CGFloat)damage andType:(AAPLWeaponTypes)type;
- (void)attackFromPosition:(SCNVector3)position withAngle:(CGFloat)angle andPlayerScene:(SCNScene *)scene andEnemiesInScene:(NSArray *)enemies;
+ (AAPLWeapon *)findWeaponWithNode:(SCNNode *)node;
+ (AAPLWeapon *)generateGranade;
+ (AAPLWeapon *)generateGun;
+ (AAPLWeapon *)generateFlamethrower;

@end
