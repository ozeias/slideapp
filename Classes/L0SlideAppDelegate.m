//
//  ShardAppDelegate.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "L0SlideAppDelegate.h"
#import "L0ImageItem.h"
#import "L0BonjourPeeringService.h"

@interface L0SlideAppDelegate ()

- (void) _showToolbar;

@end


@implementation L0SlideAppDelegate

- (void) slidePeer:(L0SlidePeer*) peer willBeSentItem:(L0SlideItem*) item;
{
	// ignore
}

- (void) slidePeer:(L0SlidePeer*) peer wasSentItem:(L0SlideItem*) item;
{
	[self.tableController returnItemToTableAfterSend:item toPeer:peer];
}

- (void) slidePeerWillSendUsItem:(L0SlidePeer*) peer;
{
	// ignore
}
- (void) slidePeer:(L0SlidePeer*) peer didSendUsItem:(L0SlideItem*) item;
{
	[item store];
	[self.tableController addItem:item comingFromPeer:peer];
}

- (void) peerFound:(L0SlidePeer*) peer;
{
	peer.delegate = self;
	[self.tableController addPeerIfSpaceAllows:peer];
}

- (IBAction) testBySendingItemToAnyPeer;
{
}

- (void) peerLeft:(L0SlidePeer*) peer;
{
	[self.tableController removePeer:peer];
}

@synthesize window, toolbar;

- (void) applicationDidFinishLaunching:(UIApplication *) application;
{
	[L0ImageItem registerClass];
	
	L0BonjourPeeringService* bonjourFinder = [L0BonjourPeeringService sharedFinder];
	bonjourFinder.delegate = self;
	[bonjourFinder start];
	
	self.tableController = [[[L0SlideItemsTableController alloc] initWithDefaultNibName] autorelease];
	
	NSMutableArray* itemsArray = [self.toolbar.items mutableCopy];
	[itemsArray addObject:self.tableController.editButtonItem];
	self.toolbar.items = itemsArray;
	[itemsArray release];
    
	self.tableController.view.frame = tableHostView.bounds;
	[tableHostView addSubview:self.tableController.view];
	[window makeKeyAndVisible];
}

@synthesize tableController, tableHostView;

- (void) dealloc;
{
	[toolbar release];
	[tableHostView release];
	[tableController release];
    [window release];
    [super dealloc];
}

- (IBAction) addItem;
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
		return;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	CGPoint center = self.toolbar.center;
	center.y += self.toolbar.bounds.size.height;
	self.toolbar.center = center;
	
	[UIView commitAnimations];
	
	self.toolbar.userInteractionEnabled = NO;
	
	UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init] autorelease];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = self;
	[self.tableController presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
{
	L0ImageItem* item = [[L0ImageItem alloc] initWithTitle:@"Image" image:image];
	[self.tableController addItem:item animation:kL0SlideItemsTableAddFromSouth];
	[item release];
	
	[picker dismissModalViewControllerAnimated:YES];
	[self _showToolbar];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
	[picker dismissModalViewControllerAnimated:YES];
	[self _showToolbar];
}

- (void) _showToolbar;
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	CGPoint center = self.toolbar.center;
	center.y -= self.toolbar.bounds.size.height;
	self.toolbar.center = center;
	
	[UIView commitAnimations];
	
	self.toolbar.userInteractionEnabled = YES;
}

@end
