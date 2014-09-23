//
//  ViewController.m
//  FlikrAround
//
//  Created by Valerii Lider on 9/23/14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import "ViewController.h"
#import "FlickrService.h"
#import "BasicCollectionViewCell.h"
#import "PhotoInfoViewController.h"

CG_INLINE BOOL is_ios_8()
{
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion > 7.99)
        return YES;
    else
        return NO;
}


@interface ViewController()<CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.location = kCLLocationCoordinate2DInvalid;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [[FlickrService sharedInstance] loginWithCompletionBlock:^(NSError *error, BOOL isSucces) {
        
        if (!error && isSucces) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Logged In!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [self startSearchPhotosOfCurrentLocation];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Failed to login" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            NSLog(@"Login Error:%@",error);
        }
    }];
}


- (void)startSearchPhotosOfCurrentLocation {
    
    if(is_ios_8()) {
        
        CLAuthorizationStatus status =  [CLLocationManager authorizationStatus];
        if(status != kCLAuthorizationStatusAuthorized || status != kCLAuthorizationStatusAuthorizedWhenInUse)
            [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return  self.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cellID";
    
    BasicCollectionViewCell *cell = (BasicCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSAssert(nil != cell, @"BasicCollectionViewCell class is not registered");
    
    NSDictionary *photo = self.photos[indexPath.row];
    
    cell.backgroundColor = [UIColor whiteColor];

    NSString *farm          = photo[@"farm"];
    NSString *server        = photo[@"server"];
    NSString *photoID       = photo[@"id"];
    NSString *photoSecret   = photo[@"secret"];
    __block NSString *title = photo[@"title"];
    
    //building photo url
    NSString *basePhotoURL =  [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@.jpg", farm, server, photoID, photoSecret];
    
    cell.imageView.image = nil;
    cell.titleLabel.textColor = [UIColor blackColor];
    
    [self downloadImageWithURL:[NSURL URLWithString:basePhotoURL] completionBlock:^(BOOL succeeded, UIImage *image) {
        
        cell.imageView.image = image;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.titleLabel.text = title;
        cell.titleLabel.textColor = [UIColor whiteColor];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCollectionViewCell *cell = (BasicCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    UIImage *image = cell.imageView.image;
    
    PhotoInfoViewController *phVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PhotoInfoViewController class])];
    phVC.image = image;
    
    NSDictionary *photo = self.photos[indexPath.row];
    
    NSString *photoID       = photo[@"id"];
    NSString *photoSecret   = photo[@"secret"];
    NSString *title         = photo[@"title"];
    
    NSDictionary *photoInfo = @{@"id":photoID,@"secret":photoSecret,@"title":title};
    
    phVC.photoInfo = photoInfo;
    [self.navigationController pushViewController:phVC animated:YES];
                                     
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(!CLLocationCoordinate2DIsValid(self.location)) {
        
        CLLocation *location = [locations lastObject];
        self.location = location.coordinate;
        
        [self.locationManager stopUpdatingLocation];
        
        __weak ViewController *weakSelf = self;
        [[FlickrService sharedInstance] searchPhotosForLocation:self.location complitionBlock:^(NSError *error, NSDictionary *response, BOOL isSucces) {
            
            if (isSucces) {
                
                NSArray *photos = response[@"photos"][@"photo"];
                if ([photos isKindOfClass:[NSArray class]]) {
                    
                    __strong ViewController *strongSelf = weakSelf;
                    @synchronized(strongSelf) {
                        
                        self.photos = photos;
                    }
                    
                    [self.collectionView reloadData];
                }
            }
        }];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (completionBlock)
                completionBlock(YES, image);
            
        } else if (completionBlock)
            completionBlock(NO, nil);
    }];
}

@end
