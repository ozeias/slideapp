//
//  L0BeamableItemsTableController.m
//  Shard
//
//  Created by ∞ on 22/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideItemsTableController.h"
#import "L0SlideItemView.h"

const CGAffineTransform L0CounterclockwiseQuarterTurnTransform = {
	0, -1,
	1, 0,
	0, 0
};

const CGAffineTransform L0ClockwiseQuarterTurnTransform = {
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
	
	if (!view.superview)
		[self.view addSubview:view];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:1.0];
	
	CGFloat randomOffsetX = 20 * (random() / (double) LONG_MAX) * (random() & 1? 1 : -1);
	CGFloat randomOffsetY = 20 * (random() / (double) LONG_MAX) * (random() & 1? 1 : -1);
	view.center = CGPointMake(goingTo.x + randomOffsetX, goingTo.y + randomOffsetY);
	
	[UIView commitAnimations];	
}

@interface L0SlideItemsTableController ()

- (L0SlideItemsTableAddAnimation) _animationForPeer:(L0SlidePeer*) peer;
- (void) _animateItemView:(L0SlideItemView*) view animation:(L0SlideItemsTableAddAnimation) a;

- (void) _removeItemView:(L0SlideItemView*) view animation:(L0SlideItemsTableRemoveAnimation) ani;

- (CGFloat) _labelAlphaForPeer:(L0SlidePeer*) peer;
- (CGFloat) _arrowAlphaForPeer:(L0SlidePeer*) peer;
- (void) _setPeer:(L0SlidePeer*) peer withArrow:(UIImageView*) arrow label:(UILabel*) label;

- (void) _bounceOrSendItemOfView:(L0SlideItemView*) view;

- (void) _endHoldingView:(L0DraggableView*) view;

@end


@implementation L0SlideItemsTableController

#pragma mark -
#pragma mark Initialization

- (id) initWithDefaultNibName;
{
	srandomdev();
	
	if (self = [self initWithNibName:@"L0SlideItemsTable" bundle:nil]) {
		itemsToViews = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		viewsBeingHeld = [NSMutableSet new];
	}
	
	return self;
}

- (void) viewDidLoad;
{
    [super viewDidLoad];
	
	self.eastLabel.transform = L0ClockwiseQuarterTurnTransform;
	self.westLabel.transform = L0CounterclockwiseQuarterTurnTransform;
	
	self.northLabel.alpha = 0;
	self.eastLabel.alpha = 0;
	self.westLabel.alpha = 0;
	
	self.northArrowView.alpha = 0;
	self.eastArrowView.alpha = 0;
	self.westArrowView.alpha = 0;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
- (void) viewDidUnload;
{
	[self clearOutlets];
}
#endif

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
	[viewsBeingHeld release];
	
	[self clearOutlets];
	self.northPeer = nil;
	self.eastPeer = nil;
	self.westPeer = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Item Management & Animation

- (L0SlideItemsTableAddAnimation) _animationForPeer:(L0SlidePeer*) peer;
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
	
	return animation;
}

- (void) addItem:(L0SlideItem*) item animation:(L0SlideItemsTableAddAnimation) a;
{
	if (CFDictionaryGetValue(itemsToViews, item))
		return;
	
	L0SlideItemView* view = [[L0SlideItemView alloc] initWithFrame:CGRectZero];
	[view sizeToFit];
	[view setDeletionTarget:self action:@selector(_deleteItemForView:)];
	view.delegate = self;
	view.transform = CGAffineTransformMakeRotation(L0RandomSlideRotation());
	[view displayWithContentsOfItem:item];
	CFDictionarySetValue(itemsToViews, item, view);

	[self _animateItemView:view animation:a];
}

