//
//  DashboardViewController.h
//  NPartner
//
//  Created by adverto on 05/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "DashboardFlowLayout.h"
#import "DashboardCollectionViewCell.h"
#import <SWRevealViewController/SWRevealViewController.h>

@interface DashboardViewController : UIViewController<iCarouselDelegate, iCarouselDataSource, UICollectionViewDataSource, CollectionCellDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dashMenuButton;
@end
