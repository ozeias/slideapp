//
//  L0BookmarkItem.m
//  Mover
//
//  Created by ∞ on 12/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0BookmarkItem.h"
#import "L0MoverUTISupport.h"

@implementation L0BookmarkItem

static id <L0BookmarkItemStorage> L0BookmarkItemCurrentStorage = nil;

+ (void) setStorage:(id <L0BookmarkItemStorage>) s;
{
	if (L0BookmarkItemCurrentStorage != s) {
		[L0BookmarkItemCurrentStorage release];
		L0BookmarkItemCurrentStorage = [s retain];
	}
}

+ (id <L0BookmarkItemStorage>) storage;
{
	return L0BookmarkItemCurrentStorage;
}

- (id) initWithAddress:(NSURL*) url title:(NSString*) t;
{
	if (self = [super init]) {
		self.address = url;
		self.title = t;
	}
	
	return self;
}

@synthesize address;

- (void) dealloc;
{
	[address release];
	[super dealloc];
}

+ (NSArray*) supportedTypes;
{
	return [NSArray arrayWithObject:kUTTypeURL];
}

- (NSData*) externalRepresentation;
{
	return [[self.address absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (id) initWithExternalRepresentation:(NSData*) payload type:(NSString*) ty title:(NSString*) t;
{
	NSString* str = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
	NSURL* theURL = [NSURL URLWithString:str];
	[str release];

	return [self initWithAddress:theURL title:t];
}

- (void) storeToAppropriateApplication;
{
	[[[self class] storage] storeBookmarkItem:self];
}

@end
