//
//  L0BonjourPeerDiscovery.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0PeerDiscovery.h"
#import "BLIP.h"

#define kL0BonjourPeeringServiceName @"_x-infinitelabs-slides._tcp."

@interface L0BonjourPeeringService : NSObject <TCPListenerDelegate, BLIPConnectionDelegate> {
	id <L0PeerDiscoveryDelegate> delegate;
	NSNetServiceBrowser* browser;

	NSMutableSet* peers;
	
	BLIPListener* listener;
	NSMutableSet* pendingConnections;
}

+ sharedService;

- (void) start;
- (void) stop;

@property(assign) id <L0PeerDiscoveryDelegate> delegate;

@end

