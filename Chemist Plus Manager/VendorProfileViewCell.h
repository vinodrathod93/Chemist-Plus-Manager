//
//  VendorProfileViewCell.h
//  NPartner
//
//  Created by Vinod Rathod on 11/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorProfileViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *vendorUsername;
@end
