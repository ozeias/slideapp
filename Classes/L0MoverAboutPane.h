//
//  L0SlideAboutPane.h
//  Slide
//
//  Created by ∞ on 11/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class L0SlideAboutCopyrightWebPane;

@interface L0MoverAboutPane : UIViewController {
	IBOutlet UILabel* versionLabel;
	IBOutlet L0SlideAboutCopyrightWebPane* copyrightPane;
}

@property(assign) IBOutlet UILabel* versionLabel;
@property(retain) L0SlideAboutCopyrightWebPane* copyrightPane;

- (IBAction) showAboutCopyrightWebPane;
- (IBAction) openInfiniteLabsDotNet;

@end

@interface L0SlideAboutCopyrightWebPane : UIViewController <UIWebViewDelegate> {
	UIWebView* webView;
}

@property(retain) UIWebView* webView;

@end
