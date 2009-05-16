//
//  L0BeamableItemsTableController.m
//  Shard
//
//  Created by ∞ on 22/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverItemsTableController.h"
#import "L0MoverItemView.h"
#import "L0MoverAppDelegate.h"
#import "L0MoverAppDelegate+L0ItemPersistance.h"
#import "L0MoverAppDelegate+L0HelpAlerts.h"

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

static inline void L0AnimateSlideEntranceFromOffscreenPoint(L0MoverItemsTableController* self, UIView* view, CGPoint comingFrom, CGPoint goingTo) {
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

@interface L0MoverItemsTableController ()

- (L0SlideItemsTableAddAnimation) animationForPeer:(L0MoverPeer*) peer;
- (void) animateItemView:(L0MoverItemView*) view withAddAnimation:(L0SlideItemsTableAddAnimation) a;

- (void) removeItemView:(L0MoverItemView*) view animation:(L0SlideItemsTableRemoveAnimation) ani;

- (CGFloat) labelAlphaForPeer:(L0MoverPeer*) peer;
- (CGFloat) arrowAlphaForPeer:(L0MoverPeer*) peer;
- (void) updateUIWithPeer:(L0MoverPeer*) peer forKey:(NSString*) key withArrow:(UIImageView*) arrow label:(UILabel*) label hadPreviousPeer:(BOOL) hadPreviousPeer;
- (void) performFadeInOutAnimationForKey:(NSString*) key assumingStillIsPeer:(L0MoverPeer*) peer withArrow:(UIImageView*) arrow label:(UILabel*) label;

- (void) bounceOrSendItemOfView:(L0MoverItemView*) view;

- (void) highlightIfNotEditing:(L0MoverItemView*) v;
- (void) unhighlight:(L0MoverItemView*) v;

- (void) beginHoldingView:(L0DraggableView*) view;
- (void) endHoldingView:(L0DraggableView*) view;

- (UIActivityIndicatorView*) spinnerForPeer:(L0MoverPeer*) peer;

@end


@implementation L0MoverItemsTableController

#pragma mark -
#pragma mark Initialization

- (id) initWithDefaultNibName;
{
	srandomdev();
	
	if (self = [self initWithNibName:@"L0MoverItemsTable" bundle:nil]) {
		itemsToViews = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		viewsBeingHeld = [NSMutableSet new];
		self.editButtonItem.enabled = NO;
		queuedPeers = [NSMutableArray new];
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
	
	basePeerLabelColor = [self.northLabel.textColor retain];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	for (L0MoverItem* i in [self items]) {
		if (i.offloadingFile)
			[i clearCache];
	}
}

@synthesize northArrowView, eastArrowView, westArrowView;
@synthesize northLabel, eastLabel, westLabel;
@synthesize northSpinner, eastSpinner, westSpinner;

- (void) clearOutlets;
{
	self.northArrowView = nil;
	self.eastArrowView = nil;
	self.westArrowView = nil;
	
	self.northLabel = nil;
	self.eastLabel = nil;
	self.westLabel = nil;
	
	[basePeerLabelColor release];
	basePeerLabelColor = nil;
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
	[queuedPeers release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Item Management & Animation

- (L0SlideItemsTableAddAnimation) animationForPeer:(L0MoverPeer*) peer;
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

- (void) addItem:(L0MoverItem*) item animation:(L0SlideItemsTableAddAnimation) a;
{
	if (CFDictionaryGetValue(itemsToViews, item))
		return;
	
	L0MoverItemView* view = [[L0MoverItemView alloc] initWithFrame:CGRectZero];
	[view sizeToFit];
	[view setActionButtonTarget:self selector:@selector(showEditingActionMenuForItemOfView:)];
	view.delegate = self;
	view.transform = CGAffineTransformMakeRotation(L0RandomSlideRotation());
	[view setItem:item];
	CFDictionarySetValue(itemsToViews, item, view);

	[self animateItemView:view withAddAnimation:a];
	
	self.editButtonItem.enabled = YES;
}

- (void) animateItemView:(L0MoverItemView*) view withAddAnimation:(L0SlideItemsTableAddAnimation) a;
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
			if (!view.superview) {
				CGSize selfSize = self.view.bounds.size;
				CGRect itemViewFrame = view.frame;
				selfSize.width -= itemViewFrame.size.width / 2 + 10;
				selfSize.height -= itemViewFrame.size.height / 2 + 10;
				
				CGPoint newCenter = CGPointMake(
												(int) selfSize.width % random(),
												(int) selfSize.height % random()
												);
				
				view.center = newCenter;
				[self.view addSubview:view];
			}
			break;
		}
	}
}

- (void) _addByDroppingAnimation:(NSString*) ani didFinish:(BOOL) finished forRetainedView:(UIView*) retainedView;
{
	[retainedView release];
	retainedView.userInteractionEnabled = YES;
}

- (void) removeItem:(L0MoverItem*) item animation:(L0SlideItemsTableRemoveAnimation) ani;
{
	L0MoverItemView* view = (L0MoverItemView*) CFDictionaryGetValue(itemsToViews, item);
	if (!view)
		return;
	
	[self removeItemView:view animation:ani];	
}

- (void) removeItemView:(L0MoverItemView*) view animation:(L0SlideItemsTableRemoveAnimation) ani;
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
	
	// TODO make file lifecycle not dependant on item object lifecycle.
	view.item.shouldDisposeOfOffloadingFileOnDealloc = YES;
	
	CFDictionaryRemoveValue(itemsToViews, view.item);
	if (CFDictionaryGetCount(itemsToViews) == 0) {
		[self setEditing:NO animated:ani != kL0SlideItemsTableNoRemoveAnimation];
		self.editButtonItem.enabled = NO;
	}
}

