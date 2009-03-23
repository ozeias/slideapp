//
//  L0BeamableItemsTableController.m
//  Shard
//
//  Created by ∞ on 22/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0BeamableItemsTableController.h"
#import "L0BeamableItemView.h"

const CGAffineTransform L0CounterclockwiseQuarterTurnRotationTransform = {
	0, -1,
	1, 0,
	0, 0
};

const CGAffineTransform L0ClockwiseQuarterTurnRotationTransform = {
	0, 1,
	-1, 0,
	0, 0
};

static inline CGFloat L0DistanceBetweenPoints(CGPoint from, CGPoint to) {
	return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2));
}

// Returns an angle in radians between that would be between -30° and 30°.
static CGFloat L0RandomSlideRotation() {
	double zeroToOneRandom = random() / (double) LONG_MAX;
	return (zeroToOneRandom * M_PI / 3.0) - M_PI / 6.0;
}

@implementation L0BeamableItemsTableController

- (id) initWithDefaultNibName;
{
	srandomdev();
	
	if (self = [self initWithNibName:@"L0BeamableItemsTable" bundle:nil]) {
		itemsToViews = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	}
	
	return self;
}

- (void) viewDidLoad;
{
    [super viewDidLoad];
	
	self.eastLabel.transform = L0ClockwiseQuarterTurnRotationTransform;
	self.westLabel.transform = L0CounterclockwiseQuarterTurnRotationTransform;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

@synthesize northArrowView, eastArrowView, westArrowView;
@synthesize northLabel, eastLabel, westLabel;

- (void) clearOutlets;
{
	self.northArrowView = nil;
	self.eastArrowView = nil;
	self.westArrowView = nil;
	
	self.northLabel = nil;
	self.eastLabel = nil;
	self.westLabel = nil;
}

- (void) viewDidUnload;
{
	[self clearOutlets];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000
- (void) setView:(UIView*) v;
{
	if (!v)
		[self clearOutlets];
	
	[super setView:v];
}
#endif

- (void) dealloc;
{
	CFRelease(itemsToViews);
	[self clearOutlets];
    [super dealloc];
}

- (void) addItem:(L0BeamableItem*) item animation:(L0BeamableItemsTableAddAnimation) a;
{
	if (CFDictionaryGetValue(itemsToViews, item))
		return;
	
	L0BeamableItemView* view = [[L0BeamableItemView alloc] initWithFrame:CGRectZero];
	[view sizeToFit];
	view.delegate = self;
	view.transform = CGAffineTransformMakeRotation(L0RandomSlideRotation());
	[view displayWithContentsOfItem:item];
	CFDictionarySetValue(itemsToViews, item, view);

	switch (a) {
		case kL0BeamableItemsTableAddFromSouth: {
			CGRect selfFrame = self.view.frame;
			CGRect itemViewFrame = view.frame;
			
			// this is conservative: side * sqrt(2) is for 45°-rotated views. still.
			CGFloat belowSouthCenterY = selfFrame.size.height + itemViewFrame.size.height * sqrt(2);
			view.center = CGPointMake(selfFrame.size.width / 2, belowSouthCenterY);
			[self.view addSubview:view];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			
			CGFloat randomOffset = 20 * (random() / (double) LONG_MAX) * (random() & 1? 1 : -1);
			view.center = CGPointMake(view.center.x + randomOffset, 2 * selfFrame.size.height / 3.0);
			
			[UIView commitAnimations];
			break;
		}
			
		case kL0BeamableItemsTableNoAddAnimation:
		default: {
			[self.view addSubview:view];
			break;
		}
	}
	
	
}

- (void) removeItem:(L0BeamableItem*) item;
{
	L0BeamableItemView* view = (L0BeamableItemView*) CFDictionaryGetValue(itemsToViews, item);
	if (!view)
		return;
	
	[view removeFromSuperview];
	CFDictionaryRemoveValue(itemsToViews, item);
}

@end
