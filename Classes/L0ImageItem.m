//
//  L0BeamableImage.m
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0ImageItem.h"

#import "L0MoverUTISupport.h"

#import <MuiKit/MuiKit.h>

@implementation L0ImageItem

+ (NSArray*) supportedTypes;
{
	return [NSArray arrayWithObjects:
			(id) kUTTypeTIFF,
			(id) kUTTypeJPEG,
			(id) kUTTypeGIF,
			(id) kUTTypePNG,
			(id) kUTTypeBMP,
			(id) kUTTypeICO,
			nil];
}

- (NSData*) externalRepresentation;
{	
	return UIImagePNGRepresentation([self.image imageByRenderingRotation]);
}

- (id) initWithTitle:(NSString*) ti image:(UIImage*) img;
{
	if (self = [super init]) {
		self.title = ti;
		self.image = img;
		self.type = (id) kUTTypePNG;
	}
	
	return self;
}

- (UIImage*) representingImage;
{
	UIImage* storedImage = [super representingImage];
	if (!storedImage) {
		storedImage = [self.image imageByRenderingRotationAndScalingWithMaximumSide:130.0];
		self.representingImage = storedImage;
	}
	
	return storedImage;
}

- (id) initWithExternalRepresentation:(NSData*) payload type:(NSString*) ty title:(NSString*) ti;
{
	if (self = [super init]) {
		self.title = ti;
		self.type = (id) kUTTypePNG;
		UIImage* img = [UIImage imageWithData:payload];
		
		if (!img) {
			[self release];
			return nil;
		}
		
		self.image = img;
	}
	
	return self;
}

- (void) storeToAppropriateApplication;
{
	UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, NULL);
}

- (void) clearCache;
{
	L0Log(@"Done to %@", self);
	self.image = nil;
}

- (void) offloadToFile:(NSString*) file;
{
	(void) [self representingImage]; // ensures it's loaded.
	[super offloadToFile:file];
}

@synthesize image;
- (UIImage*) image;
{
	if (!image && self.offloadingFile) {
		L0Log(@"Caching from contents of offloading file: %@", self.offloadingFile);
		self.image = [UIImage imageWithContentsOfFile:self.offloadingFile];
	}
	
	return image;
}

- (void) dealloc;
{
	[image release];
	[super dealloc];
}

@end
