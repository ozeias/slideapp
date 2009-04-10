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
#import "L0SlideAppDelegate+L0ItemPersistance.h"

@interface L0SlideAppDelegate ()

- (void) _returnFromImagePicker;
@property(copy, setter=_setDocumentsDirectory:) NSString* documentsDirectory;

@end


@implementation L0SlideAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication *) application;
{
	// Registering item subclasses.
	[L0ImageItem registerClass];
	
	// Starting up peering services.
	L0BonjourPeeringService* bonjourFinder = [L0BonjourPeeringService sharedService];
	bonjourFinder.delegate = self;
	[bonjourFinder start];
	
	// Setting up the UI.
	self.tableController = [[[L0SlideItemsTableController alloc] initWithDefaultNibName] autorelease];
	
	NSMutableArray* itemsArray = [self.toolbar.items mutableCopy];
	[itemsArray addObject:self.tableController.editButtonItem];
	self.toolbar.items = itemsArray;
	[itemsArray release];
    
	[tableHostView addSubview:self.tableController.view];
	[window addSubview:self.tableHostController.view];
	
	// Loading persisted items from disk.
	for (L0SlideItem* i in [self loadItemsFromMassStorage])
		[self.tableController addItem:i animation:kL0SlideItemsTableNoAddAnimation];
	
	// Go!
	[window makeKeyAndVisible];
}

- (void) applicationWillTerminate:(UIApplication*) app;
{
	[self persistItemsToMassStorage:[self.tableController items]];
}

- (void) slidePeer:(L0SlidePeer*) peer willBeSentItem:(L0SlideItem*) item;
{
	L0Log(@"About to send item %@", item);
}

- (void) slidePeer:(L0SlidePeer*) peer wasSentItem:(L0SlideItem*) item;
{
	L0Log(@"Sent %@", item);
	[self.tableController returnItemToTableAfterSend:item toPeer:peer];
}

- (void) slidePeerWillSendUsItem:(L0SlidePeer*) peer;
{
	L0Log(@"Receiving from %@", peer);
	[self.tableController itemComingFromPeer:peer];
}
- (void) slidePeer:(L0SlidePeer*) peer didSendUsItem:(L0SlideItem*) item;
{
	L0Log(@"Received %@", item);
	[item storeToAppropriateApplication];
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
@synthesize tableController, tableHostView, tableHostController;

- (void) dealloc;
{
	[toolbar release];
	[tableHostView release];
	[tableHostController release];
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
	[self.tableController setEditing:NO animated:YES];
	[self.tableHostController presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
{
	L0ImageItem* item = [[L0ImageItem alloc] initWithTitle:@"" image:image];	
	[self.tableController addItem:item animation:kL0SlideItemsTableAddFromSouth];
	[item release];
	
	[picker dismissModalViewControllerAnimated:YES];
	[self _returnFromImagePicker];
}

@synthesize documentsDirectory;
- (NSString*) documentsDirectory;
{
	if (!documentsDirectory) {
		NSArray* docsDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSAssert([docsDirs count] > 0, @"At least one documents directory is known");
		self.documentsDirectory = [docsDirs objectAtIndex:0];
	}
	
	return documentsDirectory;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
	[picker dismissModalViewControllerAnimated:YES];
	[self _returnFromImagePicker];
}

- (void) _returnFromImagePicker;
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	CGPoint center = self.toolbar.center;
	center.y -= self.toolbar.bounds.size.height;
	self.toolbar.center = center;
	
	[UIView commitAnimations];
	
	self.toolbar.userInteractionEnabled = YES;
}

@end
