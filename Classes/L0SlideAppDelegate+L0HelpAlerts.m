//
//  L0SlideAppDelegate+L0HelpAlerts.m
//  Slide
//
//  Created by ∞ on 11/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideAppDelegate+L0HelpAlerts.h"

#import <MuiKit/MuiKit.h>

@implementation L0SlideAppDelegate (L0HelpAlerts)

- (void) showAlertIfNotShownBeforeNamed:(NSString*) name;
{
	// the first method returns nil if the alert was already
	// shown.
	[[self alertIfNotShownBeforeNamed:name] show];
}

- (UIAlertView*) alertIfNotShownBeforeNamed:(NSString*) name;
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* key = [NSString stringWithFormat:@"L0HelpAlertShown_%@", name];
	
	if (![ud boolForKey:key]) {
		UIAlertView* alert = [UIAlertView alertNamed:name];
		[ud setBool:YES forKey:key];
		return alert;
	} else
		return nil;
}

// Device-dependent alerts.

- (UIAlertView*) alertIfNotShownBeforeNamedForiPhone:(NSString*) iPhoneName foriPodTouch:(NSString*) iPodTouchName;
{
	if ([UIDevice currentDevice].deviceFamily == kL0DeviceFamily_iPodTouch)
		return [self alertIfNotShownBeforeNamed:iPodTouchName];
	else
		return [self alertIfNotShownBeforeNamed:iPhoneName];
}

- (void) showAlertIfNotShownBeforeNamedForiPhone:(NSString*) iPhoneName foriPodTouch:(NSString*) iPodTouchName;
{
	[[self alertIfNotShownBeforeNamedForiPhone:iPhoneName foriPodTouch:iPodTouchName] show];
}

@end
