//
//  L0MoverImageViewer.m
//  Mover
//
//  Created by ∞ on 16/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverImageViewer.h"

@interface L0MoverImageViewer ()
- (void) clearOutlets;
@end


@implementation L0MoverImageViewer

- (id) initWithImage:(UIImage*) i;
{
	if (self = [super initWithNibName:@"L0MoverImageViewer" bundle:nil]) {
		self.image = i;
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)] autorelease];
	}
	
	return self;
}

- (void) dealloc;
{
	[self clearOutlets];
	[image release];
	[super dealloc];
}

@synthesize imageView, scrollView, image;

- (void) viewDidLoad;
{
    [super viewDidLoad];
	self.imageView.image = self.image;
}

- (void) viewWillAppear:(BOOL) ani;
{
	[super viewWillAppear:ani];
	self.imageView.frame = self.imageView.superview.bounds;
	self.scrollView.contentSize = self.imageView.frame.size;
	self.scrollView.minimumZoomScale = 1.0;
	self.scrollView.maximumZoomScale = 2.5;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
	[self.scrollView setZoomScale:1.0 animated:NO];
#endif
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView*) scrollView;
{
	return self.imageView;
}

- (void) dismiss;
{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) o;
{
	return o == UIInterfaceOrientationPortrait;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
- (void) viewDidUnload;
{
	[self clearOutlets];
}
#else
- (void) setView:(UIView*) v;
{
	if (!v)
		[self clearOutlets];
	[super setView:v];
}
#endif

- (void) clearOutlets;
{
	self.imageView = nil;
	self.scrollView = nil;
}

@end