- (void) _itemViewRemoveAnimation:(NSString*) name didEndByFinishing:(BOOL) finished context:(L0MoverItemView*) retainedView;
{
	[retainedView autorelease];
	[retainedView removeFromSuperview];
}

- (void) showEditingActionMenuForItemOfView:(L0MoverItemView*) view;
{
	L0MoverAppDelegate* delegate = (L0MoverAppDelegate*) UIApp.delegate;
	view.highlighted = YES;
	[delegate beginShowingActionMenuForItem:view.item includeRemove:YES];
}

- (void) setEditing:(BOOL) editing animated:(BOOL) animated;
{
	[super setEditing:editing animated:animated];
	
	for (L0MoverItem* item in (NSDictionary*) itemsToViews) {
		L0MoverItemView* view = (L0MoverItemView*) CFDictionaryGetValue(itemsToViews, item);
		[view setEditing:editing animated:animated];
	}
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	}

	self.northLabel.alpha = [self labelAlphaForPeer:self.northPeer];
	self.eastLabel.alpha = [self labelAlphaForPeer:self.eastPeer];
	self.westLabel.alpha = [self labelAlphaForPeer:self.westPeer];
	
	self.northArrowView.alpha = [self arrowAlphaForPeer:self.northPeer];
	self.eastArrowView.alpha = [self arrowAlphaForPeer:self.eastPeer];
	self.westArrowView.alpha = [self arrowAlphaForPeer:self.westPeer];
	
	if (animated)
		[UIView commitAnimations];
	
	if (editing)
		[(L0MoverAppDelegate*)UIApp.delegate showAlertIfNotShownBeforeNamed:@"L0EditingIsNondestructive"];
}

- (CGFloat) labelAlphaForPeer:(L0MoverPeer*) peer;
{
	CGFloat alpha;
	
	if (!peer)
		alpha = 0.0;
	else
		alpha = self.editing? 0.5 : 1.0;
	
	L0Log(@"peer = %@, alpha = %f", peer, alpha);
	return alpha;
}

- (CGFloat) arrowAlphaForPeer:(L0MoverPeer*) peer;
{
	CGFloat alpha;
	
	if (!peer)
		alpha = 0.0;
	else
		alpha = self.editing? 0.0 : 1.0;
	
	L0Log(@"peer = %@, alpha = %f", peer, alpha);
	return alpha;
}

- (void) draggableView:(L0DraggableView*) view didTouch:(UITouch*) t;
{
	[self highlightIfNotEditing:(L0MoverItemView*) view];
}

