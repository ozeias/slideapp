//
//  ShardAppDelegate.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "L0ShardAppDelegate.h"
#import "L0BeamableImage.h"

@implementation L0ShardAppDelegate

@synthesize window;


- (void) applicationDidFinishLaunching:(UIApplication *) application;
{    

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
