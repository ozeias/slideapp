//
//  L0BookmarkItem.h
//  Mover
//
//  Created by ∞ on 12/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0MoverItem.h"

@protocol L0BookmarkItemStorage;

@interface L0BookmarkItem : L0MoverItem {
	NSURL* address;
}

+ (id <L0BookmarkItemStorage>) storage;
+ (void) setStorage:(id <L0BookmarkItemStorage>) storage;

- (id) initWithAddress:(NSURL*) url title:(NSString*) title;
@property(copy) NSURL* address;

@end


@protocol L0BookmarkItemStorage <NSObject>
- (void) storeBookmarkItem:(L0BookmarkItem*) item;
@end