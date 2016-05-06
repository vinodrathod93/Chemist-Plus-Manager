//
//  SideBarModel.m
//  NPartner
//
//  Created by adverto on 06/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SideBarModel.h"

@implementation SideBarModel


- (instancetype)initWithKey:(NSString *)name andOptionsArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        
        
        self.name = name;
        self.options = array;
        
    }
    return self;
}

@end
