//
//  L0MoverAddressBookItemUI.m
//  Mover
//
//  Created by ∞ on 16/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverAddressBookItemUI.h"
#import "L0AddressBookPersonItem.h"
#import "L0MoverAppDelegate.h"

@implementation L0MoverAddressBookItemUI

+ (NSArray*) supportedItemClasses;
{
	return [NSArray arrayWithObject:[L0AddressBookPersonItem class]];
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
	ABRecordRef person = [(L0AddressBookPersonItem*)i newPersonRecordWithContentsOfItem];
	if (!person) return;
	
	ABPersonViewController* personCtl = [[ABPersonViewController new] autorelease];
	personCtl.displayedPerson = person;
	CFRelease(person);

	personCtl.title = i.title;
	personCtl.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
	personCtl.allowsEditing = NO;
	personCtl.personViewDelegate = self;
	
	UINavigationController* ctl = [[UINavigationController alloc] initWithRootViewController:personCtl];
	
	L0MoverAppDelegate* delegate = (L0MoverAppDelegate*) UIApp.delegate;
	[delegate.tableHostController presentModalViewController:ctl animated:YES];
}

- (void) dismiss;
{
	L0MoverAppDelegate* delegate = (L0MoverAppDelegate*) UIApp.delegate;
	[delegate.tableHostController dismissModalViewControllerAnimated:YES];
}

- (BOOL) personViewController:(ABPersonViewController*) personViewController shouldPerformDefaultActionForPerson:(ABRecordRef) person property:(ABPropertyID) property identifier:(ABMultiValueIdentifier) identifier;
{
	return YES;
}

@end
