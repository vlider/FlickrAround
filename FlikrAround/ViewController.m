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
@end

@implementation ViewController
{
    float lat;
    float lon;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    
    [[FlickrService sharedInstance] loginWithComplitionBlock:^(NSError *error, BOOL isSucces) {
        
        if(!error && isSucces)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Login Succes" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [self startSearchPhotosOfCurrentLocation];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Login Failure" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            NSLog(@"Login Error:%@",error);
        }
    }];
}


-(void)startSearchPhotosOfCurrentLocation
{

    if(is_ios_8())
    {
        int ig =  [CLLocationManager authorizationStatus];
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    
    [self.locationManager startUpdatingLocation];
}

-(void)requestStart:(float)latL lat:(float)lonL name:(NSString*)namePlace
{
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  self.photos.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellId = @"cellID";
    
    BasicCollectionViewCell *cell = (BasicCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if([cell isEqual:nil])
    {
        cell = [[BasicCollectionViewCell alloc] init];
    }

    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor whiteColor];

    NSString *farm          = photo[@"farm"];
    NSString *server        = photo[@"server"];
    NSString *photoID       = photo[@"id"];
    NSString *photoSecret   = photo[@"secret"];
    __block NSString *title = photo[@"title"];
    
    NSString *basePhotoURL =  [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@.jpg",farm ,server,photoID,photoSecret];
    
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BasicCollectionViewCell *cell = (BasicCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    UIImage *image = cell.imageView.image;
    
    PhotoInfoViewController *phVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PhotoInfoViewController class])];
    phVC.image = image;
    phVC.photoInfo = nil;
    [self.navigationController pushViewController:phVC animated:YES];
                                     
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(!lat && !lon)
    {
        CLLocation  *location = [locations lastObject];
        lat = location.coordinate.latitude;
        lon = location.coordinate.longitude;
        
        NSLog(@"didUpdateToLocation: %@", location);
        CLLocation *currentLocation = location;
        
        if (currentLocation != nil)
            NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
        
        [self.locationManager stopUpdatingLocation];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        NSLog(@"Resolving the Address");
        __block NSString *strAdd = nil;
        __block float latitude = location.coordinate.latitude;
        __block float longitude = location.coordinate.longitude;
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
             if (error == nil && [placemarks count] > 0)
             {
                 CLPlacemark *placemark = [placemarks lastObject];
                 if ([placemark.locality length] != 0)
                 {
                     if ([strAdd length] != 0)
                         strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
                     else
                         strAdd = placemark.locality;
                 }
                 else
                 {
                     if ([placemark.country length] != 0)
                     {
                         if ([strAdd length] != 0)
                             strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
                         else
                             strAdd = placemark.country;
                     }
                 }
             }
             
             
             [[FlickrService sharedInstance] searchPhotosForLocation:CLLocationCoordinate2DMake(latitude,longitude) complitionBlock:^(NSError *error, NSDictionary* response, BOOL isSucces)
              {
                  NSArray* photos = response[@"photos"][@"photo"];
                  self.photos = photos;
                  [[FlickrService sharedInstance] getPhotoInformations:nil secret:nil complitionBlock:^(NSError *error, id response, BOOL isSucces)
                  {
                     
                  }];
                  [self.collectionView reloadData];
             }];
             
//             [self requestStart:latitude lat:longitude name:strAdd];
             
         }];
        
        
    }
    else
    {
        
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

@end
