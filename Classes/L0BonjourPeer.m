//
//  L0WiFiBeamingPeer.m
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0BonjourPeer.h"

static inline CFMutableDictionaryRef L0CFDictionaryCreateMutableForObjects() {
	return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

@implementation L0BonjourPeer

@synthesize service = _service;

- (id) initWithNetService:(NSNetService*) service;
{
	if (self = [super init]) {
		_service = [service retain];
		_itemsBeingSentByConnection = L0CFDictionaryCreateMutableForObjects();
	}
	
	return self;
}

- (void) dealloc;
{
	[_service release];
	CFRelease(_itemsBeingSentByConnection);
	
	[super dealloc];
}

- (NSString*) name;
{
	return [_service name];
}

- (BOOL) beginBeamingItem:(L0BeamableItem*) item;
{
	if (CFDictionaryContainsValue(_itemsBeingSentByConnection, item))
		return NO;
	
	BLIPConnection* connection = [[BLIPConnection alloc] initToNetService:_service];
	[connection open];
	
	CFDictionarySetValue(_itemsBeingSentByConnection, connection, item);
	
	[delegate beamingPeer:self willSendItem:item];
	
	connection.delegate = self;
	BLIPRequest* request = [item networkBLIPRequest];
	[connection sendRequest:request];
	
	return YES;
}

- (void) connection: (BLIPConnection*)connection receivedResponse: (BLIPResponse*)response;
{
	L0BeamableItem* i = (L0BeamableItem*) CFDictionaryGetValue(_itemsBeingSentByConnection,connection);
	if (i)
		[delegate beamingPeer:self didSendItem:i];
	
	// we assume it's fine. for now.
	[connection close];
}

- (void) connectionDidClose: (TCPConnection*)connection;
{
	L0Log(@"%@", connection);
	CFDictionaryRemoveValue(_itemsBeingSentByConnection, connection);
}

- (void) connection: (TCPConnection*)connection failedToOpen: (NSError*)error;
{
	L0Log(@"%@, %@", connection, error);
	CFDictionaryRemoveValue(_itemsBeingSentByConnection, connection);	
}

- (BOOL) connectionReceivedCloseRequest: (BLIPConnection*)connection;
{
	L0Log(@"%@", connection);
	return YES;
}

- (void) connection: (BLIPConnection*)connection closeRequestFailedWithError: (NSError*)error;
{
	L0Log(@"%@, %@", connection, error);
	[connection close];
}

@end
