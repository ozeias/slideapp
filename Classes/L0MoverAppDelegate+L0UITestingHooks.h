//
//  L0MoverAppDelegate+L0UITestingHooks.h
//  Mover
//
//  Created by ∞ on 11/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define L0MoverAppDelegateAllowFriendMethods 1
#import "L0MoverAppDelegate.h"


#if DEBUG
@interface L0MoverAppDelegate (L0UITestingHooks)


- (void) testWelcomeAlert;
- (void) testContactTutorialAlert;
- (void) testImageTutorialAlert;
- (void) testImageTutorialAlert_iPod;
- (void) testNewVersionAlert;
- (void) testNetworkBecomingUnavailable; // WARNING: Disables network watching, use with care.
- (void) testNetworkBecomingAvailable; // WARNING: Disables network watching, use with care.

// Performs all of the above 5s one from the other.
- (void) testByPerformingAlertParade; // WARNING: Disables network watching, use with care.

// If the app is in "testing mode" (ie we've clobbered it beyond recognition by using the test... methods above
// and it needs a restart to return behaving like it does in normal operation)
// then we make the status bar flash between black opaque and normal to indicate it.
- (void) beginTestingModeBannerAnimation;

@end
#endif
