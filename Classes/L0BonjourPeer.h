//
//  L0WiFiBeamingPeer.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0BeamingPeer.h"
#import "L0BeamableItem.h"
#import "BLIP.h"

@interface L0BonjourPeer : L0BeamingPeer <BLIPConnectionDelegate> {
	NSNetService* _service;
	CFMutableDictionaryRef _itemsBeingSentByConnection;
}

- (id) initWithNetService:(NSNetService*) service;

@property(readonly) NSNetService* service;

@end
