//
//  DashboardViewController.m
//  NPartner
//
//  Created by adverto on 05/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "DashboardViewController.h"


@interface DashboardViewController ()

@property (nonatomic, strong) NSArray *profileImages;
@property (nonatomic, strong) NSDictionary *dashboardData;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeCylinder;
    self.carousel.vertical = YES;
    self.carousel.pagingEnabled = YES;
    
    
    
    self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    self.profileImages = @[@"http://g-ecx.images-amazon.com/images/G/31/img15/video-games/Gateway/new-year._UX1500_SX1500_CB285786565_.jpg",
                          @"http://g-ecx.images-amazon.com/images/G/31/img15/Shoes/December/4._UX1500_SX1500_CB286226002_.jpg",
                          @"http://g-ecx.images-amazon.com/images/G/31/img15/softlines/apparel/201512/GW/New-GW-Hero-1._UX1500_SX1500_CB301105718_.jpg",
                          @"http://img5a.flixcart.com/www/promos/new/20151229_193348_730x300_image-730-300-8.jpg",
                          @"http://img5a.flixcart.com/www/promos/new/20151228_231438_730x300_image-730-300-15.jpg"];
    
    _dashboardData = @{
                       @"Account Details" : @[
                               @"Rent Paid Upto",
                               @"Membership Valid Upto"],
                       @"Orders Summary" : @[
                               @"Pending",
                               @"Approved",
                               @"Ready",
                               @"Out for Delivery",
                               @"Completed",
                               @"Cancelled",
                               @"Returned"],
                       @"Products Summary" : @[
                               @"Items Sold",
                               @"Items Listed"],
                       @"Ledger" : @[
                               ],
                       @"Leaderboard" : @[
                               @"1. Brian W. Kernighan",
                               @"2. Dennis M. Ritchie",
                               @"3. Sigmund Freud"]
                       };
    
    
    [self.carousel reloadData];
    
    self.collectionView.pagingEnabled = YES;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.dashMenuButton setTarget: self.revealViewController];
        [self.dashMenuButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.profileImages.count;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    if (view == nil)
    {
        
        NSString *image_string = self.profileImages[index];
        
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(carousel.frame) - 100, CGRectGetHeight(carousel.frame))];
        NSURL *image_url = [NSURL URLWithString:image_string];
        
        [(UIImageView *)view sd_setImageWithURL:image_url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
    }
    
    return view;
}


-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    
    
    NSInteger index = self.profileImages.count -1 - carousel.currentItemIndex;
    
    index ++;
    NSLog(@"Current Index is %ld and calc. index is %ld", (long)carousel.currentItemIndex, (long)index);
    
    if(index == self.profileImages.count) {
        index = 0;
    }
    
    self.pageControl.currentPage = index;
}




#pragma mark -
#pragma mark - UICollection View Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dashboardData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DashboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dashboardCollectionViewCell" forIndexPath:indexPath];
    
//    cell
    
    NSString *key = [[_dashboardData allKeys] objectAtIndex:indexPath.item];
    cell.headerLabel.text = key;
    cell.cellData = [_dashboardData objectForKey:key];
    
    cell.delegate = self;
    cell.tag = indexPath.item;
    [cell.tableView reloadData];
    
    return cell;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.frame)/1.5, CGRectGetHeight(collectionView.frame) - 30);
}



-(void)tableCellDidSelect:(UITableViewCell *)cell {
    NSLog(@"Selected Cell is %@", cell.textLabel.text);
}






@end
