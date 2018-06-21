/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    Handles keyboard input for controlling the game.
 */

#import "AAPLGameViewControllerPrivate.h"

@implementation AAPLGameViewController (GameControls)

#pragma mark -  Game Controller Events

- (void)setupGameControllers
{
	self.gameView.eventsDelegate = self;
}

#pragma mark - Keyboard Events

- (BOOL)keyDown:(NSView *)view event:(NSEvent *)theEvent
{
    return [self event:theEvent handlerWithMask:NO];
}

- (BOOL)keyUp:(NSView *)view event:(NSEvent *)theEvent
{
    return [self event:theEvent handlerWithMask:YES];
}

- (BOOL)event:(NSEvent *)theEvent handlerWithMask:(BOOL) isKeyUp
{
    if (!self.gameView.playing && (theEvent.keyCode == 36 || theEvent.keyCode == 76)) { // Enter/return key, that means reset the game.
        [self setupScene];
        return YES;
    }
    
    BOOL success = NO;
    
    // You can shoot or change your weapon while you move
    if (theEvent.keyCode == 49) { // Spacebar
        if (!theEvent.isARepeat) {
            self.holdingTrigger = !isKeyUp;
            success = YES;
        }
    } else if (isKeyUp && theEvent.keyCode >= 18 && theEvent.keyCode <= 21) { // Numbers 1 to 4 representing the four weapon slots.
        [self activeWeaponNumber:(theEvent.keyCode - 18)];
    }
    
    switch (theEvent.keyCode) {
            
        case 0: // A
        case 123: { // Left
            if (!theEvent.isARepeat) {
                self.controllerDirection += (vector_float2) {(isKeyUp? -1 : 1), 0};
            }
            return YES;
        }
            
        case 2: // D
        case 124: // Right
            if (!theEvent.isARepeat) {
                self.controllerDirection += (vector_float2) {(isKeyUp? 1 : -1), 0};
            }
            return YES;
            
        case 13: // W
        case 126: { // Up
            if (!theEvent.isARepeat) {
                self.controllerDirection += (vector_float2) {0, (isKeyUp? -1 : 1)};
            }
            return YES;
        }
         
        case 1: // S
        case 125: { // Down
            if (!theEvent.isARepeat) {
                self.controllerDirection += (vector_float2) {0, (isKeyUp? 1 : -1)};
            }
            return YES;
        }
    }
    
    return success;
}

@end
