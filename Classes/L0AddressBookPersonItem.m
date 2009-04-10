//
//  L0AddressBookPersonItem.m
//  Slide
//
//  Created by ∞ on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0AddressBookPersonItem.h"

#define kL0AddressBookValue @"L0AddressBookValue"
#define kL0AddressBookLabel @"L0AddressBookLabel"

#define kL0AddressBookCountOfProperties (23) // sizeof(properties) / sizeof(ABPropertyID);

static ABPropertyID L0AddressBookGetPropertyWithIndex(int index) {
	static ABPropertyID L0AddressBookProperties[kL0AddressBookCountOfProperties];
	static BOOL initialized = NO;
	
	if (!initialized) {
	ABPropertyID properties[] = {
		kABPersonFirstNameProperty,
		kABPersonLastNameProperty,
		kABPersonMiddleNameProperty,
		kABPersonPrefixProperty,
		kABPersonSuffixProperty,
		kABPersonNicknameProperty,
		kABPersonFirstNamePhoneticProperty,
		kABPersonLastNamePhoneticProperty,
		kABPersonMiddleNamePhoneticProperty,
		kABPersonOrganizationProperty,
		kABPersonJobTitleProperty,
		kABPersonDepartmentProperty,
		kABPersonEmailProperty,
		kABPersonBirthdayProperty,
		kABPersonNoteProperty,
		kABPersonCreationDateProperty,
		kABPersonModificationDateProperty,
		kABPersonAddressProperty,
		kABPersonDateProperty,
		kABPersonKindProperty,
		kABPersonPhoneProperty,
		kABPersonInstantMessageProperty,
		kABPersonURLProperty,
		kABPersonRelatedNamesProperty
	};
		int i; for (i = 0; i < kL0AddressBookCountOfProperties; i++) {
			L0AddressBookProperties[i] = properties[i];
		}
	}
	
	return L0AddressBookProperties[index];
}

@interface L0AddressBookPersonItem ()

- (BOOL) loadPersonInfoFromData:(NSData*) payload;
- (void) loadPersonInfoFromAddressBookRecord:(ABRecordRef) record;

@end


@implementation L0AddressBookPersonItem

+ (NSArray*) supportedTypes;
{
	return [NSArray arrayWithObject:kL0AddressBookPersonDataInPropertyListType];
}

- (NSData*) externalRepresentation;
{
	NSDictionary* info = self.personInfo;
	
	NSAssert(info, @"The person info must be set.");
	NSString* error = nil;
	NSData* d = [NSPropertyListSerialization dataFromPropertyList:info format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
	
	if (error) {
		NSLog(@"An error occurred while serializing an address book contact: %@", error);
		[error release]; error = nil;
	}
	
	return d;
}

- (void) clearCache;
{
	[personInfo release];
	personInfo = nil;
}

- (NSDictionary*) personInfo;
{
	if (!personInfo && self.offloadingFile)
		NSAssert([self loadPersonInfoFromData:[self contentsOfOffloadingFile]], @"Must have been able to load from the offloading file.");
	return personInfo;
}

- (id) initWithExternalRepresentation:(NSData*) payload type:(NSString*) type title:(NSString*) title;
{
	if (self = [super init]) {
		if (![self loadPersonInfoFromData:payload]) {
			[self release];
			return nil;
		}
	}
	
	return self;
}


- (void) dealloc;
{
	[personInfo release];
	[super dealloc];
}

- (BOOL) loadPersonInfoFromData:(NSData*) payload;
{
	NSString* error = nil;
	
	NSDictionary* info = [NSPropertyListSerialization propertyListFromData:payload mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&error];
	
	if (error) {
		NSLog(@"An error occurred while deserializing an address book contact: %@", error);
		[error release]; error = nil;
	}
	
	[personInfo release];
	personInfo = [info copy];
	
	return personInfo != nil;
}

#define L0AddressBookIsMultiValueType(propertyType) (( (propertyType) & kABMultiValueMask ) != 0)

- (void) loadPersonInfoFromAddressBookRecord:(ABRecordRef) record;
{
	NSMutableDictionary* info = [NSMutableDictionary dictionary];
	
	int i; for (i = 0; i < kL0AddressBookCountOfProperties; i++) {
		ABPropertyID propertyID = L0AddressBookGetPropertyWithIndex(i);
		
		ABPropertyType t = ABPersonGetTypeOfProperty(propertyID);
		if (L0AddressBookIsMultiValueType(t)) {
			// we simply lift the value from the record -- since
			// all nonmulti are property list types, that's fine.
			
			id value = (id) ABRecordCopyValue(record, propertyID);
			if (value)
				[info setObject:value forKey:[NSNumber numberWithLong:propertyID]];
			
			[value release];
		} else {
			// multis are transformed into arrays of dictionaries.
			// (this is fine because NSArray is not one of the types
			// used by the AB framework).
			
			NSMutableArray* multiTransposed = [NSMutableArray array];
			ABMultiValueRef multi = ABRecordCopyValue(record, propertyID);
			
			NSArray* values = (NSArray*) ABMultiValueCopyArrayOfAllValues(multi);
			int valueIndex = 0;
			for (id value in values) {
				id label = (id) ABMultiValueCopyLabelAtIndex(multi, valueIndex);
				if (!label) label = [NSNull null];
				NSDictionary* item = [NSDictionary dictionaryWithObjectsAndKeys:
									  value, kL0AddressBookValue,
									  label, kL0AddressBookLabel,
									  nil];
				[multiTransposed addObject:item];
				[label release];
			}
			[values release];
			
			[info setObject:multiTransposed forKey:[NSNumber numberWithLong:propertyID]];
		}
	}
	
	[personInfo release];
	personInfo = [info retain];
}

- (id) initWithAddressBookRecord:(ABRecordRef) personRecord;
{
	if (self = [super init]) {
		[self loadPersonInfoFromAddressBookRecord:personRecord];
	}
	
	return self;
}

@end
