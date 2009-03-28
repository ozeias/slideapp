//
//  ShardAppDelegate.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0BeamableItemsTableController.h"
#import "L0PeerDiscovery.h"
#import "L0BeamingPeer.h"

@interface L0ShardAppDelegate : NSObject <UIApplicationDelegate, L0PeerDiscoveryDelegate, L0BeamingPeerDelegate> {
    UIWindow *window;
	L0BeamableItemsTableController* tableController;
	UIView* tableHostView;
	
	NSMutableSet* peers;
}

@property(retain) IBOutlet UIWindow *window;
@property(retain) IBOutlet UIView* tableHostView;

@property(retain) L0BeamableItemsTableController* tableController;

- (IBAction) addItem;

- (IBAction) testBySendingItemToAnyPeer;

@end