- (void) _animateItemView:(L0SlideItemView*) view animation:(L0SlideItemsTableAddAnimation) a;
{
	switch (a) {
		case kL0SlideItemsTableAddByDropping: {
			CGSize selfSize = self.view.bounds.size;
			CGRect itemViewFrame = view.frame;
			selfSize.width -= itemViewFrame.size.width / 2 + 10;
			selfSize.height -= itemViewFrame.size.height / 2 + 10;
			
			CGPoint newCenter = CGPointMake(
											(int) selfSize.width % random(),
											(int) selfSize.height % random()
											);
			
			view.center = newCenter;
			view.alpha = 0;
			CGAffineTransform currentTransform = view.transform;
			view.transform = CGAffineTransformScale(currentTransform, 1.3, 1.3);
			view.userInteractionEnabled = NO;
			
			if (!view.superview)
				[self.view addSubview:view];
			
			[UIView beginAnimations:nil context:[view retain]];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDuration:0.5];
			
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
			if (!view.superview)
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

- (void) removeItem:(L0SlideItem*) item animation:(L0SlideItemsTableRemoveAnimation) ani;
{
	L0SlideItemView* view = (L0SlideItemView*) CFDictionaryGetValue(itemsToViews, item);
	if (!view)
		return;
	
	[self _removeItemView:view animation:ani];
}

- (void) _removeItemView:(L0SlideItemView*) view animation:(L0SlideItemsTableRemoveAnimation) ani;
{
	NSAssert(!view.superview || view.superview == self.view, @"Must be a view we manage or already removed.");
	
	switch (ani) {
		case kL0SlideItemsTableRemoveByFadingAway: {
		
			view.userInteractionEnabled = NO;
			[UIView beginAnimations:nil context:[view retain]];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(_itemViewRemoveAnimation:didEndByFinishing:context:)];
			
			view.alpha = 0.0;
			
			[UIView commitAnimations];
			
			break;
		}
			
		case kL0SlideItemsTableNoRemoveAnimation:
		default: {
			[view removeFromSuperview];
			break;
		}
	}
	
	CFDictionaryRemoveValue(itemsToViews, view.item);
	if (CFDictionaryGetCount(itemsToViews) == 0) {
		[self setEditing:NO animated:ani != kL0SlideItemsTableNoRemoveAnimation];
	}
}

- (void) _itemViewRemoveAnimation:(NSString*) name didEndByFinishing:(BOOL) finished context:(L0SlideItemView*) retainedView;
{
	[retainedView autorelease];
	[retainedView removeFromSuperview];
}

- (void) _deleteItemForView:(L0SlideItemView*) view;
{
	[self _removeItemView:view animation:kL0SlideItemsTableRemoveByFadingAway];
}

- (void) setEditing:(BOOL) editing animated:(BOOL) animated;
{
	[super setEditing:editing animated:animated];
	
	for (L0SlideItem* item in (NSDictionary*) itemsToViews) {
		L0SlideItemView* view = (L0SlideItemView*) CFDictionaryGetValue(itemsToViews, item);
		[view setEditing:editing animated:animated];
	}
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	}

	self.northLabel.alpha = [self _labelAlphaForPeer:self.northPeer];
	self.eastLabel.alpha = [self _labelAlphaForPeer:self.eastPeer];
	self.westLabel.alpha = [self _labelAlphaForPeer:self.westPeer];
	
	self.northArrowView.alpha = [self _arrowAlphaForPeer:self.northPeer];
	self.eastArrowView.alpha = [self _arrowAlphaForPeer:self.eastPeer];
	self.westArrowView.alpha = [self _arrowAlphaForPeer:self.westPeer];
	
	if (animated)
		[UIView commitAnimations];
	
}

- (CGFloat) _labelAlphaForPeer:(L0SlidePeer*) peer;
{
	CGFloat alpha;
	
	if (!peer)
		alpha = 0.0;
	else
		alpha = self.editing? 0.5 : 1.0;
	
	L0Log(@"peer = %@, alpha = %f", peer, alpha);
	return alpha;
}

