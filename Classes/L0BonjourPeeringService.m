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

#define L0IPv6AddressIsEqual(a, b) (\
	(a).__u6_addr.__u6_addr32[0] == (b).__u6_addr.__u6_addr32[0] && \
	(a).__u6_addr.__u6_addr32[1] == (b).__u6_addr.__u6_addr32[1] && \
	(a).__u6_addr.__u6_addr32[2] == (b).__u6_addr.__u6_addr32[2] && \
	(a).__u6_addr.__u6_addr32[3] == (b).__u6_addr.__u6_addr32[3])

- (BOOL) _l0_comesFromAddressOfService:(NSNetService*) s;
{
	for (NSData* addressData in [s addresses]) {
		const struct sockaddr* s = [addressData bytes];
		if (s->sa_family == AF_INET) {
			const struct sockaddr_in* sIPv4 = (const struct sockaddr_in*) s;
			if (self.ipv4 == sIPv4->sin_addr.s_addr)
				return YES;
		} /* else if (s->sa_family == AF_INET6) {
			const struct sockaddr_in6* sIPv6 = (const struct sockaddr_in6*) s;
			if (L0IPv6AddressIsEqual(self.ipv6, sIPv6->sin6_addr))
				return YES;
		} */
	}
	
	return NO;
}

@end



@implementation L0BonjourPeeringService

+ sharedService;
{
	static id myself = nil; if (!myself)
		myself = [self new];
	
	return myself;
}

- (void) start;
{
	if (browser) return;
	
	peers = [NSMutableSet new];
	
	browser = [[NSNetServiceBrowser alloc] init];
	[browser setDelegate:self];
	[browser searchForServicesOfType:kL0BonjourPeeringServiceName inDomain:@""];
	
	listener = [[BLIPListener alloc] initWithPort:52525];
	listener.delegate = self;
	listener.pickAvailablePort = YES;
	listener.bonjourServiceType = kL0BonjourPeeringServiceName;
	listener.bonjourServiceName = [UIDevice currentDevice].name;
	listener.bonjourTXTRecord = [NSDictionary dictionaryWithObjectsAndKeys:
								  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], kL0BonjourPeerApplicationVersionKey,
								  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], kL0BonjourPeerUserVisibleApplicationVersionKey,
								  nil];
	NSError* e = nil;
	[listener open:&e];
	NSLog(@"%@", e);
	
//	_publishedService = [[NSNetService alloc] initWithDomain:@"" type:kL0BonjourPeeringServiceName name:[UIDevice currentDevice].name port:52525];
//	[_publishedService publish];
}

- (void) stop;
{	
	[browser stop];
	[browser release]; browser = nil;
	
	for (L0BonjourPeer* peer in peers)
		[delegate peerLeft:peer];
	
	[peers release]; peers = nil;
	
	[listener close];
	[listener release]; listener = nil;	
}

- (void) dealloc;
{
	[self stop];
	[super dealloc];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	L0BonjourPeer* leavingPeer = nil;
	for (L0BonjourPeer* peer in peers) {
		if ([peer.service isEqual:aNetService]) {
			leavingPeer = peer;
			break;
		}
	}
	
	if (leavingPeer) {
		[[leavingPeer retain] autorelease];
		[peers removeObject:leavingPeer];
		[delegate peerLeft:leavingPeer];
	}
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
		struct ifaddrs* allInterfaces = interface;
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
		
		freeifaddrs(allInterfaces);
	}
	
	if (isSelf) return;
	
	L0BonjourPeer* peer = [[L0BonjourPeer alloc] initWithNetService:sender];
	[peers addObject:peer];
	[delegate peerFound:peer];
	[peer release];
}

@synthesize delegate;

- (L0BonjourPeer*) peerForAddress:(IPAddress*) a;
{
	for (L0BonjourPeer* aPeer in peers) {
		if ([a _l0_comesFromAddressOfService:aPeer.service]) {
			return aPeer;
		}
	}
	
	return nil;
}

- (void) listener:(TCPListener*) listener didAcceptConnection:(TCPConnection*) connection;
{
	L0BonjourPeer* peer = [self peerForAddress:connection.address];
	
	if (!peer) {
		L0Log(@"No peer associated with this connection; throwing away.");
		[connection close];
		return;
	}
	
	[peer.delegate slidePeerWillSendUsItem:peer];
	
	[connection setDelegate:self];
	[pendingConnections addObject:connection];
}

- (void) connection: (BLIPConnection*)connection receivedRequest: (BLIPRequest*)request;
{
	L0BonjourPeer* peer = [self peerForAddress:connection.address];
	
	if (!peer) {
		L0Log(@"No peer associated with this connection; throwing away.");
		[pendingConnections removeObject:connection];
		[connection close];
		return;
	}

	L0MoverItem* item = [L0MoverItem itemWithContentsOfBLIPRequest:request];
	if (!item) {
		L0Log(@"No item could be created.");
		[connection close];
		[pendingConnections removeObject:connection];
		[peer.delegate slidePeerDidCancelSendingUsItem:peer];
		return;
	}
	
	[connection close];
	[pendingConnections removeObject:connection];
	[peer.delegate slidePeer:peer didSendUsItem:item];
	
	[request respondWithString:@"OK"];
}

@end
