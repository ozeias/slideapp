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

#import "L0MoverItemsTableController.h"
#import "L0PeerDiscovery.h"
#import "L0MoverPeer.h"

@interface L0MoverAppDelegate : NSObject <UIApplicationDelegate, L0PeerDiscoveryDelegate, L0MoverPeerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	
	L0MoverItemsTableController* tableController;
	UIView* tableHostView;
	L0FlipViewController* tableHostController;
	
	NSString* documentsDirectory;
	
	UIToolbar* toolbar;
	UIView* networkUnavailableView;
	CGPoint networkUnavailableViewStartingPosition;
	
	double lastSeenVersion;
}

@property(retain) IBOutlet UIWindow *window;
@property(retain) IBOutlet UIView* tableHostView;
@property(retain) IBOutlet UIToolbar* toolbar;

@property(retain) IBOutlet L0FlipViewController* tableHostController;
@property(retain) L0MoverItemsTableController* tableController;

- (IBAction) addItem;
- (void) addImageItem;
- (void) takeAPhotoAndAddImageItem;
- (void) addAddressBookItem;

- (IBAction) testBySendingItemToAnyPeer;

@property(readonly, copy) NSString* documentsDirectory;

- (void) beginWatchingNetwork;
- (void) checkNetwork;
- (void) updateNetworkWithFlags:(SCNetworkReachabilityFlags) flags;

@property(retain) IBOutlet UIView* networkUnavailableView;

@end
