//
//  PartnerAccountCell.h
//  NPartner
//
//  Created by adverto on 06/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartnerAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *userData;

@end
