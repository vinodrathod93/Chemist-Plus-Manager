//
//  Vendor.m
//  Neediator Partner
//
//  Created by adverto on 22/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "Vendor.h"

@implementation Vendor

#define kSavedVendor @"SavedVendor"

#pragma mark - Encoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.vendorID forKey:@"vendorID"];
    [encoder encodeObject:self.firstName forKey:@"FirstName"];
    [encoder encodeObject:self.lastName forKey:@"LastName"];
    [encoder encodeObject:self.email forKey:@"Email"];
    [encoder encodeObject:self.fullName forKey:@"FullName"];
    [encoder encodeObject:self.profilePic forKey:@"ProfilePicture"];
    [encoder encodeObject:self.access_token forKey:@"AccessToken"];
    [encoder encodeObject:self.default_country_id forKey:@"defaultCountry"];
    [encoder encodeObject:self.bill_address forKey:@"billAddress"];
    [encoder encodeObject:self.ship_address forKey:@"shipAddress"];
    [encoder encodeObject:self.addresses forKey:@"addresses"];
}

#pragma mark - Decoding
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _vendorID         = [decoder decodeObjectForKey:@"vendorID"];
        _firstName      = [decoder decodeObjectForKey:@"FirstName"];
        _lastName       = [decoder decodeObjectForKey:@"LastName"];
        _email          = [decoder decodeObjectForKey:@"Email"];
        _fullName       = [decoder decodeObjectForKey:@"FullName"];
        _profilePic     = [decoder decodeObjectForKey:@"ProfilePicture"];
        _access_token   = [decoder decodeObjectForKey:@"AccessToken"];
        _default_country_id = [decoder decodeObjectForKey:@"defaultCountry"];
        _bill_address       = [decoder decodeObjectForKey:@"billAddress"];
        _ship_address       = [decoder decodeObjectForKey:@"shipAddress"];
        _addresses          = [decoder decodeObjectForKey:@"addresses"];
        
    }
    return self;
}


-(void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:kSavedVendor];
    [defaults synchronize];
}

+ (id)savedVendor
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kSavedVendor];
    if (data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

+ (void)clearVendor
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kSavedVendor];
    [defaults synchronize];
}


@end
