//
//  L0MoverAppDelegate+L0HelpAlerts.h
//  Slide
//
//  Created by ∞ on 11/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "L0MoverAppDelegate.h"

@interface L0MoverAppDelegate (L0HelpAlerts)

- (void) showAlertIfNotShownBeforeNamed:(NSString*) name;
- (UIAlertView*) alertIfNotShownBeforeNamed:(NSString*) name;

- (UIAlertView*) alertIfNotShownBeforeNamedForiPhone:(NSString*) iPhoneName foriPodTouch:(NSString*) iPodTouchName;
- (void) showAlertIfNotShownBeforeNamedForiPhone:(NSString*) iPhoneName foriPodTouch:(NSString*) iPodTouchName;

@end
