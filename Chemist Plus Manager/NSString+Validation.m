//
//  NSString+Validation.m
//  Neediator Partner
//
//  Created by adverto on 22/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)


- (BOOL)isValidEmail {
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailPredicate evaluateWithObject:self];
}

- (BOOL)isValidPassword {
    return (self.length >= 5);
}

- (BOOL)isValidName {
    return (self.length >= 1);
}

- (BOOL)isValidDOB {
    return (self.length >= 1);
}

@end
