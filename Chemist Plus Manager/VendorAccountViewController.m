//
//  VendorAccountViewController.m
//  Neediator Partner
//
//  Created by adverto on 23/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "VendorAccountViewController.h"

@interface VendorAccountViewController ()

@end

@implementation VendorAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myAccountCellIdentifier" forIndexPath:indexPath];
    
    return cell;
}
@end
