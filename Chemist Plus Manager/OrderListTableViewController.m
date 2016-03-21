//
//  OrderListTableViewController.m
//  
//
//  Created by adverto on 09/07/15.
//
//

#import "OrderListTableViewController.h"
#import "OrderDetailViewController.h"
#import "OrderViewCell.h"

@interface OrderListTableViewController ()

@property (nonatomic, strong)NSMutableDictionary *jsonDictionary;

@property (nonatomic, strong) UIView *overlayView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (retain) NSMutableDictionary *tableViewCells;
@property (retain) NSMutableArray *tableViewSections;

@property (nonatomic, assign) BOOL didViewLoadedFirstTime;

@end

NSString * const CELL_IDENTIFIER = @"ordersCell";
NSString * const JSON_DATA_URL = @"http://neediator.in/NeediatorWS.asmx/vendordashboard";


@implementation OrderListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didViewLoadedFirstTime = YES;
    
//    [self fetchDataAndUpdateTableView];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if (!self.didViewLoadedFirstTime) {
        [self fetchDataAndUpdateTableView];
    }
    
}

-(void)fetchDataAndUpdateTableView {
    [self loadActivityIndicator];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self loadJSONData];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            [self.overlayView removeFromSuperview];
            
            [self setupDataSourceForSection:[self loadOrderDates]];
            
            [self.tableView reloadData];
        });
    });
}


-(void)loadJSONData {
    NSURL *url = [NSURL URLWithString:JSON_DATA_URL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSError *error;
    self.jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if (error != nil) {
        NSLog(@"Error %@",error);
    } else {
        NSLog(@"%@",self.jsonDictionary);
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.tableViewSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id key = [self.tableViewSections objectAtIndex:section];
    NSArray *tableViewCellsForSection = [self.tableViewCells objectForKey:key];
    return tableViewCellsForSection.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.tableViewSections objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[OrderViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    cell.nameLabel.text = [[[self.jsonDictionary valueForKey:@"name"]objectAtIndex:indexPath.row] capitalizedString];
    cell.location.text = [[self.jsonDictionary valueForKey:@"city_name"] objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OrderDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderDetailsVC"];
    detailVC.customerNameString = [[[self.jsonDictionary valueForKey:@"name"] objectAtIndex:indexPath.row] capitalizedString];
    detailVC.addressString = [[[self.jsonDictionary valueForKey:@"address"] objectAtIndex:indexPath.row] capitalizedString];
    detailVC.phoneNumberString = [[[self.jsonDictionary valueForKey:@"phone"] objectAtIndex:indexPath.row] capitalizedString];
    detailVC.imageString = [[self.jsonDictionary valueForKey:@"image"] objectAtIndex:indexPath.row];
    detailVC.orderIDString = [[self.jsonDictionary valueForKey:@"orderid"]objectAtIndex:indexPath.row];
    
    self.didViewLoadedFirstTime = NO;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)setupDataSourceForSection:(NSArray *)sortedDateArray {
    
    NSLog(@"%@",sortedDateArray);
    self.tableViewCells = [NSMutableDictionary dictionaryWithCapacity:0];
    self.tableViewSections = [NSMutableArray arrayWithCapacity:0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = calendar.timeZone;
    [dateFormatter setDateFormat:@"EE, d LLLL yyyy"];
    
    NSUInteger dateComponents = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSInteger previousYear = -1;
    NSInteger previousMonth = -1;
    NSInteger previousDay = -1;
    
    NSMutableArray *tableviewCellsForSection = nil;
    
    for (NSDate* date in sortedDateArray)
    {
        NSDateComponents* components = [calendar components:dateComponents fromDate:date];
        NSInteger year = [components year];
        NSInteger month = [components month];
        NSInteger day = [components day];
        if (year != previousYear || month != previousMonth || day != previousDay)
        {
            NSString *sectionHeading = [dateFormatter stringFromDate:date];
            [self.tableViewSections addObject:sectionHeading];
            tableviewCellsForSection = [NSMutableArray arrayWithCapacity:0];
            [self.tableViewCells setObject:tableviewCellsForSection forKey:sectionHeading];
            previousDay = day;
            previousYear = year;
            previousMonth = month;
        }
        [tableviewCellsForSection addObject:date];
    }
    
    NSLog(@"%@",self.tableViewCells);
}

-(NSArray *)loadOrderDates {
    NSMutableArray *allDates = [NSMutableArray array];
    
    for (NSArray *order in self.jsonDictionary) {
        NSString *dateString = [order valueForKey:@"order_date"];
        NSDate *order_date = [self convertToDateFromString:dateString];
        
        [allDates addObject:order_date];
    }
    NSLog(@"%@",allDates);
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    
    return [allDates sortedArrayUsingDescriptors:descriptors];
}

-(NSDate *)convertToDateFromString:(NSString *)string {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *convertDate = [dateFormat dateFromString:string];
    
    return convertDate;
}

-(void)loadActivityIndicator {
    self.overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    
    [self.navigationController.view addSubview:self.overlayView];
    
    [self.activityIndicator startAnimating];
}

@end
