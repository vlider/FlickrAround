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

- (void)login {
 
    AFOAuth1Token *token = [AFOAuth1Token retrieveCredentialWithIdentifier:kFlickrCredentialsId];
    if (token && ![token isExpired]) {
        
        [self.client setAccessToken:token];
    } else {
        
        [self.client authorizeUsingOAuthWithRequestTokenPath:kFlickrReqTokenPath userAuthorizationPath:kFlickrAuthorizePath callbackURL:kFlickrCallbackUrl accessTokenPath:kFlickrAccesstockenPath accessMethod:kHTTPPost scope:nil success:^(AFOAuth1Token *accessToken, id responseObject) {
            
//            NSString *responseString = nil;
//            if ([responseObject isKindOfClass:[NSData class]])
//                responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if (accessToken) {
                
                [AFOAuth1Token storeCredential:accessToken withIdentifier:kFlickrCredentialsId];
                
                //Notify abour successs
            } else {
                //Notify about failure
            }
        } failure:^(NSError *error) {
            
            //Notify about failure
        }];
    }
}

- (void)logout {
    
    [AFOAuth1Token deleteCredentialWithIdentifier:kFlickrCredentialsId];
    
    //Notify about success
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

@end
