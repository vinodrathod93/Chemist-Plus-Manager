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


@property (nonatomic, strong) NSArray *pendingArray;

@property (nonatomic, strong) UIView *overlayView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (retain) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSArray *unsortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

@property (nonatomic, assign) BOOL didViewLoadedFirstTime;

@end

NSString * const CELL_IDENTIFIER = @"ordersCell";
NSString * const JSON_DATA_URL = @"http://neediator.in/vendor/vendorWS.asmx/vendor_dashboard";



@implementation OrderListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didViewLoadedFirstTime = YES;
    

    [self checkVendorLogin];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkVendorLogin) name:@"loggedInRefreshOrderNotification" object:nil];
    
}




-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}


- (IBAction)refreshOrders:(id)sender {
    
    [self checkVendorLogin];
}


- (void)checkVendorLogin {
    
    Vendor *savedVendor = [Vendor savedVendor];
    
    if (savedVendor != nil) {
        NSLog(@"Nothing");
        
        
        [self fetchDataAndUpdateTableView:savedVendor.vendorID];
        
    }
    else {
        [self presentLoginPage];
        
    }

    
}


-(void)presentLoginPage {
    VendorLoginViewController *vendorLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"vendorLoginVC"];
    [self presentViewController:vendorLoginVC animated:YES completion:nil];
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.sections.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *ordersOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return ordersOnThisDay.count;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *ordersOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[OrderViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    NSDictionary *order = [ordersOnThisDay objectAtIndex:indexPath.row];
    
    
    cell.orderNumber.text = [order valueForKey:@"OrderNo"];
    cell.nameLabel.text = [self customerNameOfOrder:order];
    cell.location.text  = [self addressOfOrder:order];
    cell.orderPaymentType.text = [self paymentTypeOfOrder:order];
    
    if ([self isPrescriptionOrder:order]) {
        cell.orderAmount.text = @"Prescription";
        cell.orderItems.text = @"";
    }
    else {
        cell.orderAmount.text = convertToRupees([self totalAmountOfOrder:order]);
        cell.orderItems.text = [NSString stringWithFormat:@"Items: %ld",(long)[self itemsCountFromOrder:order]];
    }
    
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *ordersOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    NSDictionary *order = ordersOnThisDay[indexPath.row];
    
    
    
    OrderDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderDetailsVC"];
    detailVC.customerNameString = [self customerNameOfOrder:order];
    detailVC.addressString =  [self addressOfOrder:order];
    detailVC.amount = [self totalAmountOfOrder:order];
    
    
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



-(void)setupDataSourceForSection:(NSArray *)allOrders {
    
    
    
    self.sections = [NSMutableDictionary dictionary];
    for (NSDictionary *order in allOrders)
    {
        NSDate *date = JSDateToNSDate([self dateStringFromOrder:order]);
        
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:date];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *ordersOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        if (ordersOnThisDay == nil) {
            ordersOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [self.sections setObject:ordersOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the event to the list for this day
        [ordersOnThisDay addObject:order];
    }
    
    // Create a sorted list of days
    NSArray *unsortedDays = [self.sections allKeys];
    self.unsortedDays = unsortedDays;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.sortedDays = [unsortedDays sortedArrayUsingDescriptors:descriptors];

    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    
    
    logm(self.sortedDays);
}



-(NSString *)dateStringFromOrder:(NSDictionary *)order {
    return [order valueForKey:@"OrderDate"];
}


-(NSInteger)itemsCountFromOrder:(NSDictionary *)order {
    NSArray *items = [order objectForKey:@"order_details"];
    
    return items.count;
}

-(NSString *)addressOfOrder:(NSDictionary *)order {
    
    NSArray *addressArray = [order objectForKey:@"address"];
    if (addressArray != nil && addressArray.count != 0) {
        NSDictionary *address = [addressArray lastObject];
        
        return [[NSString stringWithFormat:@"%@, %@, %@", address[@"address"], address[@"city"], address[@"state"]] capitalizedString];
    }
    else
        return @"";
    
}

-(NSString *)timeOfOrder:(NSDictionary *)order {
    NSString *time = [order valueForKey:@"OrderTime"];
    
    return time;
}

-(BOOL)isPrescriptionOrder:(NSDictionary *)order {
    NSNumber *isPrescription = [order objectForKey:@"isPrescription"];
    
    return isPrescription.boolValue;
}

-(NSInteger)totalAmountOfOrder:(NSDictionary *)order {
    NSArray *orderDetails = [order objectForKey:@"order_details"];
    if (orderDetails != nil && orderDetails.count != 0) {
        
        __block NSUInteger amount = 0;
        [orderDetails enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger itemAmount = [[item valueForKey:@"amount"] integerValue];
            
            amount += itemAmount;
        }];
        
        return amount;
    }
    else
        return 0;
}


-(NSString *)paymentTypeOfOrder:(NSDictionary *)order {
    NSString *payment = [order valueForKey:@"payment"];
    
    return payment;
}

-(NSString *)customerNameOfOrder:(NSDictionary *)order {
    NSArray *userArray = [order objectForKey:@"users"];
    if (userArray != nil && userArray.count != 0) {
        NSDictionary *user = [userArray lastObject];
        
        return [[NSString stringWithFormat:@"%@ %@", user[@"name"],user[@"lastname"]] capitalizedString];
    }
    else
        return @"";
    
}


- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
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


-(void)fetchDataAndUpdateTableView:(NSString *)vendorID {
    [self loadActivityIndicator];
    
    
    NSString *loginURL = [NSString stringWithFormat:@"%@?user_id=%@&status_id=%@", JSON_DATA_URL, vendorID, @"1"];
    
    NSURL *url = [NSURL URLWithString:loginURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:2*1024*1024 diskCapacity:10*1024*1024 diskPath:@"OrdersData"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            
            if (error != nil) {
                loge(error);
            }
            else {
                
                self.pendingArray = [json objectForKey:@"Orders"][0][@"Orderdetails"];
                
                [self.activityIndicator stopAnimating];
                self.activityIndicator.hidden = YES;
                [self.overlayView removeFromSuperview];
                
                [self setupDataSourceForSection:self.pendingArray];
                
                [self.tableView reloadData];
                
            }
            
            
        }];
        
        
        
        
    }];
    
    [task resume];
    
    
}

@end
