//
//  L0BeamableItemView.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideItemView.h"


@implementation L0SlideItemView

@synthesize contentView, label, imageView;

- (id) initWithFrame:(CGRect) frame;
{
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:[NSDictionary dictionary]];

		self.contentView.frame = self.bounds;
		self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:self.contentView];
		
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
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

- (void) displayWithContentsOfItem:(L0SlideItem*) item;
{
	self.label.text = item.title;
	self.imageView.image = item.representingImage;
}

@end
