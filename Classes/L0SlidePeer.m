//
//  L0BeamingPeer.m
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlidePeer.h"


@implementation L0SlidePeer

@synthesize delegate;

- (BOOL) beginBeamingItem:(L0SlideItem*) item;
{
	NSAssert(NO, @"Abstract method. Subclasses must override it.");
	return NO;
}

@dynamic name;

@end