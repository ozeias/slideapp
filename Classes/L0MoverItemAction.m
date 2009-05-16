//
//  L0MoverItemAction.m
//  Mover
//
//  Created by ∞ on 15/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverItemAction.h"


@implementation L0MoverItemAction

- (id) initWithTarget:(id) t selector:(SEL) s localizedLabel:(NSString*) l;
{
	if (self = [super init]) {
		target = t; // weak
		selector = s;
		localizedLabel = [l copy];
	}
	
	return self;
}

+ (id) actionWithTarget:(id) t selector:(SEL) s localizedLabel:(NSString*) l;
{
	return [[[self alloc] initWithTarget:t selector:s localizedLabel:l] autorelease];
}

@synthesize target, selector, localizedLabel;

- (void) performOnItem:(L0MoverItem*) item;
{
	[target performSelector:selector withObject:item withObject:self];
}

- (void) dealloc;
{
	[localizedLabel release];
	[super dealloc];
}

@end
