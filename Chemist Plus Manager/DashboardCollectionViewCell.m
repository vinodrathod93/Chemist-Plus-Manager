//
//  DashboardCollectionViewCell.m
//  NPartner
//
//  Created by adverto on 05/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "DashboardCollectionViewCell.h"

@implementation DashboardCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cellData = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void) awakeFromNib{
    self.cellData = [[NSMutableArray alloc] init];
}




#pragma mark -
#pragma mark - UITableview Methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellData count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dashboardTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dashboardTableViewCell"];
    }
    
    cell.textLabel.text = [self.cellData objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[self delegate] tableCellDidSelect:cell];
}

@end
