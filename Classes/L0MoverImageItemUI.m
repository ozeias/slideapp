//
//  L0MoverImageItemUI.m
//  Mover
//
//  Created by ∞ on 16/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverImageItemUI.h"
#import "L0MoverImageViewer.h"
#import "L0ImageItem.h"
#import "L0MoverAppDelegate.h"

@implementation L0MoverImageItemUI

+ (NSArray*) supportedItemClasses;
{
	return [NSArray arrayWithObject:[L0ImageItem class]];
}

- (BOOL) removingFromTableIsSafeForItem:(L0MoverItem*) i;
{
	return YES;
}

- (L0MoverItemAction*) mainActionForItem:(L0MoverItem*) i;
{
	return [self showAction];
}

- (void) showOrOpenItem:(L0MoverItem*) i forAction:(L0MoverItemAction*) a;
{
	L0ImageItem* item = (L0ImageItem*) i;
	L0MoverImageViewer* viewer = [[[L0MoverImageViewer alloc] initWithImage:item.image] autorelease];
	UINavigationController* controller = [[[UINavigationController alloc] initWithRootViewController:viewer] autorelease];	
	controller.navigationBar.barStyle = UIBarStyleBlackTranslucent;

	L0MoverAppDelegate* delegate = (L0MoverAppDelegate*) UIApp.delegate;
	[delegate.tableHostController presentModalViewController:controller animated:YES];
}

@end
