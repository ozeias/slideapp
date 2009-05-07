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

@interface L0BonjourPeer ()

@property(assign, setter=privateSetApplicationVersion:) double applicationVersion;
@property(copy, setter=privateSetUserVisibleApplicationVersion:) NSString* userVisibleApplicationVersion;

@end


@implementation L0BonjourPeer

@synthesize service = _service;
@synthesize applicationVersion, userVisibleApplicationVersion;

- (id) initWithNetService:(NSNetService*) service;
{
	if (self = [super init]) {
		_service = [service retain];
		_itemsBeingSentByConnection = L0CFDictionaryCreateMutableForObjects();
		
		NSData* txtData = [service TXTRecordData];
		if (txtData) {
			NSDictionary* info = [NSNetService dictionaryFromTXTRecordData:txtData];
			L0Log(@"Parsing info dictionary %@ for peer %@", info, self);
			
			NSData* appVersionData;
			if (appVersionData = [info objectForKey:kL0BonjourPeerApplicationVersionKey])
				self.applicationVersion = [[[[NSString alloc] initWithData:appVersionData encoding:NSUTF8StringEncoding] autorelease] doubleValue];
			
			NSData* userVisibleAppVersionData;
			if (userVisibleAppVersionData = [info objectForKey:kL0BonjourPeerUserVisibleApplicationVersionKey])
				self.userVisibleApplicationVersion = [[[NSString alloc] initWithData:userVisibleAppVersionData encoding:NSUTF8StringEncoding] autorelease];
			
			L0Log(@"App version found: %f.", self.applicationVersion);
			L0Log(@"User visible app version found: %@", self.userVisibleApplicationVersion);
		}
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

- (BOOL) receiveItem:(L0MoverItem*) item;
{
	if (CFDictionaryContainsValue(_itemsBeingSentByConnection, item))
		return NO;
	
	BLIPConnection* connection = [[BLIPConnection alloc] initToNetService:_service];
	[connection open];
	
	CFDictionarySetValue(_itemsBeingSentByConnection, connection, item);
	
	[delegate slidePeer:self willBeSentItem:item];
	
	connection.delegate = self;
	BLIPRequest* request = [item contentsAsBLIPRequest];
	[connection sendRequest:request];
	[connection release];
	
	return YES;
}

- (void) connection: (BLIPConnection*)connection receivedResponse: (BLIPResponse*)response;
{
	L0MoverItem* i = (L0MoverItem*) CFDictionaryGetValue(_itemsBeingSentByConnection, connection);
	if (i)
		[delegate slidePeer:self wasSentItem:i];
	
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
