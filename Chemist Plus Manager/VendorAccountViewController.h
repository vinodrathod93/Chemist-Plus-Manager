//
//  VendorAccountViewController.h
//  Neediator Partner
//
//  Created by adverto on 23/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VendorAccountViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end
