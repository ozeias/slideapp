//
//  ShardAppDelegate.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0BeamableItemsTableController.h"

@interface L0ShardAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	L0BeamableItemsTableController* tableController;
	UIView* tableHostView;
}

@property(retain) IBOutlet UIWindow *window;
@property(retain) IBOutlet UIView* tableHostView;

@property(retain) L0BeamableItemsTableController* tableController;

- (IBAction) addItem;

@end