- (void) draggableView:(L0DraggableView*) view didTapMultipleTimesWithTouch:(UITouch*) t;
{
	L0MoverItemView* itemView = (L0MoverItemView*) view;
	if (!self.editing) {
		L0MoverAppDelegate* delegate = (L0MoverAppDelegate*) UIApp.delegate;
		BOOL performed = [delegate performMainActionForItem:itemView.item];
		if (performed)
			itemView.highlighted = YES;	
	}
	
	[self unhighlight:itemView];
}

- (void) draggableViewDidBeginDragging:(L0DraggableView*) view;
{
	[self unhighlight:(L0MoverItemView*) view];
}

- (void) draggableViewDidPress:(L0DraggableView*) view;
{
	[self unhighlight:(L0MoverItemView*) view];
}	

- (void) highlightIfNotEditing:(L0MoverItemView*) v;
{
	if (self.editing)
		return;
	
	// This avoids drag lag.
	[self performSelector:@selector(performHighlight:) withObject:v afterDelay:0.2];
}

- (void) performHighlight:(L0MoverItemView*) v;
{
	[v setHighlighted:YES animated:YES animationDuration:0.35];
}

- (void) unhighlight:(L0MoverItemView*) v;
{
	if (hasBegunShowingActionMenu)
		return;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performHighlight:) object:v];
	[v setHighlighted:NO animated:YES animationDuration:0.3];
}

- (BOOL) draggableViewShouldBeginDraggingAfterPressAndHold:(L0DraggableView*) view;
{
	if (self.editing) {
		[self beginHoldingView:view];
		return YES;
	} else {
		L0Log(@"Showing action menu.");
		L0MoverAppDelegate* delegate = (L0MoverAppDelegate*) [UIApp delegate];
		[delegate beginShowingActionMenuForItem:((L0MoverItemView*)view).item includeRemove:YES];
		hasBegunShowingActionMenu = YES;
		return NO;
	}
}

- (void) finishedShowingActionMenuForItem:(L0MoverItem*) item;
{
	L0MoverItemView* v = (L0MoverItemView*) CFDictionaryGetValue(itemsToViews, item);
	[v setHighlighted:NO animated:YES animationDuration:0.3];
	hasBegunShowingActionMenu = NO;
}


#define kL0SlideItemsTableScaleWhenHeld 1.1
#define kL0SlideItemsTableAlphaWhenHeld 0.7

- (void) beginHoldingView:(L0DraggableView*) view;
{
	[viewsBeingHeld addObject:view];
	
	[view.superview bringSubviewToFront:view];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	view.transform = CGAffineTransformScale(view.transform, kL0SlideItemsTableScaleWhenHeld, kL0SlideItemsTableScaleWhenHeld);
	view.alpha = kL0SlideItemsTableAlphaWhenHeld;
	
	[UIView commitAnimations];
}

- (void) endHoldingView:(L0DraggableView*) view;
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
	[self unhighlight:(L0MoverItemView*) view];
	[self endHoldingView:view];
}
	
- (void) draggableViewDidEndDragging:(L0DraggableView*) view continuesWithSlide:(BOOL) slide;
{
	[self endHoldingView:view];
}

#pragma mark -
#pragma mark Peer Management & Animation

@synthesize northPeer, eastPeer, westPeer;

