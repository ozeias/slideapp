//
//  ShardAppDelegate.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "L0SlideAppDelegate.h"
#import "L0ImageItem.h"
#import "L0AddressBookPersonItem.h"
#import "L0BonjourPeeringService.h"
#import "L0SlideAppDelegate+L0ItemPersistance.h"
#import "L0SlideAppDelegate+L0HelpAlerts.h"

#import <netinet/in.h>

@interface L0SlideAppDelegate ()

- (void) _returnFromImagePicker;
@property(copy, setter=_setDocumentsDirectory:) NSString* documentsDirectory;

@end


@implementation L0SlideAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication *) application;
{
	// Registering item subclasses.
	[L0ImageItem registerClass];
	[L0AddressBookPersonItem registerClass];
	
	// Starting up peering services.
	L0BonjourPeeringService* bonjourFinder = [L0BonjourPeeringService sharedService];
	bonjourFinder.delegate = self;
	[bonjourFinder start];
	
	// Setting up the UI.
	self.tableController = [[[L0SlideItemsTableController alloc] initWithDefaultNibName] autorelease];
	
	NSMutableArray* itemsArray = [self.toolbar.items mutableCopy];
	[itemsArray addObject:self.tableController.editButtonItem];
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self.tableHostController action:@selector(showBack) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem* infoButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
	[itemsArray addObject:infoButtonItem];
	self.toolbar.items = itemsArray;
	[itemsArray release];
    
	[tableHostView addSubview:self.tableController.view];
	[window addSubview:self.tableHostController.view];
	
	// Loading persisted items from disk. (Later, so we avoid the AB constant bug.)
	[self performSelector:@selector(addPersistedItemsToTable) withObject:nil afterDelay:0.05];
	
	// Go!
	[window makeKeyAndVisible];
	
	// Be helpful if this is the first time (ahem).
	[self showAlertIfNotShownBeforeNamed:@"L0SlideWelcome"];
	
	networkUnavailableViewStartingPosition = self.networkUnavailableView.center;
	[self beginWatchingNetwork];
}

#pragma mark -
#pragma mark Reachability

static SCNetworkReachabilityRef reach = NULL;

static void L0SlideAppDelegateNetworkStateChanged(SCNetworkReachabilityRef reach, SCNetworkReachabilityFlags flags, void* nothing) {
	L0SlideAppDelegate* myself = (L0SlideAppDelegate*) UIApp.delegate;
	[NSObject cancelPreviousPerformRequestsWithTarget:myself selector:@selector(checkNetwork) object:nil];
	[myself updateNetworkWithFlags:flags];
}

@synthesize networkUnavailableView;

- (void) beginWatchingNetwork;
{
	if (reach) return;
	
	// What follows comes from Reachability.m.
	// Basically, we look for reachability for the link-local address --
	// and filter for WWAN or connection-required responses in -updateNetworkWithFlags:.
	
	// Build a sockaddr_in that we can pass to the address reachability query.
	struct sockaddr_in sin;
	bzero(&sin, sizeof(sin));
	sin.sin_len = sizeof(sin);
	sin.sin_family = AF_INET;
	
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	sin.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	
	reach = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*) &sin);
	
	SCNetworkReachabilityContext emptyContext = {0, self, NULL, NULL, NULL};
	SCNetworkReachabilitySetCallback(reach, &L0SlideAppDelegateNetworkStateChanged, &emptyContext);
	SCNetworkReachabilityScheduleWithRunLoop(reach, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
	
	SCNetworkReachabilityFlags flags;
	if (!SCNetworkReachabilityGetFlags(reach, &flags))
		[self performSelector:@selector(checkNetwork) withObject:nil afterDelay:0.5];
	else
		[self updateNetworkWithFlags:flags];
}

- (void) checkNetwork;
{
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reach, &flags))
		[self updateNetworkWithFlags:flags];
}

