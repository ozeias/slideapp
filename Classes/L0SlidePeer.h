//
//  L0BeamingPeer.h
//  Shard
//
//  Created by ∞ on 24/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0SlideItem.h"

@protocol L0SlidePeerDelegate;

@interface L0SlidePeer : NSObject {
	id <L0SlidePeerDelegate> delegate;
}

@property(readonly) NSString* name;
@property(assign) id <L0SlidePeerDelegate> delegate;

- (BOOL) receiveItem:(L0SlideItem*) item;

@end


@protocol L0SlidePeerDelegate <NSObject>

- (void) slidePeer:(L0SlidePeer*) peer willBeSentItem:(L0SlideItem*) item;
- (void) slidePeer:(L0SlidePeer*) peer wasSentItem:(L0SlideItem*) item;

- (void) slidePeerWillSendUsItem:(L0SlidePeer*) peer;
- (void) slidePeer:(L0SlidePeer*) peer didSendUsItem:(L0SlideItem*) item;

@end
