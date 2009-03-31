//
//  L0BeamableItem.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideItem.h"

@implementation L0SlideItem

+ (void) registerClass;
{
	for (NSString* type in [self supportedTypes])
		[self registerClass:self forType:type];
}

+ (NSArray*) supportedTypes;
{
	NSAssert(NO, @"Subclasses of L0BeamableItem must implement this method.");
	return nil;
}

static NSMutableDictionary* classes = nil;

+ (void) registerClass:(Class) c forType:(NSString*) type;
{
	if (!classes)
		classes = [NSMutableDictionary new];
	
	[classes setObject:c forKey:type];
}

+ (Class) classForType:(NSString*) c;
{
	return [classes objectForKey:c];
}

- (id) initWithNetworkPacketPayload:(NSData*) payload type:(NSString*) type title:(NSString*) title;
{
	NSAssert(NO, @"Subclasses of L0BeamableItem must implement this method.");
	return nil;
}

@synthesize title;
@synthesize type;
@synthesize representingImage;

- (NSData*) networkPacketPayload;
{
	NSAssert(NO, @"Subclasses of L0BeamableItem must implement this method.");
	return nil;
}

- (void) store;
{
	// Overridden, optionally, by subclasses.
}

- (void) dealloc;
{
	[title release];
	[type release];
	[representingImage release];
	[super dealloc];
}

@end

@implementation L0SlideItem (L0BLIPBeaming)

- (BLIPRequest*) networkBLIPRequest;
{
	NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
								self.title, @"L0BeamableItemTitle",
								self.type, @"L0BeamableItemType",
								@"1", @"L0BeamableItemWireProtocolVersion",
								nil];
								
	
	return [BLIPRequest requestWithBody:[self networkPacketPayload]
							 properties:properties];
}

+ (id) beamableItemWithNetworkBLIPRequest:(BLIPRequest*) req;
{
	NSString* version = [req valueOfProperty:@"L0BeamableItemWireProtocolVersion"];
	if (![version isEqualToString:@"1"])
		return nil;
	
	NSString* type = [req valueOfProperty:@"L0BeamableItemType"];
	if (!type)
		return nil;
	
	
	NSString* title = [req valueOfProperty:@"L0BeamableItemTitle"];
	if (!title)
		return nil;
	
	Class c = [self classForType:type];
	if (!c)
		return nil;
					   
	return [[[c alloc] initWithNetworkPacketPayload:req.body type:type title:title] autorelease];
}

@end
