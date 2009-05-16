//
//  L0MoverItemAction.h
//  Mover
//
//  Created by ∞ on 15/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0MoverItem.h"

@interface L0MoverItemAction : NSObject {
	id target;
	SEL selector;
	NSString* localizedLabel;
}

// selector is of the form:
// - (void) doSomethingToItem:(L0MoverItem*) item forAction:(L0MoverItemAction*) a;

- (id) initWithTarget:(id) target selector:(SEL) selector localizedLabel:(NSString*) localizedLabel;
+ (id) actionWithTarget:(id) target selector:(SEL) selector localizedLabel:(NSString*) localizedLabel;

@property(readonly) NSString* localizedLabel;
@property(readonly) id target;
@property(readonly) SEL selector;

- (void) performOnItem:(L0MoverItem*) item;

@end
