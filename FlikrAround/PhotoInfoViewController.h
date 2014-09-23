//
//  PhotoInfoViewController.h
//  FlikrAround
//
//  Created by developer on 23.09.14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoInfoViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDictionary *photoInfo;
@end
