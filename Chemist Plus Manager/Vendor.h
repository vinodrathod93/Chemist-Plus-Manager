//
//  Vendor.h
//  Neediator Partner
//
//  Created by adverto on 22/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vendor : NSObject

@property (nonatomic, copy) NSString *vendorID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *profilePic;
@property (nonatomic, copy) NSString *workingHours;
@property (nonatomic, copy) NSString *default_country_id;
@property (nonatomic, copy) NSDictionary *bill_address;
@property (nonatomic, copy) NSDictionary *ship_address;
@property (nonatomic, copy) NSArray *addresses;

-(void)save;
+ (id)savedVendor;
+ (void)clearVendor;

@end
