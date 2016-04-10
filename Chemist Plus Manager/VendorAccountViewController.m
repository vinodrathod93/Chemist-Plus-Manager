//
//  VendorAccountViewController.m
//  Neediator Partner
//
//  Created by adverto on 23/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "VendorAccountViewController.h"
#import "VendorProfileViewCell.h"

@interface VendorAccountViewController ()
{
    NSArray *_options;
    NSString *cellIdentifier;
}

@end

enum MyAccountCells {
    MyOrdersCell=0,
    MyBookingCell,
    MyAddressesCell,
    LeaderBoardCell
};

@implementation VendorAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showViewAfterLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    self.tableview.frame = CGRectMake(0, self.topLayoutGuide.length, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _options.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_options[section] isKindOfClass:[NSArray class]]) {
        
        NSArray *array = _options[section];
        
        return array.count;
        
    }
    else
        return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    vendorProfileViewCell
//    myAccountCellIdentifier
    
    
    if (indexPath.section == 0) {
        cellIdentifier = @"vendorProfileViewCell";
    } else
        cellIdentifier = @"myAccountCellIdentifier";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        [self configureProfileViewCell:cell forIndexPath:indexPath];
    } else
        [self configureBasicViewCell:cell forIndexPath:indexPath];
    
    
    
    return cell;
}


-(void)configureProfileViewCell:(VendorProfileViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    Vendor *user = [Vendor savedVendor];
    
    
    
    cell.storeName.text = user.storeName;
    cell.vendorUsername.text = user.username;
    
    NSURL *url = [NSURL URLWithString:user.profilePic];
    [cell.storeImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile_placeholder"] options:SDWebImageRefreshCached];
    cell.storeImageView.layer.cornerRadius = cell.storeImageView.frame.size.width/2.0f;
    cell.storeImageView.clipsToBounds = YES;
    
}


-(void)configureBasicViewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    if ([_options[indexPath.section] isKindOfClass:[NSArray class]]) {
        
        NSArray *array = _options[indexPath.section];
        
        cell.textLabel.text = array[indexPath.row];
    }
    else if(indexPath.section != 0) {
        cell.textLabel.text = _options[indexPath.section];
    }
    
    
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 212.0f;
    } else
        return 44.0f;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == MyOrdersCell) {
            [self.tabBarController setSelectedIndex:0];
        }
        else if (indexPath.row == MyAddressesCell) {
            
        }
        
        
    }
    else if (indexPath.section == 2) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self showWarningBeforeSignoutForCell:cell];
        
    }
    
}


-(void)showWarningBeforeSignoutForCell: (UITableViewCell *)cell {
    UIAlertController *alertController  = [UIAlertController alertControllerWithTitle:nil message:@"Are you Sure ?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *signoutAction = [UIAlertAction actionWithTitle:@"Yes, Signout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        
        
        // Remove all user data here
        [Vendor clearVendor];
        
        [self.tableview reloadData];
       
        
        // present login view or show login view.
        showLoginPageOn(self);
        
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:signoutAction];
    [alertController addAction:cancelAction];
    
    alertController.popoverPresentationController.sourceView = cell;
    alertController.popoverPresentationController.sourceRect = cell.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)showViewAfterLogin {
    
    Vendor *user = [Vendor savedVendor];
    
    if (user != nil) {
        _options = @[ @"", @[ @"Orders", @"Bookings", @"My Addresses", @"Leaderboard"],
                      @"Sign Out"];
//        
//        _iconsArray  = @[
//                         @"",
//                         @[@"store_fav", @"my_orders", @"booking", @"address", @"user"],
//                         @"signout"
//                         ];
//        
        
        [self.tableview reloadData];
    }
    else {
        
        // Show login view
        
        showLoginPageOn(self);
    }
    
}



@end
