//
//  L0MoverAppDelegate+L0UITestingHooks.m
//  Mover
//
//  Created by ∞ on 11/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverAppDelegate+L0UITestingHooks.h"


#if DEBUG
@implementation L0MoverAppDelegate (L0UITestingHooks)

- (void) testWelcomeAlert;
{
	[[UIAlertView alertNamed:@"L0MoverWelcome"] performSelector:@selector(show) withObject:nil afterDelay:1.0];
}

- (void) testContactTutorialAlert;
{
	[[UIAlertView alertNamed:@"L0ContactReceived"] performSelector:@selector(show) withObject:nil afterDelay:1.0];
}

- (void) testImageTutorialAlert;
{
	[[UIAlertView alertNamed:@"L0ImageReceived_iPhone"] performSelector:@selector(show) withObject:nil afterDelay:1.0];
}

- (void) testImageTutorialAlert_iPod;
{
	[[UIAlertView alertNamed:@"L0ImageReceived_iPod"] performSelector:@selector(show) withObject:nil afterDelay:1.0];
}

- (void) testNewVersionAlert;
{
	[self performSelector:@selector(displayNewVersionAlertWithVersion:) withObject:@"2.5" afterDelay:1.0];
}

- (void) testNetworkBecomingUnavailable; // WARNING: Disables network watching, use with care.
{
	[self performSelector:@selector(_performTestNetworkUnavailable) withObject:nil afterDelay:1.0];
}

- (void) _performTestNetworkUnavailable;
{
	[self stopWatchingNetwork];
	self.networkAvailable = NO;
}

- (void) testNetworkBecomingAvailable; // WARNING: Disables network watching, use with care.
{
	[self performSelector:@selector(_performTestNetworkAvailable) withObject:nil afterDelay:1.0];
}

- (void) _performTestNetworkAvailable;
{
	[self stopWatchingNetwork];
	self.networkAvailable = YES;
}

@end
#endif