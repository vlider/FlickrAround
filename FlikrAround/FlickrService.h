//
//  FlickrService.h
//  FlikrAround
//
//  Created by Valerii Lider on 9/23/14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FlickrService : NSObject

+ (instancetype)sharedInstance;

- (void)loginWithComplitionBlock:(void (^)(NSError*,BOOL isSucces))complitionBlock;
- (void)logoutComplitionBlock:(void (^)(NSError*,BOOL isSucces))complitionBlock;;

- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;

- (void)getPhotoInformations:(NSString *)photoID secret:(NSString *)photoSecret complitionBlock:(void (^)(NSError * ,id response, BOOL))complitionBlock;
- (void)searchPhotosForLocation:(CLLocationCoordinate2D)coordinate complitionBlock:(void (^)(NSError * ,id response, BOOL))complitionBlock;

/** TASK
 
 Create simple universal iOS application that consumes Flickr api and returns 50 images taken near users current location. Application needs to load results from Flickr api and present them in a grid with thumbnails and image names. Thumbnails should be evenly spaced with 4 thumbnails in each row on regular width screen and 3 thumbnails on compact width screen.
 After selecting each thumbnail image details should be shown modally containing full size image and ability to see image metadata.
 You should avoid using any kind of Flickr iOS SDK. All other third party code is allowed.
 
 Documentation for needed API calls can be found at:
 https://www.flickr.com/services/api/flickr.places.find.html 
 https://www.flickr.com/services/api/flickr.photos.search.html
 https://www.flickr.com/services/api/flickr.photos.getInfo.html
 https://www.flickr.com/services/api/flickr.photos.getSizes.html
 
 You will need to create Flickr API key.
 Code should be hosted on Github and after 24 hours app should be buildable and ready for review.
 Application needs to be:
 • Fast
 • Non blocking
 • Responsive
 • Working on both platforms iPad and iPhone
 
 Any of the following will be treated as bonus achievements:
 • API code is separated into framework and easily re-usable
 • Unit tests are implemented and passing
 • Data caching is implemented
 • List view has paging implemented
 • Image details are zoomable
 • It is possible to browse images from image detail screen
 • Image details show more image information available from getInfo api method
 */

@end
