//
//  L0MoverItemUI.h
//  Mover
//
//  Created by ∞ on 15/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "L0MoverItemAction.h"
#import "L0MoverItem.h"

@interface L0MoverItemUI : NSObject {

}

+ (void) registerUI:(L0MoverItemUI*) ui forItemClass:(Class) c;
+ (void) registerClass;

+ (L0MoverItemUI*) UIForItemClass:(Class) i;
+ (L0MoverItemUI*) UIForItem:(L0MoverItem*) i;

// Funnels
+ (NSArray*) supportedItemClasses;

- (L0MoverItemAction*) mainActionForItem:(L0MoverItem*) i;
- (NSArray*) additionalActionsForItem:(L0MoverItem*) i;

- (L0MoverItemAction*) showAction;
- (L0MoverItemAction*) openAction;
// The above actions have the receiver as target and the following method as their selector.
- (void) showOrOpenItem:(L0MoverItem*) i forAction:(L0MoverItemAction*) a;

- (L0MoverItemAction*) resaveAction;
// whose target is self and whose selector is:
- (void) resaveItem:(L0MoverItem*) i forAction:(L0MoverItemAction*) a;

- (BOOL) removingFromTableIsSafeForItem:(L0MoverItem*) i;

@end

@interface L0MoverDefaultItemUI : L0MoverItemUI {}
@end
