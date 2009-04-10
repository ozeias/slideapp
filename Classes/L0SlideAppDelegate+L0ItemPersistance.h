//
//  L0SlideAppDelegate+L0ItemPersistance.h
//  Slide
//
//  Created by ∞ on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0SlideAppDelegate.h"

@class L0SlideItem;

@interface L0SlideAppDelegate (L0ItemPersistance)

- (void) persistItemsToMassStorage:(NSArray*) items;
- (NSArray*) loadItemsFromMassStorage;

@end
