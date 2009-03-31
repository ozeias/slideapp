//
//  L0BeamableItemsTableController.m
//  Shard
//
//  Created by ∞ on 22/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideItemsTableController.h"
#import "L0SlideItemView.h"

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

static inline void L0AnimateSlideEntranceFromOffscreenPoint(L0SlideItemsTableController* self, UIView* view, CGPoint comingFrom, CGPoint goingTo) {
	view.center = comingFrom;
	[self.view addSubview:view];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:1.0];
	
	CGFloat randomOffsetX = 20 * (random() / (double) LONG_MAX) * (random() & 1? 1 : -1);
	CGFloat randomOffsetY = 20 * (random() / (double) LONG_MAX) * (random() & 1? 1 : -1);
	view.center = CGPointMake(goingTo.x + randomOffsetX, goingTo.y + randomOffsetY);
	
	[UIView commitAnimations];	
}

@implementation L0SlideItemsTableController

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
	
	self.northLabel.alpha = 0;
	self.eastLabel.alpha = 0;
	self.westLabel.alpha = 0;
	
	self.northArrowView.alpha = 0;
	self.eastArrowView.alpha = 0;
	self.westArrowView.alpha = 0;
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

- (void) addItem:(L0SlideItem*) item animation:(L0SlideItemsTableAddAnimation) a;
{
	if (CFDictionaryGetValue(itemsToViews, item))
		return;
	
	L0SlideItemView* view = [[L0SlideItemView alloc] initWithFrame:CGRectZero];
	[view sizeToFit];
	view.delegate = self;
	view.transform = CGAffineTransformMakeRotation(L0RandomSlideRotation());
	[view displayWithContentsOfItem:item];
	CFDictionarySetValue(itemsToViews, item, view);

	switch (a) {
		case kL0SlideItemsTableAddByDropping: {
			CGSize selfSize = self.view.bounds.size;
			CGRect itemViewFrame = view.frame;
			selfSize.width -= itemViewFrame.size.width / 2 - 10;
			selfSize.height -= itemViewFrame.size.height / 2 - 10;
			
			CGPoint newCenter = CGPointMake(
				(int) selfSize.width % random(),
				(int) selfSize.height % random()
			);
			
			view.center = newCenter;
			view.alpha = 0;
			CGAffineTransform currentTransform = view.transform;
			view.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(L0RandomSlideRotation()), 1.2, 1.2);
			view.userInteractionEnabled = NO;
			
			[self.view addSubview:view];
			
			[UIView beginAnimations:nil context:[view retain]];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDuration:1.0];
			
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(_addByDroppingAnimation:didFinish:forRetainedView:)];
			
			view.transform = currentTransform;
			view.alpha = 1;
			
			[UIView commitAnimations];
			
			break;
		}
			
		case kL0SlideItemsTableAddFromSouth: {
			CGRect selfFrame = self.view.frame;
			CGRect itemViewFrame = view.frame;
			
			// this is conservative: side * sqrt(2) is for 45°-rotated views. still.
			CGFloat belowSouthCenterY = selfFrame.size.height + itemViewFrame.size.height * sqrt(2);
			CGPoint comingFrom = CGPointMake(selfFrame.size.width / 2, belowSouthCenterY);
			CGPoint goingTo = CGPointMake(comingFrom.x, 2 * selfFrame.size.height / 3.0);
			
			L0AnimateSlideEntranceFromOffscreenPoint(self, view, comingFrom, goingTo);
			
			break;
		}
			
		case kL0SlideItemsTableAddFromEast: {
			CGRect selfFrame = self.view.frame;
			CGRect itemViewFrame = view.frame;
			
			CGFloat fartherThanEastX = selfFrame.size.width + itemViewFrame.size.width * sqrt(2);
			CGPoint comingFrom = CGPointMake(fartherThanEastX, selfFrame.size.height / 2);
			CGPoint goingTo = CGPointMake(2 * selfFrame.size.width / 3.0, comingFrom.y);
			
			L0AnimateSlideEntranceFromOffscreenPoint(self, view, comingFrom, goingTo);
			
			break;
		}
			
		case kL0SlideItemsTableAddFromNorth: {
			CGRect selfFrame = self.view.frame;
			CGRect itemViewFrame = view.frame;
			
			// this is conservative: side * sqrt(2) is for 45°-rotated views. still.
			CGFloat aboveNorthCenterY = -itemViewFrame.size.height * sqrt(2);
			CGPoint comingFrom = CGPointMake(selfFrame.size.width / 2, aboveNorthCenterY);
			CGPoint goingTo = CGPointMake(comingFrom.x, selfFrame.size.height / 3.0);
			
			L0AnimateSlideEntranceFromOffscreenPoint(self, view, comingFrom, goingTo);
			
			break;
		}
			
		case kL0SlideItemsTableAddFromWest: {
			CGRect selfFrame = self.view.frame;
			CGRect itemViewFrame = view.frame;
			
			CGFloat beforeWestY = -itemViewFrame.size.width * sqrt(2);
			CGPoint comingFrom = CGPointMake(beforeWestY, selfFrame.size.height / 2);
			CGPoint goingTo = CGPointMake(selfFrame.size.width / 3.0, comingFrom.y);
			
			L0AnimateSlideEntranceFromOffscreenPoint(self, view, comingFrom, goingTo);
			
			break;
		}
			
		case kL0SlideItemsTableNoAddAnimation:
		default: {
			[self.view addSubview:view];
			break;
		}
	}
	
	
}

