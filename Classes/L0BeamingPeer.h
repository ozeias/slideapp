//
//  L0BeamingPeer.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0BeamableItem.h"

@protocol L0BeamingPeerDelegate;

@interface L0BeamingPeer : NSObject {
	id <L0BeamingPeerDelegate> delegate;
}

@property(readonly) NSString* name;
@property(assign) id <L0BeamingPeerDelegate> delegate;

- (BOOL) beginBeamingItem:(L0BeamableItem*) item;

@end


@protocol L0BeamingPeerDelegate <NSObject>

- (void) beamingPeer:(L0BeamingPeer*) peer willSendItem:(L0BeamableItem*) item;
- (void) beamingPeer:(L0BeamingPeer*) peer didSendItem:(L0BeamableItem*) item;

- (void) beamingPeerWillReceiveItem:(L0BeamingPeer*) peer;
- (void) beamingPeer:(L0BeamingPeer*) peer didReceiveItem:(L0BeamableItem*) item;

@end
