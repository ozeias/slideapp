//
//  ShardAppDelegate.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0SlideItemsTableController.h"
#import "L0PeerDiscovery.h"
#import "L0SlidePeer.h"

@interface L0SlideAppDelegate : NSObject <UIApplicationDelegate, L0PeerDiscoveryDelegate, L0SlidePeerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
	
	L0SlideItemsTableController* tableController;
	UIView* tableHostView;
	UIViewController* tableHostController;
	
	NSString* documentsDirectory;
	
	UIToolbar* toolbar;
}

@property(retain) IBOutlet UIWindow *window;
@property(retain) IBOutlet UIView* tableHostView;
@property(retain) IBOutlet UIToolbar* toolbar;

@property(retain) IBOutlet UIViewController* tableHostController;
@property(retain) L0SlideItemsTableController* tableController;

- (IBAction) addItem;

- (IBAction) testBySendingItemToAnyPeer;

@property(readonly, copy) NSString* documentsDirectory;

@end

