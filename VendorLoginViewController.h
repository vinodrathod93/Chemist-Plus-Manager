//
//  VendorLoginViewController.h
//  Neediator Partner
//
//  Created by adverto on 22/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
- (IBAction)loginPressed:(id)sender;
@end
