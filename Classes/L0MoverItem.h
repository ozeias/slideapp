//
//  L0BeamableItem.h
//  Shard
//
//  Created by ∞ on 21/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdint.h>

#import "BLIP.h"

#define kL0BeamableItemUTF8TitleLength 1024
#define kL0BeamableItemUTF8TypeLength 256

#define kL0BeamableItemNetworkPacketIdentifierString "ITEM"
#define kL0BeamableItemNetworkPacketVersion1 1

typedef struct {
	char Kind[5]; // "ITEM", NULL-terminated.
	int Version; // kL0BeamableItemNetworkPacketVersion1
	char Title[kL0BeamableItemUTF8TitleLength]; // UTF-8 NULL-terminated.
	char Type[kL0BeamableItemUTF8TypeLength]; // UTF-8 NULL-terminated version of a UTI, eg. kUTTypeVCard
	uint32_t Size; // Size of the payload in bytes.
} L0BeamableItemNetworkHeader;

@interface L0MoverItem : NSObject {
	NSString* title;
	NSString* type;
	UIImage* representingImage;
	
	NSString* offloadingFile;
	BOOL shouldDisposeOfOffloadingFileOnDealloc;
}

+ (void) registerClass;

+ (void) registerClass:(Class) c forType:(NSString*) type;
+ (Class) classForType:(NSString*) c;

@property(copy) NSString* title;
@property(copy) NSString* type;
@property(retain) UIImage* representingImage;

// Funnels

+ (NSArray*) supportedTypes;
- (NSData*) externalRepresentation;
- (id) initWithExternalRepresentation:(NSData*) payload type:(NSString*) type title:(NSString*) title;

- (void) storeToAppropriateApplication;

// Persistance methods.
// TODO error handling.
+ itemWithOffloadedFile:(NSString*) file type:(NSString*) type title:(NSString*) title;
- (void) offloadToFile:(NSString*) file;
@property(readonly, copy) NSString* offloadingFile;
@property(assign) BOOL shouldDisposeOfOffloadingFileOnDealloc;
- (NSData*) contentsOfOffloadingFile;
- (void) clearCache;

@end

@interface L0MoverItem (L0BLIPBeaming)

- (BLIPRequest*) contentsAsBLIPRequest;
+ (id) itemWithContentsOfBLIPRequest:(BLIPRequest*) req;

@end
