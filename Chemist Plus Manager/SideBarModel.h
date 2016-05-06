//
//  SideBarModel.h
//  NPartner
//
//  Created by adverto on 06/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SideBarModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *options;


@property(nonatomic) BOOL canBeExpanded;
@property(nonatomic) BOOL isExpanded;


- (instancetype)initWithKey:(NSString *)name andOptionsArray:(NSArray *)array;

@end
