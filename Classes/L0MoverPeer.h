//
//  L0BeamingPeer.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0MoverItem.h"

#define kL0UnknownApplicationVersion (0.0)

@protocol L0MoverPeerDelegate;

@interface L0MoverPeer : NSObject {
	id <L0MoverPeerDelegate> delegate;
	double applicationVersion;
	NSString* userVisibleApplicationVersion;
}

@property(readonly) NSString* name;
@property(assign) id <L0MoverPeerDelegate> delegate;
@property(readonly) double applicationVersion;
@property(readonly, copy) NSString* userVisibleApplicationVersion;

- (BOOL) receiveItem:(L0MoverItem*) item;

@end


@protocol L0MoverPeerDelegate <NSObject>

- (void) slidePeer:(L0MoverPeer*) peer willBeSentItem:(L0MoverItem*) item;
- (void) slidePeer:(L0MoverPeer*) peer wasSentItem:(L0MoverItem*) item;

- (void) slidePeerWillSendUsItem:(L0MoverPeer*) peer;
- (void) slidePeer:(L0MoverPeer*) peer didSendUsItem:(L0MoverItem*) item;
- (void) slidePeerDidCancelSendingUsItem:(L0MoverPeer*) peer;

@end