- (void) updateNetworkWithFlags:(SCNetworkReachabilityFlags) flags;
{
	BOOL habemusNetwork = 
		(flags & kSCNetworkReachabilityFlagsReachable) &&
		!(flags & kSCNetworkReachabilityFlagsConnectionRequired);
	// note that unlike Reachability.m we don't care about WWANs.
	
	if (habemusNetwork) {
		L0Log(@"We have network!");
		
		// update UI for network. Huzzah!
		if (self.networkUnavailableView.alpha > 0) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			
			self.networkUnavailableView.alpha = 0.0;
			CGPoint position = self.networkUnavailableView.center;
			position.y =
				self.networkUnavailableView.superview.frame.size.height +
				self.networkUnavailableView.superview.frame.size.height;
			self.networkUnavailableView.center = position;
			
			[UIView commitAnimations];
		}
	} else {
		L0Log(@"No network!");

		// disable UI for no network. Boo, user, boo!
		if (self.networkUnavailableView.alpha == 0) {
			CGPoint position = self.networkUnavailableView.center;
			position.y =
				self.networkUnavailableView.superview.frame.size.height +
				self.networkUnavailableView.superview.frame.size.height;
			self.networkUnavailableView.center = position;
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			
			self.networkUnavailableView.alpha = 1.0;
			self.networkUnavailableView.center = networkUnavailableViewStartingPosition;
			
			[UIView commitAnimations];
		}
		
		// clear all peers off the table. TODO: only Bonjour peers!
		self.tableController.northPeer = nil;
		self.tableController.eastPeer = nil;
		self.tableController.westPeer = nil;
	}
}

#pragma mark -
#pragma mark Other methods

- (void) addPersistedItemsToTable;
{
	for (L0SlideItem* i in [self loadItemsFromMassStorage])
		[self.tableController addItem:i animation:kL0SlideItemsTableNoAddAnimation];
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
	[self.tableController beginWaitingForItemComingFromPeer:peer];
}
- (void) slidePeer:(L0SlidePeer*) peer didSendUsItem:(L0SlideItem*) item;
{
	L0Log(@"Received %@", item);
	[item storeToAppropriateApplication];
	[self.tableController addItem:item comingFromPeer:peer];
	
	if ([item isKindOfClass:[L0ImageItem class]])
		[self showAlertIfNotShownBeforeNamedForiPhone:@"L0ImageReceived_iPhone" foriPodTouch:@"L0ImageReceived_iPodTouch"];
	else if ([item isKindOfClass:[L0AddressBookPersonItem class]])
		[self showAlertIfNotShownBeforeNamed:@"L0ContactReceived"];
}
- (void) slidePeerDidCancelSendingUsItem:(L0SlidePeer*) peer;
{
	[self.tableController stopWaitingForItemFromPeer:peer];
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
	[self.tableController setEditing:NO animated:YES];
	
	UIActionSheet* sheet = [[UIActionSheet new] autorelease];
	sheet.delegate = self;
	[sheet addButtonWithTitle:NSLocalizedString(@"Add Image", @"Image/Contact image button")];
	[sheet addButtonWithTitle:NSLocalizedString(@"Add Contact", @"Image/Contact contact button")];
	NSInteger i = [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Image/Contact cancel button")];
	sheet.cancelButtonIndex = i;

	[sheet showInView:self.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	switch (buttonIndex) {
		case 0:
			[self addImageItem];
			break;
		case 1:
			[self addAddressBookItem];
			break;
		default:
			break;
	}
}

- (void) addAddressBookItem;
{
	ABPeoplePickerNavigationController* picker = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	picker.peoplePickerDelegate = self;
	[self.tableHostController presentModalViewController:picker animated:YES];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
{
	L0AddressBookPersonItem* item = [[L0AddressBookPersonItem alloc] initWithAddressBookRecord:person];
	[self.tableController addItem:item animation:kL0SlideItemsTableAddFromSouth];
	[item release];
	
	[peoplePicker dismissModalViewControllerAnimated:YES];
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
{
	return [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}

- (void) addImageItem;
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
		return;
	
	UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init] autorelease];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = self;
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
}

@end
