//
//  ViewController.m
//  FlikrAround
//
//  Created by Valerii Lider on 9/23/14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import "ViewController.h"
#import "FlickrService.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[FlickrService sharedInstance] login];
}

@end
