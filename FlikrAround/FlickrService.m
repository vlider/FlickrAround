//
//  FlickrService.m
//  FlikrAround
//
//  Created by Valerii Lider on 9/23/14.
//  Copyright (c) 2014 Spire LLC. All rights reserved.
//

#import "FlickrService.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import <AFOAuth1Client/AFOAuth1Client.h>

#define kFlickrConsumerKey      @"f3dd084d814ebd7851fde1ecbd6d70ca"
#define kFlickrConsumerSecret   @"d4138d07aafcef93"
#define kFlickrBaseURLString    @"https://api.flickr.com"
#define kFlickrReqTokenPath     @"/services/oauth/request_token"
#define kFlickrAuthorizePath    @"/services/oauth/authorize"
#define kFlickrAccesstockenPath @"/services/oauth/access_token"
#define kFlickrCallbackUrl      [NSURL URLWithString:@"flkrrnd://oauth"]

#define kHTTPPost               @"POST"
#define kFlickrCredentialsId    @"FlikrCredentialsIdentifier"
#define kFlickrAroundURLScheme  @"flkrrnd"

#define kRestMethodsPath            @"/services/rest"
#define kMethodKey                  @"method"
#define kFlickrProhosSearchMethod   @"flickr.photos.search"
#define kFlickrProhoInfoMethod      @"flickr.photos.getInfo"
#define kFormatKey                  @"format"
#define kJSON                       @"json"
#define kLatitudeKey                @"lat"
#define kLongitudeKey               @"lon"
#define kPhotoID                    @"photo_id"
#define kPhotoSecret                @"secret"



@interface FlickrService ()
@property (nonatomic, strong) AFOAuth1Client *client;
@end

@implementation FlickrService

+ (instancetype)sharedInstance {
    
    static FlickrService *_gSharedFlickrServiceInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gSharedFlickrServiceInstance = [[FlickrService alloc] init];
    });
    
    return _gSharedFlickrServiceInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL *baseURL = [NSURL URLWithString:kFlickrBaseURLString];
        self.client = [[AFOAuth1Client alloc] initWithBaseURL:baseURL
                                                          key:kFlickrConsumerKey
                                                       secret:kFlickrConsumerSecret];
        [self.client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;
}

- (void)loginWithComplitionBlock:(void (^)(NSError *, BOOL))complitionBlock
{
 
    AFOAuth1Token *token = [AFOAuth1Token retrieveCredentialWithIdentifier:kFlickrCredentialsId];
    if (token && ![token isExpired]) {
        
        [self.client setAccessToken:token];
        dispatch_async(dispatch_get_main_queue(), ^{
            complitionBlock(nil,YES);
        });

    } else {
        
        [self.client authorizeUsingOAuthWithRequestTokenPath:kFlickrReqTokenPath userAuthorizationPath:kFlickrAuthorizePath callbackURL:kFlickrCallbackUrl accessTokenPath:kFlickrAccesstockenPath accessMethod:kHTTPPost scope:nil success:^(AFOAuth1Token *accessToken, id responseObject) {
            
//            NSString *responseString = nil;
//            if ([responseObject isKindOfClass:[NSData class]])
//                responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if (accessToken) {
                
                [AFOAuth1Token storeCredential:accessToken withIdentifier:kFlickrCredentialsId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    complitionBlock(nil,YES);
                });

                //Notify abour successs
            } else {
                //Notify about failure
                dispatch_async(dispatch_get_main_queue(), ^{
                    complitionBlock(nil,NO);
                });
            }
        } failure:^(NSError *error) {
            
            //Notify about failure
            dispatch_async(dispatch_get_main_queue(), ^{
             complitionBlock(error,YES);
            });
        }];
    }
}

- (void)logoutComplitionBlock:(void (^)(NSError *, BOOL))complitionBlock {
    
    [AFOAuth1Token deleteCredentialWithIdentifier:kFlickrCredentialsId];
    dispatch_async(dispatch_get_main_queue(), ^{
        complitionBlock(nil,YES);
    });
}

- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
    
    if (NSOrderedSame == [[url scheme] compare:kFlickrAroundURLScheme options:NSCaseInsensitiveSearch]) {
        
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:@{kAFApplicationLaunchOptionsURLKey:url}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        return YES;
    }
    
    return NO;
}
- (void)getPhotoInformations:(NSString *)photoID secret:(NSString *)photoSecret complitionBlock:(void (^)(NSError * ,id response, BOOL))complitionBlock
{
    
    //3887 _ 14904639627_288768fcf6
    
    photoID = @"14904639627";
    photoSecret = @"288768fcf6";
    
    NSDictionary *parameters = @{kMethodKey:kFlickrProhoInfoMethod,
                                 kPhotoID:photoID,
                                 kPhotoSecret:photoSecret,
                                 kFormatKey:kJSON};
    
    [self.client getPath:kRestMethodsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *object = nil;
        NSError *error = [self deserializeResponse:operation.responseString intoObject:&object];
        
        if(error)
        {
            complitionBlock(error,nil,NO);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                complitionBlock(nil,object,NO);
            });
            
            NSLog(@"%@", operation.responseString);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complitionBlock(error,nil,NO);
        });
        NSLog(@"%@", operation.responseString);
    }];
    
}

- (void)searchPhotosForLocation:(CLLocationCoordinate2D)coordinate complitionBlock:(void (^)(NSError *,id response, BOOL))complitionBlock{
    
    NSDictionary *parameters = @{kMethodKey:kFlickrProhosSearchMethod,
                                 kLatitudeKey:@(coordinate.latitude),
                                 kLongitudeKey:@(coordinate.longitude),
                                 kFormatKey:kJSON};
    [self.client getPath:kRestMethodsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *object = nil;
        NSError *error = [self deserializeResponse:operation.responseString intoObject:&object];
        
        if(error)
        {
            complitionBlock(error,nil,NO);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                complitionBlock(nil,object,NO);
            });
            
            NSLog(@"%@", operation.responseString);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complitionBlock(error,nil,NO);
        });
        NSLog(@"%@", operation.responseString);
    }];
}

#pragma mark -
#pragma mark Deserialize methods
#pragma mark -

- (NSError *)deserializeResponse:(NSString *)str intoObject:(NSDictionary **)object
{
    NSError *error = nil;
    
    str = [str stringByReplacingOccurrencesOfString:@"jsonFlickrApi(" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@")" withString:@""];

    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:0 error:&error];
//    *object = [ NSJSONSerialization JSONObjectWithData: options:NSJSONReadingMutableLeaves error:&error ];
    
//    if( error )
//    {
//        NSString *s = [ [ NSString alloc ]initWithData:blob encoding:NSUTF8StringEncoding ];
//        NSLog(@"%@", s);
//    }
    
    *object = jsonObject;
    
//    NSNumber *code = obj[ @"error" ];
//    if( code )
//    {
//        error = [ NSError errorWithDomain:@"FSCore" code:code.intValue userInfo:nil ];
//    }
    
    return error;
}

@end
