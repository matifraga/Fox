/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This class manages most of the game logic.
*/

#ifndef AAPLCollisionMask_h
#define AAPLCollisionMask_h

typedef NS_OPTIONS (NSUInteger, AAPLBitmask) {
	AAPLBitmaskPlayer        = 1UL << 1,
	AAPLBitmaskCollectable   = 1UL << 2,
	AAPLBitmaskEnemy         = 1UL << 3,
	AAPLBitmaskCollision     = 1UL << 4,
    AAPLBitmaskWeapon        = 1UL << 5
};

#endif
