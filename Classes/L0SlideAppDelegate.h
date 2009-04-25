//
//  ShardAppDelegate.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "L0SlideItemsTableController.h"
#import "L0PeerDiscovery.h"
#import "L0SlidePeer.h"

@interface L0SlideAppDelegate : NSObject <UIApplicationDelegate, L0PeerDiscoveryDelegate, L0SlidePeerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate> {
    UIWindow *window;
	
	L0SlideItemsTableController* tableController;
	UIView* tableHostView;
	L0FlipViewController* tableHostController;
	
	NSString* documentsDirectory;
	
	UIToolbar* toolbar;
	UIView* networkUnavailableView;
	CGPoint networkUnavailableViewStartingPosition;
}

@property(retain) IBOutlet UIWindow *window;
@property(retain) IBOutlet UIView* tableHostView;
@property(retain) IBOutlet UIToolbar* toolbar;

@property(retain) IBOutlet L0FlipViewController* tableHostController;
@property(retain) L0SlideItemsTableController* tableController;

- (IBAction) addItem;
- (void) addImageItem;
- (void) addAddressBookItem;

- (IBAction) testBySendingItemToAnyPeer;

@property(readonly, copy) NSString* documentsDirectory;

- (void) beginWatchingNetwork;
- (void) checkNetwork;
- (void) updateNetworkWithFlags:(SCNetworkReachabilityFlags) flags;

@property(retain) IBOutlet UIView* networkUnavailableView;

@end

