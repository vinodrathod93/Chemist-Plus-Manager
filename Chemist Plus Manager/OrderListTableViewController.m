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
#import "Vendor.h"
#import "VendorLoginViewController.h"

@interface OrderListTableViewController ()

//@property (nonatomic, strong) NSMutableDictionary *jsonDictionary;
@property (nonatomic, strong) NSArray *pendingArray;

@property (nonatomic, strong) UIView *overlayView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (retain) NSMutableDictionary *tableViewCells;
@property (retain) NSMutableArray *tableViewSections;

@property (nonatomic, assign) BOOL didViewLoadedFirstTime;

@end

NSString * const CELL_IDENTIFIER = @"ordersCell";
NSString * const JSON_DATA_URL = @"http://neediator.in/vendor/vendorWS.asmx/vendordashboard";


@implementation OrderListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didViewLoadedFirstTime = YES;
    

    
    Vendor *savedVendor = [Vendor savedVendor];
    
    if (savedVendor != nil) {
        NSLog(@"Nothing");
        
        
            [self fetchDataAndUpdateTableView:savedVendor.vendorID];
        
    }
    else {
        
        VendorLoginViewController *vendorLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"vendorLoginVC"];
        [self presentViewController:vendorLoginVC animated:YES completion:nil];
    }
    
    
    
}




-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}


- (IBAction)refreshOrders:(id)sender {
    
    Vendor *savedVendor = [Vendor savedVendor];
    
    if (savedVendor != nil) {
        NSLog(@"Nothing");
        
        
        [self fetchDataAndUpdateTableView:savedVendor.vendorID];
        
    }
    else {
        
        VendorLoginViewController *vendorLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"vendorLoginVC"];
        [self presentViewController:vendorLoginVC animated:YES completion:nil];
    }
}

-(void)fetchDataAndUpdateTableView:(NSString *)vendorID {
    [self loadActivityIndicator];
    
    
    NSString *loginURL = [NSString stringWithFormat:@"%@?user_id=%@", JSON_DATA_URL, vendorID];
    
    NSURL *url = [NSURL URLWithString:loginURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
   
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:2*1024*1024 diskCapacity:10*1024*1024 diskPath:@"OrdersData"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error != nil) {
            NSLog(@"Error %@",error);
        }
        else {
            
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 
                 self.pendingArray = [json objectForKey:@"Orders"][0][@"pending_list"];
                 
                 [self.activityIndicator stopAnimating];
                 self.activityIndicator.hidden = YES;
                 [self.overlayView removeFromSuperview];
                 
                 [self setupDataSourceForSection:[self loadOrderDates]];
                 
                 [self.tableView reloadData];
                 
             }];
            
        }
        
    }];
    
    [task resume];
            
    
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
    
    NSDictionary *order = self.pendingArray[indexPath.section];
    
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[OrderViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    cell.nameLabel.text = [order valueForKey:@"OrderNo"];
    cell.location.text  = [order valueForKey:@"OrderDate"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *order = self.pendingArray[indexPath.section];
    
    NSLog(@"%@", order);
    
    NSDictionary *user = [order objectForKey:@"users"][0];
    NSDictionary *address = [order objectForKey:@"address"][0];
    
    
    OrderDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderDetailsVC"];
    detailVC.customerNameString = [[user valueForKey:@"name"] capitalizedString];
    detailVC.addressString =  [NSString stringWithFormat:@"%@ - %@", [[address valueForKey:@"address"] capitalizedString], [[address valueForKey:@"city"] capitalizedString]];
    detailVC.phoneNumberString = @"No Phone number";
    
    
    BOOL isPrescription = [[order valueForKey:@"isPrescription"] boolValue];
    
    if (isPrescription) {
        NSArray *presOrder = [order objectForKey:@"upload_prescription"];
        
        if (presOrder.count == 0) {
            detailVC.imageString = nil;
        }
        else
            detailVC.imageString = [presOrder lastObject][@"image_url"];
    }
    else {
        
        NSArray *genOrder = [order objectForKey:@"order_details"];
        
        if (genOrder.count == 0) {
            detailVC.imageString = nil;
        }
        else
            detailVC.imageString = genOrder[0][@"image_url"];
    }
    
    detailVC.orderIDString = [order valueForKey:@"id"];
    
    
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
    NSMutableArray *allDates = [[NSMutableArray alloc] init];
    
    for (NSArray *order in self.pendingArray) {
        NSString *dateString = [order valueForKey:@"OrderDate"];
        NSDate *order_date = [self convertToDateFromString:dateString];
        
        [allDates addObject:order_date];
    }
    NSLog(@"%@",allDates);
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    
    return [allDates sortedArrayUsingDescriptors:descriptors];
}

-(NSDate *)convertToDateFromString:(NSString *)string {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
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
