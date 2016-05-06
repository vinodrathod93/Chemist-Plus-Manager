//
//  SideBarViewController.m
//  Blossom Vinegars
//
//  Created by Vinod Rathod on 08/11/15.
//  Copyright © 2015 Vinod Rathod. All rights reserved.
//

#import "SideBarViewController.h"
#import "SideBarModel.h"
#import "SideBarTableViewCell.h"
#import "PartnerAccountCell.h"
#import "OrderListTableViewController.h"

@interface SideBarViewController ()

@end

typedef NS_ENUM(uint16_t, sections) {
    SectionAccount = 0,
    SectionOptions
};


@implementation SideBarViewController {
    NSArray *menuItems;
    NSMutableArray *allOptions;
    BOOL _isExpanded;
    UITapGestureRecognizer *_headerGestureRecognizer;
    BOOL _isTapped;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    menuItems = @[
                  [[SideBarModel alloc] initWithKey:@"Dashboard" andOptionsArray:@[]],
                  [[SideBarModel alloc] initWithKey:@"Orders" andOptionsArray:@[@"New Orders", @"Return Orders"]],
                  [[SideBarModel alloc] initWithKey:@"Products" andOptionsArray:@[@"Add Items", @"Manage Items"]],
                  [[SideBarModel alloc] initWithKey:@"Financials" andOptionsArray:@[]],
                  [[SideBarModel alloc] initWithKey:@"Communicate" andOptionsArray:@[@"Advertise", @"Offers", @"Suggestion", @"Feedback", @"Report Problem"]]
                  
                  ];
    
    
    allOptions = [[NSMutableArray alloc] initWithArray:menuItems];
    
    _headerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderTapGesture:)];
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return section == SectionOptions ? allOptions.count : 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PartnerOptionsCellIdentifier";
    static NSString *AccountCellIdentifier = @"partnerAccountCellIdentifier";
    
    
    if (indexPath.section == SectionOptions) {
        SideBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.indentationWidth = 20;
        
        
        
        if ([allOptions[indexPath.row] isKindOfClass:[NSString class]]) {
            NSString *insideOption = allOptions[indexPath.row];
            
            
            
            cell.optionAccessoryView.image = nil;
            cell.optionLabel.text = insideOption;
            
            cell.indentationLevel = 1;
            
            
        }
        else {
            
            SideBarModel *model = [allOptions objectAtIndex:indexPath.row];
            
            cell.optionLabel.text = model.name;
            
            cell.indentationLevel = 0;
            
            if (model.options.count > 0) {
                
                model.canBeExpanded = YES;
                cell.optionAccessoryView.image  = [self viewForDisclosureForState:_isExpanded];
                
            }
            else {
                cell.optionAccessoryView.image  = nil;
            }
            
        }
        
        
        return cell;
    }
    else {
        // Account
        
        
        PartnerAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier forIndexPath:indexPath];
//        
//        if (!cell)
//            cell = [[PartnerAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AccountCellIdentifier];
        
        cell.userData = @[ @"User", @"Add", @"User", @"Add", @"User", @"Add"];
        [cell.collectionView reloadData];
        
        return cell;
    
    }
    
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == SectionOptions) {
        
        
        id model = allOptions[indexPath.row];
        
        SideBarTableViewCell *selected_cell = [tableView cellForRowAtIndexPath:indexPath];
        
        
        if ([model isKindOfClass:[SideBarModel class]]) {
            
            SideBarModel *model = allOptions[indexPath.row];
            
            if (model.canBeExpanded) {
                if (model.isExpanded) {
                    [self collapseCellsFromIndexOf:model indexPath:indexPath tableView:tableView];
                    selected_cell.optionAccessoryView.image = [self viewForDisclosureForState:NO];
                    _isExpanded = NO;
                }
                else {
                    [self expandCellsFromIndexOf:model indexPath:indexPath tableView:tableView];
                    selected_cell.optionAccessoryView.image = [self viewForDisclosureForState:YES];
                    _isExpanded = YES;
                }
            }
        }
        else {
            
            
            
        }
    }
    else {
        
        // Account
        
        
    }
    
    
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    header.backgroundColor = [UIColor lightGrayColor];
    header.userInteractionEnabled = YES;
    
    
    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(self.view.frame) - 20, 30)];
    headingLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.f];
    
    
    
    if (section == SectionOptions) {
        headingLabel.text = @"Chemist";
    }
    else {
        headingLabel.text = @"Partner Name";
        
        [header addGestureRecognizer:_headerGestureRecognizer];
    }
    
    [header addSubview:headingLabel];
    
    return header;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (indexPath.section == SectionAccount) {
        
        CGFloat height;
        
        if (_isTapped) {
            height = CGRectGetHeight(self.view.frame)-60;
        }
        else
            height = 0;
        
        return height;
    }
    else
        return 44.f;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}


-(void)collapseCellsFromIndexOf:(SideBarModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSLog(@"collapseCellsFromIndexOf");
    
        
        NSInteger collapseCount = [self numberOfCellsToBeCollapsed:model];
        NSRange collapseRange = NSMakeRange(indexPath.row + 1, collapseCount);
        
        
        [allOptions removeObjectsInRange:collapseRange];
        model.isExpanded = NO;
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i<collapseRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:indexPath.section]];
        }
        // Animate and delete
        [tableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
}



-(void)expandCellsFromIndexOf:(SideBarModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
        if (model.options.count > 0) {
            model.isExpanded = YES;
            
            int i=0;
            
            for (NSString *insideOption in model.options) {
                [allOptions insertObject:insideOption atIndex:indexPath.row + i + 1];
                i++;
            }
            
            NSRange expandedRange = NSMakeRange(indexPath.row, i);
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i< expandedRange.length; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:indexPath.section]];
            }
            
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            
            [tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    
    
    
}


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Set the title of navigation bar by using the menu items
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//    destViewController.viewControllers[0].title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
//}



-(UIImage *) viewForDisclosureForState:(BOOL) isExpanded
{
    NSString *imageName;
    if(isExpanded)
    {
        imageName = @"Collapse Arrow";
    }
    else
    {
        imageName = @"Expand Arrow";
    }
    
    return [UIImage imageNamed:imageName];
}


-(NSInteger) numberOfCellsToBeCollapsed:(SideBarModel *) model
{
    
    NSLog(@"numberOfCellsToBeCollapsed");
    
    NSInteger total = 0;
    
    if(model.isExpanded)
    {
        // Set the expanded status to no
        model.isExpanded = NO;
        NSArray *child = model.options;
        
        total = child.count;
        
    }
    return total;
}


-(void)handleHeaderTapGesture:(id)sender {
    
    _isTapped = !_isTapped;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
}

@end
