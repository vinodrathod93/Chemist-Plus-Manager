//
//  OrdersRequestCollectionViewCell.m
//  NPartner
//
//  Created by adverto on 06/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "OrdersRequestCollectionViewCell.h"

@implementation OrdersRequestCollectionViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 10.f;
    self.layer.masksToBounds = YES;
    
    self.stageCountLabel.layer.cornerRadius = self.stageCountLabel.frame.size.width/2.f;
    self.stageCountLabel.layer.masksToBounds = YES;
}


@end
