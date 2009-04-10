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

#define kL0AddressBookPersonInfoProperties @"L0AddressBookPersonInfoProperties"
#define kL0AddressBookPersonInfoImageData @"L0AddressBookPersonInfoImageData"

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
		int i; for (i = 0; i < kL0AddressBookCountOfProperties; i++)
			L0AddressBookProperties[i] = properties[i];
		
		initialized = YES;
	}
	
	return L0AddressBookProperties[index];
}

@interface L0AddressBookPersonItem ()

- (BOOL) loadPersonInfoFromData:(NSData*) payload;
- (void) loadPersonInfoFromAddressBookRecord:(ABRecordRef) record;

- (NSString*) shortenedNameFromAddressBookRecord:(ABRecordRef) record;
- (NSString*) shortenedNameFromName:(NSString*) name surname:(NSString*) surname;

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

- (id) initWithExternalRepresentation:(NSData*) payload type:(NSString*) ty title:(NSString*) ti;
{
	if (self = [super init]) {
		if (![self loadPersonInfoFromData:payload]) {
			[self release];
			return nil;
		}
		
		self.type = kL0AddressBookPersonDataInPropertyListType;
		
		NSString* nameKey = [NSString stringWithFormat:@"%d", kABPersonFirstNameProperty];
		NSString* surnameKey = [NSString stringWithFormat:@"%d", kABPersonLastNameProperty];
		
		NSDictionary* properties = [[self personInfo] objectForKey:kL0AddressBookPersonInfoProperties];
		
		self.title = [self shortenedNameFromName:[properties objectForKey:nameKey] surname:[properties objectForKey:surnameKey]];
		
		UIImage* image;
		if ([personInfo objectForKey:kL0AddressBookPersonInfoImageData])
			image = [UIImage imageWithData:[personInfo objectForKey:kL0AddressBookPersonInfoImageData]];
		else
			image = [UIImage imageNamed:@"ContactWithoutImageIcon.png"];
		self.representingImage = image;		
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
		if (!L0AddressBookIsMultiValueType(t)) {
			// we simply lift the value from the record -- since
			// all nonmulti are property list types, that's fine.
			
			id value = (id) ABRecordCopyValue(record, propertyID);
			if (value)
				[info setObject:value forKey:[NSString stringWithFormat:@"%d", propertyID]];
			
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
				valueIndex++;
			}
			[values release];
			
			[info setObject:multiTransposed forKey:[NSString stringWithFormat:@"%d", propertyID]];
			CFRelease(multi);
		}
	}
	
	NSMutableDictionary* person = [NSMutableDictionary dictionary];
	[person setObject:info forKey:kL0AddressBookPersonInfoProperties];
	
	if (ABPersonHasImageData(record)) {
		NSData* data = (NSData*) ABPersonCopyImageData(record);
		[person setObject:data forKey:kL0AddressBookPersonInfoImageData];
		[data release];
	}
	
	[personInfo release];
	personInfo = [person retain];
}


- (NSString*) shortenedNameFromAddressBookRecord:(ABRecordRef) record;
{
	NSString* name = [(NSString*) ABRecordCopyValue(record, kABPersonFirstNameProperty) autorelease];
	NSString* surname = [(NSString*) ABRecordCopyValue(record, kABPersonLastNameProperty) autorelease];
	
	return [self shortenedNameFromName:name surname:surname];
}

