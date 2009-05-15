//
//  L0BeamableItemView.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverItemView.h"


@implementation L0MoverItemView

@synthesize contentView, label, imageView, highlightView;

- (id) initWithFrame:(CGRect) frame;
{
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:[NSDictionary dictionary]];

		self.contentView.frame = self.bounds;
		self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:self.contentView];
		
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.editing = NO;
		self.highlighted = NO;
	}
	
    return self;
}

- (void) sizeToFit;
{
	CGRect frame = self.frame;
	frame.size = CGSizeMake(179, 179);
	self.frame = frame;
	
	self.contentView.frame = self.bounds;
}

- (void) dealloc;
{
	self.contentView = nil;
	[super dealloc];
}

@synthesize item;

- (void) displayWithContentsOfItem:(L0MoverItem*) i;
{
	self.label.text = i.title;
	self.imageView.image = i.representingImage;
	item = i;
}

@synthesize deleteButton;

- (void) setDeletionTarget:(id) target action:(SEL) action;
{
	deletionTarget = target;
	deletionAction = action;
}

- (IBAction) performDelete;
{
	if (deletionTarget && deletionAction)
		[deletionTarget performSelector:deletionAction withObject:self];
}

- (void) setEditing:(BOOL) newEditing animated:(BOOL) animated;
{
	if (newEditing == editing)
		return;
	
	editing = newEditing;
	if (editing) {
		
		deleteButton.userInteractionEnabled = YES;
		contentView.userInteractionEnabled = YES;

		if (animated) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.4];
		}

		imageView.alpha = 0.4;
		deleteButton.alpha = 1.0;
		
		if (animated)
			[UIView commitAnimations];
		
	} else {

		deleteButton.userInteractionEnabled = NO;
		contentView.userInteractionEnabled = NO;

		if (animated) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.4];
		}
		
		imageView.alpha = 1.0;
		deleteButton.alpha = 0.0;
		
		if (animated)
			[UIView commitAnimations];
		
	}
}

- (void) setHighlighted:(BOOL) h animated:(BOOL) animated animationDuration:(NSTimeInterval) duration;
{
	[UIView beginAnimations:nil context:NULL];
	if (animated) {
		[UIView setAnimationDuration:duration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationBeginsFromCurrentState:YES];
	} else
		[UIView setAnimationDuration:0.0];
	
	highlightView.alpha = h? 1.0 : 0.0;
	
	[UIView commitAnimations];
}

@synthesize editing;
- (void) setEditing:(BOOL) e;
{
	[self setEditing:e animated:NO];
}

@synthesize highlighted;
- (void) setHighlighted:(BOOL) h;
{
	[self setHighlighted:h animated:NO animationDuration:0.0];
}

@end
