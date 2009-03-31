//
//  L0BeamingPeer.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0SlideItem.h"

@protocol L0BeamingPeerDelegate;

@interface L0SlidePeer : NSObject {
	id <L0BeamingPeerDelegate> delegate;
}

@property(readonly) NSString* name;
@property(assign) id <L0BeamingPeerDelegate> delegate;

- (BOOL) beginBeamingItem:(L0SlideItem*) item;

@end


@protocol L0BeamingPeerDelegate <NSObject>

- (void) beamingPeer:(L0SlidePeer*) peer willSendItem:(L0SlideItem*) item;
- (void) beamingPeer:(L0SlidePeer*) peer didSendItem:(L0SlideItem*) item;

- (void) beamingPeerWillReceiveItem:(L0SlidePeer*) peer;
- (void) beamingPeer:(L0SlidePeer*) peer didReceiveItem:(L0SlideItem*) item;

@end
