//
//  DashboardCollectionViewCell.h
//  NPartner
//
//  Created by adverto on 05/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DashboardCollectionViewCell;

@protocol CollectionCellDelegate
-(void)tableCellDidSelect:(UITableViewCell *)cell;
@end

@interface DashboardCollectionViewCell : UICollectionViewCell<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cellData;


@property(weak,nonatomic) id<CollectionCellDelegate> delegate;

@end
