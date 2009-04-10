//
//  L0SlideAppDelegate+L0ItemPersistance.m
//  Slide
//
//  Created by ∞ on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0SlideAppDelegate+L0ItemPersistance.h"
#import "L0SlideItem.h"

static inline NSDictionary* L0InformationFromItem(L0SlideItem* i) {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			i.title, @"Title",
			i.type, @"Type",
			nil];
}

@implementation L0SlideAppDelegate (L0ItemPersistance)

- (void) persistItemsToMassStorage:(NSArray*) items;
{
	NSMutableDictionary* pathsToItemInfo = [NSMutableDictionary dictionary];
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* docs = self.documentsDirectory;
	
	for (L0SlideItem* i in items) {
		if (!i.offloadingFile) {
			NSString* path;
			do {
				path = [docs stringByAppendingPathComponent:[[L0UUID UUID] stringValue]];
			} while ([fm fileExistsAtPath:path]);
			
			[i offloadToFile:path];
		}
		
		[pathsToItemInfo setObject:L0InformationFromItem(i) forKey:i.offloadingFile];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:pathsToItemInfo forKey:@"L0SlidePersistedItems"];
}

- (NSArray*) loadItemsFromMassStorage;
{
	NSDictionary* pathsToItemInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"L0SlidePersistedItems"];
	if (!pathsToItemInfo)
		return [NSArray array];
	
	NSMutableArray* items = [NSMutableArray array];

	for (NSString* path in pathsToItemInfo) {
		NSDictionary* itemInfo = [pathsToItemInfo objectForKey:path];
		if (![itemInfo isKindOfClass:[NSDictionary class]])
			continue;
		
		NSString* title = [itemInfo objectForKey:@"Title"];
		NSString* type = [itemInfo objectForKey:@"Type"];
		
		if (!title || !type)
			continue;
		
		L0SlideItem* item = [L0SlideItem itemWithOffloadedFile:path type:type title:title];
		if (item)
			[items addObject:item];
	}
	
	return items;
}

@end
