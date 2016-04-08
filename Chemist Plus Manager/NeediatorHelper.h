//
//  NeediatorHelper.h
//  Neediator Partner
//
//  Created by Vinod Rathod on 08/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#ifndef NeediatorHelper_h
#define NeediatorHelper_h

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static void __logm(id msg) {
    NSLog(@"%@", msg);
}

static void loge(id err) {
    NSLog(@"Error: %@", err);
}

#ifdef NO_DEBUG
    #define logm(...)
#else
    #define logm __logm
#endif


typedef void (^LoginBlock)(BOOL isLoggedIn, id data);



static NSDate *JSDateToNSDate(NSString *dateTimeString) {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    NSDate *convertDate = [dateFormat dateFromString:dateTimeString];
    
    return convertDate;
}

#endif /* NeediatorHelper_h */
