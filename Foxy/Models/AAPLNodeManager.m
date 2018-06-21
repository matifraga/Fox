//
// AAPLNodeManager.m
// Fox OS X (Objective-C)
//
// Created by Tomi De Lucca on 6/17/18.
// Copyright © 2018 Apple Inc. All rights reserved.
//

#import "AAPLNodeManager.h"

// This was copied to avoid managing the memmory consumption of items, enemies and so on the Singleton, and avoid possible memmory leaks

@interface AAPLNodeManager ()
// NSMapTable is like a map but it lets you define the retation policy over the key and the value
// if some of them gets thrown out of the heap, the whole entry gets removed from the NSMapTable
@property (nonatomic, strong) NSMapTable <SCNNode *, NSObject *> *nodes;
@end

@implementation AAPLNodeManager

+ (id)sharedManager
{
	static AAPLNodeManager *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc] init];
		sharedMyManager.nodes = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
	});
	return sharedMyManager;
}

- (void)associateNode:(SCNNode *)node withModel:(id)model
{
	[self.nodes setObject:model forKey:node];
}

- (id)modelForAssociatedNode:(SCNNode *)node
{
	return [self.nodes objectForKey:node];
}

@end
