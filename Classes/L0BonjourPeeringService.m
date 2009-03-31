//
//  L0BonjourPeerDiscovery.m
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0BonjourPeeringService.h"
#import "L0BonjourPeer.h"

#import "BLIP.h"
#import "IPAddress.h"
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>

@interface IPAddress (L0BonjourPeerFinder_NetServicesMatching)

- (BOOL) _l0_comesFromAddressOfService:(NSNetService*) s;

@end

@implementation IPAddress (L0BonjourPeerFinder_NetServicesMatching)

- (BOOL) _l0_comesFromAddressOfService:(NSNetService*) s;
{
	for (NSData* addressData in [s addresses]) {
		const struct sockaddr* s = [addressData bytes];
		if (s->sa_family == AF_INET) {
			const struct sockaddr_in* sIPv4 = (const struct sockaddr_in*) s;
			if (self.ipv4 == sIPv4->sin_addr.s_addr)
				return YES;
		}
	}
	
	return NO;
}

@end



@implementation L0BonjourPeeringService

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
	_listener.pickAvailablePort = YES;
	_listener.bonjourServiceType = kL0BonjourPeeringServiceName;
	_listener.bonjourServiceName = [UIDevice currentDevice].name;
	NSError* e = nil;
	[_listener open:&e];
	NSLog(@"%@", e);
	
//	_publishedService = [[NSNetService alloc] initWithDomain:@"" type:kL0BonjourPeeringServiceName name:[UIDevice currentDevice].name port:52525];
//	[_publishedService publish];
}

- (void) stopPeering;
{	
	[_browser stop];
	[_browser release]; _browser = nil;
	
	for (L0BonjourPeer* peer in _peers)
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
	[aNetService retain];
	[aNetService setDelegate:self];
	[aNetService resolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender;
{
	[sender autorelease];
	
	BOOL isSelf = NO;
	struct ifaddrs* interface;
	
	if (getifaddrs(&interface) == 0) {
		while (interface != NULL) {
			const struct sockaddr_in* address = (const struct sockaddr_in*) interface->ifa_addr;
			if (address->sin_family != AF_INET) {
				interface = interface->ifa_next;
				continue;
			}
			
			for (NSData* serviceAddressData in [sender addresses]) {
				const struct sockaddr_in* serviceAddress = [serviceAddressData bytes];
				if (!serviceAddress->sin_family == AF_INET) continue;
				
				if (serviceAddress->sin_addr.s_addr == address->sin_addr.s_addr) {
					isSelf = YES;
					break;
				}
			}
			
			if (isSelf) break;
			interface = interface->ifa_next;
		}
	}
	
	if (isSelf) return;
	
	L0BonjourPeer* peer = [[L0BonjourPeer alloc] initWithNetService:sender];
	[_peers addObject:peer];
	[delegate peerFound:peer];
}

@synthesize delegate;

- (L0BonjourPeer*) peerForAddress:(IPAddress*) a;
{
	for (L0BonjourPeer* aPeer in _peers) {
		if ([a _l0_comesFromAddressOfService:aPeer.service]) {
			return aPeer;
		}
	}
	
	return nil;
}

- (void) listener:(TCPListener*) listener didAcceptConnection:(BLIPConnection*) connection;
{
	L0BonjourPeer* peer = [self peerForAddress:connection.address];
	
	if (!peer) {
		[connection close];
		return;
	}
	
	[connection setDelegate:self];
	[_pendingConnections addObject:connection];
}

- (void) connection: (BLIPConnection*)connection receivedRequest: (BLIPRequest*)request;
{
	L0SlideItem* item = [L0SlideItem beamableItemWithNetworkBLIPRequest:request];
	if (!item) {
		[connection close];
		[_pendingConnections removeObject:connection];
		return;
	}
	
	L0BonjourPeer* peer = [self peerForAddress:connection.address];
	
	if (!peer) {
		[connection close];
		return;
	}

	[connection close];
	[_pendingConnections removeObject:connection];
	[peer.delegate beamingPeer:peer didReceiveItem:item];
}

@end