- (CGFloat) _arrowAlphaForPeer:(L0SlidePeer*) peer;
{
	CGFloat alpha;
	
	if (!peer)
		alpha = 0.0;
	else
		alpha = self.editing? 0.0 : 1.0;
	
	L0Log(@"peer = %@, alpha = %f", peer, alpha);
	return alpha;
}

#define kL0SlideItemsTableScaleWhenHeld 1.1
#define kL0SlideItemsTableAlphaWhenHeld 0.7

- (BOOL) draggableViewShouldBeginDraggingAfterPressAndHold:(L0DraggableView*) view;
{
	[viewsBeingHeld addObject:view];
	
	[view.superview bringSubviewToFront:view];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];

	view.transform = CGAffineTransformScale(view.transform, kL0SlideItemsTableScaleWhenHeld, kL0SlideItemsTableScaleWhenHeld);
	view.alpha = kL0SlideItemsTableAlphaWhenHeld;
	
	[UIView commitAnimations];
	
	return YES;
}

- (void) _endHoldingView:(L0DraggableView*) view;
{
	if ([viewsBeingHeld containsObject:view]) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		view.transform = CGAffineTransformScale(view.transform, 1/kL0SlideItemsTableScaleWhenHeld, 1/kL0SlideItemsTableScaleWhenHeld);
		view.alpha = 1.0;
		
		[UIView commitAnimations];
		
		[viewsBeingHeld removeObject:view];
	}
}

- (void) draggableViewDidEndPressAndHold:(L0DraggableView*) view;
{
	[self _endHoldingView:view];
}
	
- (void) draggableViewDidEndDragging:(L0DraggableView*) view continuesWithSlide:(BOOL) slide;
{
	[self _endHoldingView:view];
}

#pragma mark -
#pragma mark Peer Management & Animation

@synthesize northPeer, eastPeer, westPeer;

- (BOOL) addPeerIfSpaceAllows:(L0SlidePeer*) peer;
{
	if ([peer isEqual:self.northPeer] || [peer isEqual:self.eastPeer] || [peer isEqual:self.westPeer])
		return YES;
	
	if (self.eastPeer && self.northPeer && self.westPeer)
		return NO;
	
	BOOL added = NO;
	while (!added) {
		int where = random() % 3;
		switch (where) {
			case 0:
				if (!self.northPeer) {
					self.northPeer = peer;
					added = YES;
				}
				break;

			case 1:
				if (!self.westPeer) {
					self.westPeer = peer;
					added = YES;
				}
				break;

			case 2:
				if (!self.eastPeer) {
					self.eastPeer = peer;
					added = YES;
				}
				break;
		}
	}
	
	return YES;
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
	if (peer)
		label.text = peer.name;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:peer? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn];
		
	label.alpha = [self _labelAlphaForPeer:peer];
	arrow.alpha = [self _arrowAlphaForPeer:peer];
	
	[UIView commitAnimations];		
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

#pragma mark -
#pragma mark Receiving

- (void) addItem:(L0SlideItem*) item comingFromPeer:(L0SlidePeer*) peer;
{
	[self addItem:item animation:[self _animationForPeer:peer]];
}

- (void) returnItemToTableAfterSend:(L0SlideItem*) item toPeer:(L0SlidePeer*) peer;
{
	L0SlideItemView* view = (L0SlideItemView*) CFDictionaryGetValue(itemsToViews, item);

	if (view)
		[self _animateItemView:view animation:[self _animationForPeer:peer]];
}

#pragma mark -
#pragma mark Sending

#define kL0SlideItemsTableOffsetBeforeAttractingOutside 30

