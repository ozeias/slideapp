//
//  L0BeamableItemsTableController.h
//  Shard
//
//  Created by ∞ on 22/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0SlideItem.h"
#import "L0SlidePeer.h"
#import "L0DraggableView.h"

enum {
	kL0SlideItemsTableNoAddAnimation,
	
	kL0SlideItemsTableAddFromNorth,
	kL0SlideItemsTableAddFromEast,
	kL0SlideItemsTableAddFromWest,
	
	// used for self-additions
	kL0SlideItemsTableAddFromSouth,
	kL0SlideItemsTableAddByDropping,
};
typedef NSUInteger L0SlideItemsTableAddAnimation;

enum {
	kL0SlideItemsTableNoRemoveAnimation,

	//	kL0SlideItemsTableAddFromNorth,
	//	kL0SlideItemsTableAddFromEast,
	//	kL0SlideItemsTableAddFromWest,
	
	kL0SlideItemsTableFadeAway,
};
typedef NSUInteger L0SlideItemsTableRemoveAnimation;

@interface L0SlideItemsTableController : UIViewController <L0DraggableViewDelegate> {
	CFMutableDictionaryRef itemsToViews;
	
	UIImageView* northArrowView;
	UIImageView* eastArrowView;
	UIImageView* westArrowView;
	
	UILabel* northLabel;
	UILabel* eastLabel;
	UILabel* westLabel;
	
	L0SlidePeer* northPeer;
	L0SlidePeer* eastPeer;
	L0SlidePeer* westPeer;
}

- (id) initWithDefaultNibName;

@property(assign) IBOutlet UIImageView* northArrowView;
@property(assign) IBOutlet UIImageView* eastArrowView;
@property(assign) IBOutlet UIImageView* westArrowView;

@property(assign) IBOutlet UILabel* northLabel;
@property(assign) IBOutlet UILabel* eastLabel;
@property(assign) IBOutlet UILabel* westLabel;

@property(retain) L0SlidePeer* northPeer;
@property(retain) L0SlidePeer* eastPeer;
@property(retain) L0SlidePeer* westPeer;

- (BOOL) addPeerIfSpaceAllows:(L0SlidePeer*) peer;
- (void) removePeer:(L0SlidePeer*) peer;

- (void) addItem:(L0SlideItem*) item comingFromPeer:(L0SlidePeer*) peer;
- (void) addItem:(L0SlideItem*) item animation:(L0SlideItemsTableAddAnimation) animation;
- (void) removeItem:(L0SlideItem*) item /* animation: ... */;

- (void) returnItemToTableAfterSend:(L0SlideItem*) item;

@end