- (BOOL) addPeerIfSpaceAllows:(L0MoverPeer*) peer;
{
	L0Log(@"%@", peer);
	
	if ([peer isEqual:self.northPeer] || [peer isEqual:self.eastPeer] || [peer isEqual:self.westPeer])
		return YES;
	
	if ([queuedPeers containsObject:peer])
		return YES;
	
	if (self.eastPeer && self.northPeer && self.westPeer) {
		[queuedPeers addObject:peer];
		return YES;
	}
	
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
- (void) removePeer:(L0MoverPeer*) peer;
{
	L0Log(@"%@", peer);
	
	id nextPeer = nil; BOOL used = NO;
	if ([queuedPeers count] > 0) {
		nextPeer = [queuedPeers lastObject];
	}
	
	if ([peer isEqual:self.northPeer]) {
		self.northPeer = nextPeer; used = (nextPeer != nil);
	} else if ([peer isEqual:self.eastPeer]) {
		self.eastPeer = nextPeer; used = (nextPeer != nil);
	} else if ([peer isEqual:self.westPeer]) {
		self.westPeer = nextPeer; used = (nextPeer != nil);
	} else
		[queuedPeers removeObject:peer];
	
	if (used)
		[queuedPeers removeLastObject];
}

- (void) updateUIWithPeer:(L0MoverPeer*) peer forKey:(NSString*) key withArrow:(UIImageView*) arrow label:(UILabel*) label hadPreviousPeer:(BOOL) hadPreviousPeer;
{	
	L0Log(@"%@, %@, %@, %@, %d", peer, key, arrow, label, hadPreviousPeer);
	
	if (hadPreviousPeer && peer) {
		[UIView beginAnimations:@"L0ArrowFadeOutForBlankingAnimation" context:NULL];
		[UIView setAnimationCurve:peer? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.5];
		
		label.alpha = 0.0;
		arrow.alpha = 0.0;
		
		[UIView commitAnimations];
		
		[label performSelector:@selector(setText:) withObject:peer.name afterDelay:0.55];
	}
	
	if (peer && !hadPreviousPeer)
		label.text = peer.name;

	if (!hadPreviousPeer)
		[self performFadeInOutAnimationForKey:key assumingStillIsPeer:peer withArrow:arrow label:label];
	else {
		NSMutableDictionary* attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  key, @"key",
									  arrow, @"arrow",
									  label, @"label",
									  nil];
		if (peer)
			[attrs setObject:peer forKey:@"peer"];
		[self performSelector:@selector(performFadeInOutAnimationWithAttributes:) withObject:attrs afterDelay:0.7];
	}
}

- (void) performFadeInOutAnimationWithAttributes:(NSDictionary*) d;
{
	L0Log(@"%@", d);
	[self performFadeInOutAnimationForKey:[d objectForKey:@"key"] assumingStillIsPeer:[d objectForKey:@"peer"] withArrow:[d objectForKey:@"arrow"] label:[d objectForKey:@"label"]];
}

- (void) performFadeInOutAnimationForKey:(NSString*) key assumingStillIsPeer:(L0MoverPeer*) assumedPeer withArrow:(UIImageView*) arrow label:(UILabel*) label;
{
	L0Log(@"key = %@, assumed peer = %@, arrow = %@, label = %@", key, assumedPeer, arrow, label);
	NSAssert(arrow != nil, @"Have an arrow");
	NSAssert(label != nil, @"Have an arrow");
	
	L0MoverPeer* peer = [self valueForKey:key];
	if ([peer isEqual:[NSNull null]])
		peer = nil;
	if ([self valueForKey:key] != assumedPeer) {
		L0Log(@"Assumption no longer valid, now %@", peer);
		return;
	}
	
	[UIView beginAnimations:@"L0ArrowFadeInOutAnimation" context:NULL];
	[UIView setAnimationCurve:peer? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:1.0];
	
	label.alpha = [self labelAlphaForPeer:peer];
	arrow.alpha = [self arrowAlphaForPeer:peer];
	
	[UIView commitAnimations];
}

- (void) setNorthPeer:(L0MoverPeer*) p;
{
	L0Log(@"replacing %@ with %@", northPeer, p);	
	BOOL hadPeer = (northPeer != nil);
	
	if (p != northPeer) {
		[northPeer release];
		northPeer = [p retain];
	}
	
	[self updateUIWithPeer:p forKey:@"northPeer" withArrow:self.northArrowView label:self.northLabel hadPreviousPeer:hadPeer];
}

- (void) setEastPeer:(L0MoverPeer*) p;
{
	L0Log(@"replacing %@ with %@", eastPeer, p);	
	BOOL hadPeer = (eastPeer != nil);
	
	if (p != eastPeer) {
		[eastPeer release];
		eastPeer = [p retain];
	}
	
	[self updateUIWithPeer:p forKey:@"eastPeer" withArrow:self.eastArrowView label:self.eastLabel hadPreviousPeer:hadPeer];
}

