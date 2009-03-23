//
//  L0BeamableItemsTableController.h
//  Shard
//
//  Created by ∞ on 22/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0BeamableItem.h"
#import "L0DraggableView.h"

enum {
	kL0BeamableItemsTableNoAddAnimation,
	
//	kL0BeamableItemsTableAddFromNorth,
//	kL0BeamableItemsTableAddFromEast,
//	kL0BeamableItemsTableAddFromWest,
	
	// used for self-additions
	kL0BeamableItemsTableAddFromSouth,
};
typedef NSUInteger L0BeamableItemsTableAddAnimation;

enum {
	kL0BeamableItemsTableNoRemoveAnimation,

	//	kL0BeamableItemsTableAddFromNorth,
	//	kL0BeamableItemsTableAddFromEast,
	//	kL0BeamableItemsTableAddFromWest,
	
	// used for self-additions
	kL0BeamableItemsTableFadeAway,
};
typedef NSUInteger L0BeamableItemsTableRemoveAnimation;

@interface L0BeamableItemsTableController : UIViewController <L0DraggableViewDelegate> {
	CFMutableDictionaryRef itemsToViews;
	
	UIImageView* northArrowView;
	UIImageView* eastArrowView;
	UIImageView* westArrowView;
	
	UILabel* northLabel;
	UILabel* eastLabel;
	UILabel* westLabel;
}

- (id) initWithDefaultNibName;

@property(assign) IBOutlet UIImageView* northArrowView;
@property(assign) IBOutlet UIImageView* eastArrowView;
@property(assign) IBOutlet UIImageView* westArrowView;

@property(assign) IBOutlet UILabel* northLabel;
@property(assign) IBOutlet UILabel* eastLabel;
@property(assign) IBOutlet UILabel* westLabel;

- (void) addItem:(L0BeamableItem*) item animation:(L0BeamableItemsTableAddAnimation) animation;
- (void) removeItem:(L0BeamableItem*) item /* animation: ... */;

@end