- (void) _addByDroppingAnimation:(NSString*) ani didFinish:(BOOL) finished forRetainedView:(UIView*) retainedView;
{
	[retainedView release];
	retainedView.userInteractionEnabled = YES;
}

- (void) removeItem:(L0SlideItem*) item;
{
	L0SlideItemView* view = (L0SlideItemView*) CFDictionaryGetValue(itemsToViews, item);
	if (!view)
		return;
	
	[view removeFromSuperview];
	CFDictionaryRemoveValue(itemsToViews, item);
}

@synthesize northPeer, eastPeer, westPeer;

- (BOOL) addPeerIfSpaceAllows:(L0SlidePeer*) peer;
{
	if ([peer isEqual:self.northPeer] || [peer isEqual:self.eastPeer] || [peer isEqual:self.westPeer])
		return YES;
	
	if (!self.eastPeer) {
		self.eastPeer = peer;
		return YES;
	}
	
	if (!self.northPeer) {
		self.northPeer = peer;
		return YES;
	}
	
	if (!self.westPeer) {
		self.westPeer = peer;
		return YES;
	}
	
	return NO;
}
- (void) removePeer:(L0SlidePeer*) peer;
{
	if ([peer isEqual:self.northPeer])
		self.northPeer = nil;
	else if ([peer isEqual:self.eastPeer])
		self.eastPeer = nil;
	else if ([peer isEqual:self.westPeer])
		self.westPeer = nil;	
}

- (void) _setPeer:(L0SlidePeer*) peer withArrow:(UIImageView*) arrow label:(UILabel*) label;
{
	if (peer) {
		label.text = peer.name;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		label.alpha = 1;
		arrow.alpha = 1;
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		
		label.alpha = 0;
		arrow.alpha = 0;
		[UIView commitAnimations];		
	}
}

- (void) setNorthPeer:(L0SlidePeer*) p;
{
	if (p != northPeer) {
		[northPeer release];
		northPeer = [p retain];
	}
	
	[self _setPeer:p withArrow:self.northArrowView label:self.northLabel];
}

- (void) setEastPeer:(L0SlidePeer*) p;
{
	if (p != eastPeer) {
		[eastPeer release];
		eastPeer = [p retain];
	}
	
	[self _setPeer:p withArrow:self.eastArrowView label:self.eastLabel];
}

- (void) setWestPeer:(L0SlidePeer*) p;
{
	if (p != westPeer) {
		[westPeer release];
		westPeer = [p retain];
	}
	
	[self _setPeer:p withArrow:self.westArrowView label:self.westLabel];
}

- (void) addItem:(L0SlideItem*) item comingFromPeer:(L0SlidePeer*) peer;
{
	L0SlideItemsTableAddAnimation animation = kL0SlideItemsTableAddByDropping;
	if (peer) {
		if ([peer isEqual:self.northPeer])
			animation = kL0SlideItemsTableAddFromNorth;
		else if ([peer isEqual:self.eastPeer])
			animation = kL0SlideItemsTableAddFromEast;
		else if ([peer isEqual:self.westPeer])
			animation = kL0SlideItemsTableAddFromWest;
	}
	
	[self addItem:item animation:animation];
}

// TODO

- (void) returnItemToTableAfterSend:(L0SlideItem*) item;
{	
}

@end
