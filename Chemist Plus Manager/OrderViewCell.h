//
//  OrderViewCell.h
//  
//
//  Created by adverto on 09/07/15.
//
//

#import <UIKit/UIKit.h>

@interface OrderViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *orderAmount;
@property (weak, nonatomic) IBOutlet UILabel *orderItems;
@property (weak, nonatomic) IBOutlet UILabel *orderPaymentType;


@end
