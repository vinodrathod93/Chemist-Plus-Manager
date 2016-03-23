//
//  NSString+Validation.h
//  Neediator Partner
//
//  Created by adverto on 22/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (BOOL)isValidEmail;
- (BOOL)isValidPassword;
- (BOOL)isValidName;
- (BOOL)isValidDOB;
- (BOOL)isValidVendorID;

@end
