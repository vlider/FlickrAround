//
//  PhotoInfoViewController.m
//  FlikrAround
//
//  Created by developer on 23.09.14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import "PhotoInfoViewController.h"
#import "FlickrService.h"

@interface PhotoInfoViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@property (nonatomic, strong) NSDictionary *infoDict;

@end

@implementation PhotoInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSString *photoID       = self.photoInfo[@"id"];
    NSString *photoSecret   = self.photoInfo[@"secret"];
    NSString *title         = self.photoInfo[@"title"];
    
    self.title = title;
    
    [[FlickrService sharedInstance] getPhotoInformations:photoID secret:photoSecret complitionBlock:^(NSError *error, NSDictionary *response, BOOL isSucces)
     {
         
         NSDictionary *photo = response[@"photo"];
         NSString *name = photo[@"owner"][@"realname"];
         NSString *descrip = photo[@"description"][@"_content"];
//         NSNumber *dateuploaded = photo[@"dateuploaded"];
         
         
         
         self.nameLabel.text = [NSString stringWithFormat:@"Location: %@",descrip];
         self.placeLabel.text = [NSString stringWithFormat:@"Owner: %@",name];

     }];
    
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
