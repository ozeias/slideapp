//
//  L0MoverAppDelegate+L0ItemPersistance.h
//  Slide
//
//  Created by ∞ on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0MoverAppDelegate.h"

@class L0MoverItem;

@interface L0MoverAppDelegate (L0ItemPersistance)

- (void) persistItemsToMassStorage:(NSArray*) items;
- (NSArray*) loadItemsFromMassStorage;

@end
