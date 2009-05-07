//
//  L0WiFiBeamingPeer.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0MoverPeer.h"
#import "L0MoverItem.h"
#import "BLIP.h"

#define kL0BonjourPeerApplicationVersionKey @"L0AppVersion"
#define kL0BonjourPeerUserVisibleApplicationVersionKey @"L0UserAppVersion"

@interface L0BonjourPeer : L0MoverPeer <BLIPConnectionDelegate> {
	NSNetService* _service;
	CFMutableDictionaryRef _itemsBeingSentByConnection;
}

- (id) initWithNetService:(NSNetService*) service;

@property(readonly) NSNetService* service;

@end
