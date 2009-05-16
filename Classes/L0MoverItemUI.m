//
//  L0MoverItemUI.m
//  Mover
//
//  Created by ∞ on 15/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverItemUI.h"

#import "L0ImageItem.h"
#import "L0AddressBookPersonItem.h"

@implementation L0MoverItemUI

static NSMutableDictionary* L0ItemClassesToUIs = nil;

+ (void) registerUI:(L0MoverItemUI*) ui forItemClass:(Class) c;
{
	if (!L0ItemClassesToUIs)
		L0ItemClassesToUIs = [NSMutableDictionary new];
	
	[L0ItemClassesToUIs setObject:ui forKey:NSStringFromClass(c)];
}

+ (void) registerClass;
{
	id myself = [[self new] autorelease];
	
	for (Class c in [self supportedItemClasses])
		[self registerUI:myself forItemClass:c];
}

+ (L0MoverItemUI*) UIForItemClass:(Class) i;
{
	Class current = i; id ui;
	do {
		if (!current || [current isEqual:[L0MoverItem class]])
			return nil;
		
		ui = [L0ItemClassesToUIs objectForKey:NSStringFromClass(current)];
		current = [current superclass];
	} while (ui == nil);
	
	return ui;
}

+ (L0MoverItemUI*) UIForItem:(L0MoverItem*) i;
{
	return [self UIForItemClass:[i class]];
}

// Funnels
+ (NSArray*) supportedItemClasses;
{
	NSAssert(NO, @"You must override +supportedItemClasses and/or +registerClass in your implementation.");
	return nil;
}

- (L0MoverItemAction*) mainActionForItem:(L0MoverItem*) i;
{
	return nil;
}

- (NSArray*) additionalActionsForItem:(L0MoverItem*) i;
{
	return [NSArray arrayWithObject:[self resaveAction]];
}

- (L0MoverItemAction*) showAction;
{
	return [L0MoverItemAction actionWithTarget:self selector:@selector(showOrOpenItem:forAction:) localizedLabel:NSLocalizedString(@"Show", @"Default label for the 'Show' action on items")];
}
- (L0MoverItemAction*) openAction;
{
	return [L0MoverItemAction actionWithTarget:self selector:@selector(showOrOpenItem:forAction:) localizedLabel:NSLocalizedString(@"Open", @"Default label for the 'Open' action on items")];
}

- (void) showOrOpenItem:(L0MoverItem*) i forAction:(L0MoverItemAction*) a;
{
	NSAssert(NO, @"You must override -showOrOpenItem:forAction: for this to work properly.");
}

- (L0MoverItemAction*) resaveAction;
{
	return [L0MoverItemAction actionWithTarget:self selector:@selector(resaveItem:forAction:) localizedLabel:NSLocalizedString(@"Save Again", @"Default label for the 'Save Again' action on items")];
}
// whose target is self and whose selector is:
- (void) resaveItem:(L0MoverItem*) i forAction:(L0MoverItemAction*) a;
{
	[i storeToAppropriateApplication];
}

- (BOOL) removingFromTableIsSafeForItem:(L0MoverItem*) i;
{
	NSAssert(NO, @"You must override -removingFromTableIsSafeForItem:");
	return NO;
}

@end

@implementation L0MoverDefaultItemUI

+ (NSArray*) supportedItemClasses;
{
	return [NSArray arrayWithObjects:[L0ImageItem class], [L0AddressBookPersonItem class], nil];
}

- (BOOL) removingFromTableIsSafeForItem:(L0MoverItem*) i;
{
	return YES;
}

@end