- (void) setWestPeer:(L0MoverPeer*) p;
{
	L0Log(@"replacing %@ with %@", westPeer, p);	
	BOOL hadPeer = (westPeer != nil);
	
	if (p != westPeer) {
		[westPeer release];
		westPeer = [p retain];
	}
	
	[self updateUIWithPeer:p forKey:@"westPeer" withArrow:self.westArrowView label:self.westLabel hadPreviousPeer:hadPeer];
}

#pragma mark -
#pragma mark Receiving

- (UIActivityIndicatorView*) spinnerForPeer:(L0MoverPeer*) peer;
{
	UIActivityIndicatorView* spinner = nil;
	if (peer == self.northPeer)
		spinner = self.northSpinner;
	else if (peer == self.eastPeer)
		spinner = self.eastSpinner;
	else if (peer == self.westPeer)
		spinner = self.westSpinner;
	
	return spinner;
}

- (UILabel*) _labelForPeer:(L0MoverPeer*) peer;
{
	UILabel* label = nil;
	if (peer == self.northPeer)
		label = self.northLabel;
	else if (peer == self.eastPeer)
		label = self.eastLabel;
	else if (peer == self.westPeer)
		label = self.westLabel;
	
	return label;
}

- (void) addItem:(L0MoverItem*) item comingFromPeer:(L0MoverPeer*) peer;
{
	[self addItem:item animation:[self animationForPeer:peer]];
	[self stopWaitingForItemFromPeer:peer];
}

- (void) stopWaitingForItemFromPeer:(L0MoverPeer*) peer;
{
	[[self spinnerForPeer:peer] stopAnimating];
	
	[self _labelForPeer:peer].textColor = basePeerLabelColor;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationRepeatCount:1];
	[UIView setAnimationRepeatAutoreverses:NO];
	
	[self _labelForPeer:peer].alpha = 1;
	
	[UIView commitAnimations];
}

- (void) returnItemToTableAfterSend:(L0MoverItem*) item toPeer:(L0MoverPeer*) peer;
{
	L0MoverItemView* view = (L0MoverItemView*) CFDictionaryGetValue(itemsToViews, item);

	if (view)
		[self animateItemView:view withAddAnimation:[self animationForPeer:peer]];
}

- (void) beginWaitingForItemComingFromPeer:(L0MoverPeer*) peer;
{
	[[self spinnerForPeer:peer] startAnimating];
	
	[self _labelForPeer:peer].textColor = [UIColor colorWithRed:33.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationRepeatCount:1e100f];
	[UIView setAnimationRepeatAutoreverses:YES];
	
	[self _labelForPeer:peer].alpha = 0.3;
	
	[UIView commitAnimations];
	
	
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
	[self bounceOrSendItemOfView:(L0MoverItemView*) view];
}

- (void) draggableView:(L0DraggableView*) view didEndInertialSlideByFinishing:(BOOL) finished;
{
	[self bounceOrSendItemOfView:(L0MoverItemView*) view];
}

#define kL0SlideItemsTableOffsetSafetyMargin 50

- (void) bounceOrSendItemOfView:(L0MoverItemView*) view;
{	
	L0Log(@"%@", view);
	
	CGPoint center = view.center;
	CGSize selfSize = self.view.bounds.size;
	L0MoverPeer* peer = nil;
	
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
		L0MoverItem* item = nil;
		
		for (L0MoverItem* candidateItem in (NSDictionary*) itemsToViews) {
			L0MoverItemView* candidateView = (L0MoverItemView*) CFDictionaryGetValue(itemsToViews, candidateItem);
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

- (NSArray*) items;
{
	// VLAs are bad in GCC 4 :(
	size_t itemsCount = CFDictionaryGetCount(itemsToViews);
	id* allItemsCArray = malloc(sizeof(id) * itemsCount);
	CFDictionaryGetKeysAndValues(itemsToViews, (const void**) allItemsCArray, NULL);
	NSArray* arr = [[[NSArray alloc] initWithObjects:(const id*) allItemsCArray count:itemsCount] autorelease];
	free(allItemsCArray);
	
	return arr;
}

@end
