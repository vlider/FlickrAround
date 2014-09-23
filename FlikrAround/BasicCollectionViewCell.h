//
//  BasicCollectionViewCell.h
//  FlikrAround
//
//  Created by developer on 23.09.14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
