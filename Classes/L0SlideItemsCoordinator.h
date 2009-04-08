//
//  L0SlideItemsCoordinator.h
//  Slide
//
//  Created by ∞ on 08/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "L0SlideItem.h"

// Mostly TODO

@interface L0SlideItemsCoordinator : NSObject {
	NSMutableArray* itemInformation;
}

- (void) persistItem:(L0SlideItem*) item;
- (void) removePersistedItem:(L0SlideItem*) item;

- (void) loadItemsFromMassStorage;
- (void) saveItemsToMassStorage;

@end
