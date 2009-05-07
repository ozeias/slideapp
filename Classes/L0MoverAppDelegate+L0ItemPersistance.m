//
//  L0MoverAppDelegate+L0ItemPersistance.m
//  Slide
//
//  Created by ∞ on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0MoverAppDelegate+L0ItemPersistance.h"
#import "L0MoverItem.h"

static inline NSDictionary* L0InformationFromItem(L0MoverItem* i) {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			i.title, @"Title",
			i.type, @"Type",
			nil];
}

@implementation L0MoverAppDelegate (L0ItemPersistance)

- (void) persistItemsToMassStorage:(NSArray*) items;
{
	NSMutableDictionary* pathsToItemInfo = [NSMutableDictionary dictionary];
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* docs = self.documentsDirectory;
	
	for (L0MoverItem* i in items) {
		NSString* name;
		if (!i.offloadingFile) {
			do {
				name = [[L0UUID UUID] stringValue];
			} while ([fm fileExistsAtPath:[docs stringByAppendingPathComponent:name]]);
			
			[i offloadToFile:[docs stringByAppendingPathComponent:name]];
		} else
			name = [i.offloadingFile lastPathComponent];
		
		[pathsToItemInfo setObject:L0InformationFromItem(i) forKey:name];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:pathsToItemInfo forKey:@"L0SlidePersistedItems"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*) loadItemsFromMassStorage;
{
	NSDictionary* pathsToItemInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"L0SlidePersistedItems"];
	if (!pathsToItemInfo)
		return [NSArray array];
	
	NSMutableArray* items = [NSMutableArray array];
	NSString* docs = self.documentsDirectory;

	for (NSString* name in pathsToItemInfo) {
		NSDictionary* itemInfo = [pathsToItemInfo objectForKey:name];
		if (![itemInfo isKindOfClass:[NSDictionary class]])
			continue;
		
		NSString* title = [itemInfo objectForKey:@"Title"];
		NSString* type = [itemInfo objectForKey:@"Type"];
		
		if (!title || !type)
			continue;
		
		NSString* path = [docs stringByAppendingPathComponent:name];
		L0MoverItem* item = [L0MoverItem itemWithOffloadedFile:path type:type title:title];
		if (item)
			[items addObject:item];
	}
	
	return items;
}

@end
