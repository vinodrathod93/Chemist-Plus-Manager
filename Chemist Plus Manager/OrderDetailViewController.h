//
//  OrderDetailViewController.h
//  Chemist Plus Manager
//
//  Created by adverto on 09/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *customerName;
@property (weak, nonatomic) IBOutlet UIImageView *prescriptionImage;
@property (weak, nonatomic) IBOutlet UILabel *orderAmount;
@property (weak, nonatomic) IBOutlet UILabel *address;

@property (strong, nonatomic) NSString *customerNameString;
@property (assign, nonatomic) NSInteger amount;
@property (strong, nonatomic) NSString *addressString;
@property (strong, nonatomic) NSString *imageString;
@property (strong, nonatomic) NSString *orderIDString;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)confirmPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
@end
