//
//  L0SlideItemsCoordinator.m
//  Slide
//
//  Created by ∞ on 08/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideItemsCoordinator.h"

#import <MuiKit/MuiKit.h>
#import "L0SlideAppDelegate.h"

@implementation L0SlideItemsCoordinator

// TODO

- (void) persistItem:(L0SlideItem*) item;
{
	NSString* documentsDir = ((L0SlideAppDelegate*) [UIApp delegate]).documentsDirectory;
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* path;
	do {
		L0UUID* uuid = [L0UUID UUID];
		path = [documentsDir stringByAppendingPathComponent:[uuid stringValue]];
	} while ([fm fileExistsAtPath:path]);
	
	[item offloadToFile:path];
}

- (void) removePersistedItem:(L0SlideItem*) item;
{}

- (void) loadItemsFromMassStorage;
{}

- (void) saveItemsToMassStorage;
{}

@end
