//
//  ShardAppDelegate.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "L0ShardAppDelegate.h"
#import "L0BeamableImage.h"
#import "L0BonjourPeerFinder.h"

@implementation L0ShardAppDelegate

@synthesize window;

- (void) beamingPeer:(L0BeamingPeer*) peer willSendItem:(L0BeamableItem*) item;
{
	// ignore
}

- (void) beamingPeer:(L0BeamingPeer*) peer didSendItem:(L0BeamableItem*) item;
{
	[self.tableController returnItemToTableAfterSend:item];
}

- (void) beamingPeerWillReceiveItem:(L0BeamingPeer*) peer;
{
	// ignore
}
- (void) beamingPeer:(L0BeamingPeer*) peer didReceiveItem:(L0BeamableItem*) item;
{
	[self.tableController addItem:item comingFromPeer:peer];
}

- (void) peerFound:(L0BeamingPeer*) peer;
{
	peer.delegate = self;
	[self.tableController addPeerIfSpaceAllows:peer];

	if (!peers)
		peers = [NSMutableSet new];
	[peers addObject:peer];
}

- (IBAction) testBySendingItemToAnyPeer;
{
	L0BeamingPeer* peer = [peers anyObject];
	L0BeamableImage* image = [[L0BeamableImage alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]];
	[peer beginBeamingItem:image];
	[image release];
}

- (void) peerLeft:(L0BeamingPeer*) peer;
{
	[self.tableController removePeer:peer];
}

- (void) applicationDidFinishLaunching:(UIApplication *) application;
{
	[L0BeamableImage registerClass];
	
	L0BonjourPeerFinder* bonjourFinder = [L0BonjourPeerFinder sharedFinder];
	bonjourFinder.delegate = self;
	[bonjourFinder beginPeering];
	
	self.tableController = [[[L0BeamableItemsTableController alloc] initWithDefaultNibName] autorelease];
    
	self.tableController.view.frame = tableHostView.bounds;
	[tableHostView addSubview:self.tableController.view];
	[window makeKeyAndVisible];
}

@synthesize tableController, tableHostView;

- (void) dealloc;
{
	[tableHostView release];
	[tableController release];
    [window release];
    [super dealloc];
}

- (IBAction) addItem;
{
	L0BeamableImage* image = [[L0BeamableImage alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]];
	[self.tableController addItem:image animation:kL0BeamableItemsTableAddFromSouth];
	[image release];
}

@end
