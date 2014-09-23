//
//  PhotoInfoViewController.m
//  FlikrAround
//
//  Created by developer on 23.09.14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import "PhotoInfoViewController.h"

@interface PhotoInfoViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation PhotoInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake(0.f, 0.f, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 1.5;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView addSubview:self.imageView];
    
    [self.scrollView setZoomScale:0.9 animated:YES];

}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.center = self.scrollView.center;
    
    float sizeCenterHeight = self.scrollView.contentSize.height/2.f;
    float sizeCenterWidth = self.scrollView.contentSize.width/2.f;
    
    if(self.scrollView.contentSize.height < self.scrollView.frame.size.height)
        sizeCenterHeight = self.scrollView.frame.size.height/2.f;
    
    if(self.scrollView.contentSize.width < self.scrollView.frame.size.width)
        sizeCenterWidth = self.scrollView.frame.size.width/2.f;
    
    self.imageView.center = CGPointMake(sizeCenterWidth, sizeCenterHeight-64);
    
    //    self.scallingUI = 1.5/scrollView.zoomScale;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.imageView.center = self.scrollView.center;
    
    float sizeCenterHeight = self.scrollView.contentSize.height/2.f;
    float sizeCenterWidth = self.scrollView.contentSize.width/2.f;
    
    if(self.scrollView.contentSize.height < self.scrollView.frame.size.height)
        sizeCenterHeight = self.scrollView.frame.size.height/2.f;
    
    if(self.scrollView.contentSize.width < self.scrollView.frame.size.width)
        sizeCenterWidth = self.scrollView.frame.size.width/2.f;
    
    self.imageView.center = CGPointMake(sizeCenterWidth, sizeCenterHeight-64);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
