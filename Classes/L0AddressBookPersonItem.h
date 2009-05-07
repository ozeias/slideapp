//
//  L0AddressBookPersonItem.h
//  Slide
//
//  Created by ∞ on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0MoverItem.h"

#import <AddressBook/AddressBook.h>

#define kL0AddressBookPersonDataInPropertyListType @"net.infinite-labs.Slide.AddressBookPersonPropertyList"

@interface L0AddressBookPersonItem : L0MoverItem {
	NSDictionary* personInfo;
}

- (id) initWithAddressBookRecord:(ABRecordRef) personRecord;

@property(readonly) NSDictionary* personInfo;

@end