- (NSString*) shortenedNameFromName:(NSString*) name surname:(NSString*) surname;
{
	// should we shorten at all?
	// This includes all latin letters but not IPA extensions, spacing modifiers
	// and combining diacriticals.
	NSCharacterSet* latinLetters = [NSCharacterSet characterSetWithRange:NSMakeRange(0, 0x250)];
	
	BOOL shouldShorten = [name length] > 1 && [surname length] > 1;
	
	NSUInteger i;
	// while we have still more string to scan and we still have the intention
	// of shortening, see if there's some character there that we might not
	// like.
	for (i = 0; i < [name length] || !shouldShorten; i++)
		shouldShorten = [latinLetters characterIsMember:[name characterAtIndex:i]];
	for (i = 0; i < [surname length] || !shouldShorten; i++)
		shouldShorten = [latinLetters characterIsMember:[surname characterAtIndex:i]];
	
	if (!shouldShorten) {
		if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst) {
			if (!name && surname)
				return surname;
			else if (!surname && name)
				return name;
			else
				return [NSString stringWithFormat:@"%@ %@", name, surname];
		} else {
			if (!surname && name)
				return name;
			else if (!name && surname)
				return surname;
			else
				return [NSString stringWithFormat:@"%@ %@", surname, name];
		}
	}
	
	if (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst) {
		// "Emanuele V."		
		if (!name && surname)
			return surname;
		else if (!surname && name)
			return name;
		else {
			surname = [surname substringToIndex:1];
			return [NSString stringWithFormat:@"%@ %@.", name, surname];
		}
	} else {
		// "Vulcano, E."
		if (!name && surname)
			return surname;
		else if (!surname && name)
			return name;
		else {
			name = [name substringToIndex:1];
			return [NSString stringWithFormat:@"%@, %@.", surname, name];
		}
	}
}

- (id) initWithAddressBookRecord:(ABRecordRef) personRecord;
{
	if (self = [super init]) {
		[self loadPersonInfoFromAddressBookRecord:personRecord];
		self.type = kL0AddressBookPersonDataInPropertyListType;
		self.title = [self shortenedNameFromAddressBookRecord:personRecord];
		
		UIImage* image;
		if ([personInfo objectForKey:kL0AddressBookPersonInfoImageData])
			image = [UIImage imageWithData:[personInfo objectForKey:kL0AddressBookPersonInfoImageData]];
		else
			image = [UIImage imageNamed:@"ContactWithoutImageIcon.png"];
		self.representingImage = image;
	}
	
	return self;
}

- (void) storeToAppropriateApplication;
{
	NSDictionary* personInfoDictionary = [self personInfo];
	NSDictionary* info = [personInfoDictionary objectForKey:kL0AddressBookPersonInfoProperties];
	NSAssert(info, @"We must have the person info in order to store in the address book.");
	
	ABRecordRef person = ABPersonCreate();
	
	for (NSString* propertyIDString in info) {
		ABPropertyID propertyID = [propertyIDString intValue];
		id value = [info objectForKey:propertyIDString];
		
		CFTypeRef setValue;
		BOOL shouldReleaseSetValue = NO;
		if (![value isKindOfClass:[NSArray class]]) 
			setValue = (CFTypeRef) value;
		else {
			ABPropertyType propertyType = ABPersonGetTypeOfProperty(propertyID);
			ABMultiValueRef multi = ABMultiValueCreateMutable(propertyType);
			
			for (NSDictionary* valuePart in value) {
				id value = [valuePart objectForKey:kL0AddressBookValue];
				id label = [valuePart objectForKey:kL0AddressBookLabel];
				
				ABMultiValueAddValueAndLabel(multi, (CFTypeRef) value, (CFStringRef) label, NULL);
			}
			
			setValue = (CFTypeRef) multi;
			shouldReleaseSetValue = YES;
		}
		
		CFErrorRef error = NULL;
		ABRecordSetValue(person, propertyID, setValue, &error);
		
		if (error) {
			NSLog(@"%@", (id) error);
			CFRelease(error);
		}
		
		if (shouldReleaseSetValue)
			CFRelease(setValue);
	}
	
	NSData* imageData;
	if (imageData = [personInfoDictionary objectForKey:kL0AddressBookPersonInfoImageData]) {
		CFErrorRef error = NULL;
		
		ABPersonSetImageData(person, (CFDataRef) imageData, &error);
		
		if (error) {
			NSLog(@"%@", (id) error);
			CFRelease(error);
		}
	}
	
	ABAddressBookRef ab = ABAddressBookCreate();
	CFErrorRef error = NULL;
	ABAddressBookAddRecord(ab, person, &error);
	
	if (error) {
		NSLog(@"%@", (id) error);
		CFRelease(error);
	}
	
	ABAddressBookSave(ab, &error);
	
	if (error) {
		NSLog(@"%@", (id) error);
		CFRelease(error);
	}
	
	CFRelease(ab);
	CFRelease(person);
}

@end
