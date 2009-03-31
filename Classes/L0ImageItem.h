//
//  L0BeamableImage.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0SlideItem.h"

@interface L0ImageItem : L0SlideItem {
	UIImage* image;
}

- (id) initWithTitle:(NSString*) title image:(UIImage*) image;
@property(retain) UIImage* image;

@end
