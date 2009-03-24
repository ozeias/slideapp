//
//  L0BonjourPeerDiscovery.m
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0BonjourPeerFinder.h"
#import "L0BonjourBeamingPeer.h"

@implementation L0BonjourPeerFinder

+ sharedFinder;
{
	static id myself = nil; if (!myself)
		myself = [self new];
	
	return myself;
}

- (void) beginPeering;
{
	if (_browser) return;
	
	_peers = [NSMutableSet new];
	
	_browser = [[NSNetServiceBrowser alloc] init];
	[_browser setDelegate:self];
	[_browser searchForServicesOfType:kL0BonjourPeeringServiceName inDomain:@""];
	
	_listener = [[BLIPListener alloc] initWithPort:52525];
	_listener.delegate = self;
	
	_publishedService = [[NSNetService alloc] initWithDomain:@"" type:kL0BonjourPeeringServiceName name:nil port:52525];
	[_publishedService publish];
}

- (void) stopPeering;
{	
	[_browser stop];
	[_browser release]; _browser = nil;
	
	for (L0BonjourBeamingPeer* peer in _peers)
		[delegate peerLeft:peer];
	
	[_peers release]; _peers = nil;
	
	[_listener close];
	[_listener release]; _listener = nil;
	
	[_publishedService stop];
	[_publishedService release]; _publishedService = nil;
}

- (void) dealloc;
{
	[self stopPeering];
	[super dealloc];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[aNetService setDelegate:self];
	[aNetService resolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender;
{
	L0BonjourBeamingPeer* peer = [[L0BonjourBeamingPeer alloc] initWithNetService:sender];
	[_peers addObject:peer];
	[delegate peerFound:peer];
}

@synthesize delegate;

- (void) listener:(TCPListener*) listener didAcceptConnection:(BLIPConnection*) connection;
{
	// TODO
}

@end
