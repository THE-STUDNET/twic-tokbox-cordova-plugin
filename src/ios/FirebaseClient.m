//
//  FirebaseClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import "FirebaseClient.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseCore/FirebaseCore.h>

@interface FirebaseClient()

//the database
@property (strong, nonatomic) FIRDatabaseReference *databaseReference;

@end

@implementation FirebaseClient

static NSString *_GoogleAppID = @"1:1027767631440:ios:442ff72b0311e807";
static NSString *_GCMSenderID = @"1027767631440";
static NSString *_APIKey = @"AIzaSyBiIbGIY5W6eyB8mXNfrZ8ZvVY1vuVRPnQ";
static NSString *_ClientID = @"1027767631440-vdq1lfsj0kop3lp7fr1stc53ubof7tma.apps.googleusercontent.com";
static NSString *_DatabaseURL = @"https://twicapp-c6710.firebaseio.com";

+ (FirebaseClient *)sharedInstance
{
    static FirebaseClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[FirebaseClient alloc] init];
    });
    return _sharedClient;
}


-(void)configure
{
    [self configureWithGoogleAppID:_GoogleAppID
                          bundleID:[[NSBundle mainBundle] bundleIdentifier]
                       GCMSenderID:_GCMSenderID
                            APIKey:_APIKey
                          clientID:_ClientID
                        trackingID:nil
                   androidClientID:nil
                       databaseURL:_DatabaseURL
                     storageBucket:nil deepLinkURLScheme:nil];
}

- (void)configureWithGoogleAppID:(NSString *)googleAppID
                        bundleID:(NSString *)bundleID
                     GCMSenderID:(NSString *)GCMSenderID
                          APIKey:(NSString *)APIKey
                        clientID:(NSString *)clientID
                      trackingID:(NSString *)trackingID
                 androidClientID:(NSString *)androidClientID
                     databaseURL:(NSString *)databaseURL
                   storageBucket:(NSString *)storageBucket
               deepLinkURLScheme:(NSString *)deepLinkURLScheme
{
    FIROptions *options = [[FIROptions alloc]initWithGoogleAppID:googleAppID
                                                        bundleID:bundleID
                                                     GCMSenderID:GCMSenderID
                                                          APIKey:APIKey
                                                        clientID:clientID
                                                      trackingID:trackingID
                                                 androidClientID:androidClientID
                                                     databaseURL:databaseURL
                                                   storageBucket:storageBucket
                                               deepLinkURLScheme:deepLinkURLScheme];
    //configure the app
    [FIRApp configureWithOptions:options];

    //retrieve the database
    self.databaseReference = [[FIRDatabase database]referenceWithPath:@"messageiOS"];
}

-(void)writeStringValue:(NSString *)stringValue
{

    [self.databaseReference setValue:stringValue];
}

@end
