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

@end