- (BOOL) draggableView:(L0DraggableView*) view shouldMoveFromPoint:(CGPoint) start toAttractionPoint:(CGPoint*) outPoint;
{
	L0Log(@"Checking for attraction with start = %@", NSStringFromCGPoint(start));
	CGRect r = self.view.bounds;
	
	CGSize itemSize = view.bounds.size;
	
	if (self.northPeer && start.y > -itemSize.height * sqrt(2.0) && start.y < kL0SlideItemsTableOffsetBeforeAttractingOutside) {
		L0Log(@"Will attract the item north");
		// again this is conservative.
		start.y = -itemSize.height * sqrt(2.0);
		*outPoint = start;
		return YES;
	} else if (self.eastPeer && start.x > -itemSize.width * sqrt(2.0) && start.x < kL0SlideItemsTableOffsetBeforeAttractingOutside) {
		L0Log(@"Will attract the item east");
		// again this is conservative.
		start.x = -itemSize.width * sqrt(2.0);
		*outPoint = start;
		return YES;		
	} else if (self.westPeer && start.x < r.size.width + itemSize.width * sqrt(2.0) && start.x > r.size.width - kL0SlideItemsTableOffsetBeforeAttractingOutside) {
		L0Log(@"Will attract the item west");
		// again this is conservative.
		start.x = r.size.width + itemSize.width * sqrt(2.0);
		*outPoint = start;
		return YES;		
	} else
		return NO;
}

- (void) draggableView:(L0DraggableView*) view didEndAttractionByFinishing:(BOOL) finished;
{
	[self _bounceOrSendItemOfView:(L0SlideItemView*) view];
}

- (void) draggableView:(L0DraggableView*) view didEndInertialSlideByFinishing:(BOOL) finished;
{
	[self _bounceOrSendItemOfView:(L0SlideItemView*) view];
}

#define kL0SlideItemsTableOffsetSafetyMargin 50

- (void) _bounceOrSendItemOfView:(L0SlideItemView*) view;
{	
	L0Log(@"%@", view);
	
	CGPoint center = view.center;
	CGSize selfSize = self.view.bounds.size;
	L0SlidePeer* peer = nil;
	
	if (self.editing) // no sending while editing
		peer = nil;
	else if (center.y < 0)
		peer = self.northPeer;
	else if (center.x < 0)
		peer = self.westPeer;
	else if (center.x > selfSize.width)
		peer = self.eastPeer;
	else if (!(center.y > selfSize.height))
		return; // not off the edge -- don't send.
	// Note that we still want to bounce off the south edge, so we
	// don't return in that case -- but we don't send either.
	
	L0Log(@"Will send to peer: %@ (not sent if null).", peer);
	
	BOOL sent = NO;
	if (peer) {
		L0SlideItem* item = nil;
		
		for (L0SlideItem* candidateItem in (NSDictionary*) itemsToViews) {
			L0SlideItemView* candidateView = (L0SlideItemView*) CFDictionaryGetValue(itemsToViews, candidateItem);
			if (candidateView == view) {
				item = candidateItem;
				break;
			}
		}
		
		if (item) {
			[peer receiveItem:item];
			sent = YES;
		}
	} 
	
	if (!sent) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		
		if (center.y < kL0SlideItemsTableOffsetBeforeAttractingOutside)
			center.y = kL0SlideItemsTableOffsetBeforeAttractingOutside + kL0SlideItemsTableOffsetSafetyMargin;
		if (center.x < kL0SlideItemsTableOffsetBeforeAttractingOutside)
			center.x = kL0SlideItemsTableOffsetBeforeAttractingOutside + kL0SlideItemsTableOffsetSafetyMargin;
		if (center.x > selfSize.width - kL0SlideItemsTableOffsetBeforeAttractingOutside)
			center.x = selfSize.width - kL0SlideItemsTableOffsetBeforeAttractingOutside - kL0SlideItemsTableOffsetSafetyMargin;
		
		if (center.y > selfSize.height - kL0SlideItemsTableOffsetBeforeAttractingOutside)
			center.y = selfSize.height - kL0SlideItemsTableOffsetBeforeAttractingOutside - kL0SlideItemsTableOffsetSafetyMargin - 44; // for the toolbar
		
		view.center = center;
		
		[UIView commitAnimations];
	}
}

@end
