//
//  L0BeamableItemView.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0DraggableView.h"
#import "L0BeamableItem.h"

@interface L0BeamableItemView : L0DraggableView {
	UIView* contentView;
	
	UILabel* label;
	UIImageView* imageView;
}

@property(retain) IBOutlet UIView* contentView;
@property(assign) IBOutlet UILabel* label;
@property(assign) IBOutlet UIImageView* imageView;

- (void) displayWithContentsOfItem:(L0BeamableItem*) item;

@end
