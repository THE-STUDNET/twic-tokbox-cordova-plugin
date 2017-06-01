//
//  FirebaseClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import "TWICFirebaseClient.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseCore/FirebaseCore.h>
#import "TWICSettingsManager.h"
#import "TWICHangoutManager.h"
#import "TWICUserManager.h"

@interface TWICFirebaseClient()

//the database
@property (strong, nonatomic) FIRDatabaseReference *databaseReference;
@property (strong, nonatomic) FIRDatabaseReference *connectedUserReference;

@end

@implementation TWICFirebaseClient

static NSString *_GoogleAppID = @"1:1027767631440:ios:442ff72b0311e807";
static NSString *_GCMSenderID = @"1027767631440";
static NSString *_APIKey = @"AIzaSyBiIbGIY5W6eyB8mXNfrZ8ZvVY1vuVRPnQ";
static NSString *_ClientID = @"1027767631440-vdq1lfsj0kop3lp7fr1stc53ubof7tma.apps.googleusercontent.com";

+ (TWICFirebaseClient *)sharedInstance
{
    static TWICFirebaseClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICFirebaseClient alloc] init];
    });
    return _sharedClient;
}


-(void)configure
{
    NSDictionary *firebaseSettings = [[TWICSettingsManager sharedInstance]settingsForKey:SettingsFirebaseKey];
    [self configureWithGoogleAppID:_GoogleAppID
                          bundleID:[[NSBundle mainBundle] bundleIdentifier]
                       GCMSenderID:_GCMSenderID
                            APIKey:_APIKey
                          clientID:_ClientID
                        trackingID:nil
                   androidClientID:nil
                       databaseURL:firebaseSettings[SettingsUrlKey]
                     storageBucket:nil
                 deepLinkURLScheme:nil];
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
//    [[FIRAuth auth] signInWithCustomToken:customToken
//                               completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
//                                   // ...
//                               }];

    //retrieve the database
    self.databaseReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"hangouts/%@/connecteds",[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]]];//get hangout id
}

-(void)registerConnectedUser
{
    self.connectedUserReference = [self.databaseReference childByAutoId];
    //store the reference
    [self.connectedUserReference setValue:[TWICUserManager sharedInstance].currentUser[UserIdKey]];
    //add guard in case of crash or other things
    [self.connectedUserReference onDisconnectRemoveValue];
}
-(void)unregisterConnectedUser
{
    //remove the value
    [self.connectedUserReference removeValue];
    //cancel guard
    [self.connectedUserReference cancelDisconnectOperations];
    self.connectedUserReference = nil;
}
@end
