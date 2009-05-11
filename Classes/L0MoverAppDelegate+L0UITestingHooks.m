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
	[self performSelector:@selector(performTestNetworkUnavailable) withObject:nil afterDelay:1.0];
}

- (void) performTestNetworkUnavailable;
{
	[self beginTestingModeBannerAnimation];
	[self stopWatchingNetwork];
	self.networkAvailable = NO;
}

- (void) testNetworkBecomingAvailable; // WARNING: Disables network watching, use with care.
{
	[self performSelector:@selector(performTestNetworkAvailable) withObject:nil afterDelay:1.0];
}

- (void) performTestNetworkAvailable;
{
	[self beginTestingModeBannerAnimation];
	[self stopWatchingNetwork];
	self.networkAvailable = YES;
}

- (void) testByPerformingAlertParade; // WARNING: Disables network watching, use with care.
{
	[self performSelector:@selector(beginTestingModeBannerAnimation) withObject:nil afterDelay:0.01];
	[self performSelector:@selector(testWelcomeAlert) withObject:nil afterDelay:0.02];
	[self performSelector:@selector(testContactTutorialAlert) withObject:nil afterDelay:5.0];
	[self performSelector:@selector(testImageTutorialAlert) withObject:nil afterDelay:10.0];
	[self performSelector:@selector(testImageTutorialAlert_iPod) withObject:nil afterDelay:15.0];
	[self performSelector:@selector(testNewVersionAlert) withObject:nil afterDelay:20.0];
	[self performSelector:@selector(testNetworkBecomingUnavailable) withObject:nil afterDelay:25.0];
	[self performSelector:@selector(testNetworkBecomingAvailable) withObject:nil afterDelay:30.0];
}

- (void) beginTestingModeBannerAnimation;
{
	static BOOL isInTestingMode = NO;
	
	if (!isInTestingMode) {
		[[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(switchStatusBarColorForTestingModeAnimation:) userInfo:nil repeats:YES] retain];
		isInTestingMode = YES;
	}
}

- (void) switchStatusBarColorForTestingModeAnimation:(NSTimer*) t;
{
	static BOOL black = NO;
	UIStatusBarStyle style = black? UIStatusBarStyleDefault : UIStatusBarStyleBlackOpaque;
	black = !black;
	[UIApp setStatusBarStyle:style animated:YES];
}

@end
#endif