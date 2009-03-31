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

@implementation L0SlideAppDelegate

@synthesize window;

- (void) beamingPeer:(L0SlidePeer*) peer willSendItem:(L0SlideItem*) item;
{
	// ignore
}

- (void) beamingPeer:(L0SlidePeer*) peer didSendItem:(L0SlideItem*) item;
{
	[self.tableController returnItemToTableAfterSend:item toPeer:peer];
}

- (void) beamingPeerWillReceiveItem:(L0SlidePeer*) peer;
{
	// ignore
}
- (void) beamingPeer:(L0SlidePeer*) peer didReceiveItem:(L0SlideItem*) item;
{
	[self.tableController addItem:item comingFromPeer:peer];
}

- (void) peerFound:(L0SlidePeer*) peer;
{
	peer.delegate = self;
	[self.tableController addPeerIfSpaceAllows:peer];

	if (!peers)
		peers = [NSMutableSet new];
	[peers addObject:peer];
}

- (IBAction) testBySendingItemToAnyPeer;
{
	L0SlidePeer* peer = [peers anyObject];
	L0ImageItem* image = [[L0ImageItem alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]];
	[peer beginBeamingItem:image];
	[image release];
}

- (void) peerLeft:(L0SlidePeer*) peer;
{
	[self.tableController removePeer:peer];
}

- (void) applicationDidFinishLaunching:(UIApplication *) application;
{
	[L0ImageItem registerClass];
	
	L0BonjourPeeringService* bonjourFinder = [L0BonjourPeeringService sharedFinder];
	bonjourFinder.delegate = self;
	[bonjourFinder start];
	
	self.tableController = [[[L0SlideItemsTableController alloc] initWithDefaultNibName] autorelease];
    
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
	static int i = 0;
	
	L0ImageItem* images[] = {
		[[[L0ImageItem alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]] autorelease],
		[[[L0ImageItem alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]] autorelease],
		[[[L0ImageItem alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]] autorelease],
		[[[L0ImageItem alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]] autorelease],
		[[[L0ImageItem alloc] initWithTitle:@"Test" image:[UIImage imageNamed:@"IMG_0192.JPG"]] autorelease],
	};
	
	L0SlideItemsTableAddAnimation animations[] = {
		kL0SlideItemsTableAddFromSouth,
		kL0SlideItemsTableAddFromEast,
		kL0SlideItemsTableAddFromWest,
		kL0SlideItemsTableAddFromNorth,
		kL0SlideItemsTableAddByDropping
	};
	
	[self.tableController addItem:images[i] animation:animations[i]];
	i++; if (i >= 5) i = 0;
}

@end
