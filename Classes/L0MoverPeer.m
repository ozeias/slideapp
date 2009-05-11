//
//  L0BeamingPeer.m
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverPeer.h"


@implementation L0MoverPeer

@synthesize delegate;

- (BOOL) receiveItem:(L0MoverItem*) item;
{
	NSAssert(NO, @"Abstract method. Subclasses must override it.");
	return NO;
}

@dynamic name, applicationVersion, userVisibleApplicationVersion;

- (NSString*) description;
{
	return [NSString stringWithFormat:@"%@ { %@ }", [super description], self.name];
}

@end
