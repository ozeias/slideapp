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

static ABPropertyID L0AddressBookGetPropertyWithIndex(int idx) {
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
		
		L0Log(@"kABPersonLastNameProperty == %d at %p", kABPersonLastNameProperty, &kABPersonLastNameProperty);
		
		int i; for (i = 0; i < kL0AddressBookCountOfProperties; i++)
			L0AddressBookProperties[i] = properties[i];
		
		initialized = YES;
	}
	
	return L0AddressBookProperties[idx];
}

@interface L0AddressBookPersonItem ()

- (BOOL) loadPersonInfoFromData:(NSData*) payload;
- (void) loadPersonInfoFromAddressBookRecord:(ABRecordRef) record;

- (NSString*) shortenedNameFromAddressBookRecord:(ABRecordRef) record;
- (NSString*) shortenedNameFromNickname:(NSString*) nickname name:(NSString*) name surname:(NSString*) surname companyName:(NSString*) companyName;

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
		
		// There is a stupid bug where kABPersonLastNameProperty and other constants
		// from AB are zero'd until I call an AB* function, so I'm doing that once now.
		static BOOL didCallAddressBookCreate = NO;
		if (!didCallAddressBookCreate) {
			ABAddressBookRef ab = ABAddressBookCreate();
			CFRelease(ab);
			didCallAddressBookCreate = YES;
		}
		
		self.type = kL0AddressBookPersonDataInPropertyListType;
		
		NSString* nameKey = [NSString stringWithFormat:@"%d", kABPersonFirstNameProperty];
		NSString* surnameKey = [NSString stringWithFormat:@"%d", kABPersonLastNameProperty];
		NSString* nicknameKey = [NSString stringWithFormat:@"%d", kABPersonNicknameProperty];
		NSString* organizationKey = [NSString stringWithFormat:@"%d", kABPersonOrganizationProperty];
		
		L0Log(@"kABPersonLastNameProperty == %d at %p", kABPersonLastNameProperty, &kABPersonLastNameProperty);
		
		NSDictionary* properties = [[self personInfo] objectForKey:kL0AddressBookPersonInfoProperties];
		
		NSString* name = [properties objectForKey:nameKey];
		NSString* surname = [properties objectForKey:surnameKey];
		NSString* nickname = [properties objectForKey:nicknameKey];
		NSString* companyName = [properties objectForKey:organizationKey];
		
		self.title = [self shortenedNameFromNickname:nickname name:name surname:surname companyName:companyName];
		
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
	NSString* nickname = [(NSString*) ABRecordCopyValue(record, kABPersonNicknameProperty) autorelease];
	NSString* name = [(NSString*) ABRecordCopyValue(record, kABPersonFirstNameProperty) autorelease];
	NSString* surname = [(NSString*) ABRecordCopyValue(record, kABPersonLastNameProperty) autorelease];
	NSString* companyName = [(NSString*) ABRecordCopyValue(record, kABPersonOrganizationProperty) autorelease];
	
	return [self shortenedNameFromNickname:nickname name:name surname:surname companyName:companyName];
}

- (NSString*) shortenedNameFromNickname:(NSString*) nickname name:(NSString*) name surname:(NSString*) surname companyName:(NSString*) companyName;
{	
	if (nickname)
		return nickname;
	
	if (!name && !surname) {
		if (companyName)
			return companyName;
		else
			return @"?";
	}
	
	// should we shorten at all?
	// This includes all latin letters but not IPA extensions, spacing modifiers
	// and combining diacriticals.
	NSCharacterSet* latinLetters = [NSCharacterSet characterSetWithRange:NSMakeRange(0, 0x250)];
	
	BOOL shouldShorten = [name length] > 1 && [surname length] > 1;
	
	NSUInteger i;
	// while we have still more string to scan and we still have the intention
	// of shortening, see if there's some character there that we might not
	// like.
//	for (i = 0; i < [name length] || !shouldShorten; i++)
//		shouldShorten = [latinLetters characterIsMember:[name characterAtIndex:i]];
//	for (i = 0; i < [surname length] || !shouldShorten; i++)
//		shouldShorten = [latinLetters characterIsMember:[surname characterAtIndex:i]];

	// stupid buggy for loops I hate you :'(
	// NOTE TO SELF: NEVER EVER WEAKEN BREAK CONDITIONS
	// and if you're not sure about the semantics of a for loop, it's better to
	// unwind it.
	i = 0;
	while (i < [name length]) {
		shouldShorten = [latinLetters characterIsMember:[name characterAtIndex:i]];
		if (shouldShorten)
			break;
		i++;
	}
	
	i = 0;
	while (i < [surname length]) {
		shouldShorten = [latinLetters characterIsMember:[surname characterAtIndex:i]];
		if (shouldShorten)
			break;
		i++;
	}
	
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
				id multiValue = [valuePart objectForKey:kL0AddressBookValue];
				id label = [valuePart objectForKey:kL0AddressBookLabel];
				
				ABMultiValueAddValueAndLabel(multi, (CFTypeRef) multiValue, (CFStringRef) label, NULL);
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
