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
#import <Firebase/Firebase.h>
#import "TWICSettingsManager.h"
#import "TWICHangoutManager.h"
#import "TWICUserManager.h"
@interface TWICFirebaseClient()

//the database
@property (strong, nonatomic) FIRDatabaseReference *databaseReference;
@property (strong, nonatomic) FIRDatabaseReference *connectedUserReference;

@end

@implementation TWICFirebaseClient

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
    [self configureWithFirebaseSettings:firebaseSettings];
}

-(void)configureWithFirebaseSettings:(NSDictionary *)settings
{
    //authent
    if([settings[SettingsFirebaseTokenKey]length] > 0)
    {
        //create the options
        FIROptions *options = [[FIROptions alloc]initWithGoogleAppID:settings[SettingsFirebaseGoogleAppIdKey]
                                                            bundleID:[[NSBundle mainBundle] bundleIdentifier]
                                                         GCMSenderID:settings[SettingsFirebaseGCMSenderIdKey]
                                                              APIKey:settings[SettingsApiKey]
                                                            clientID:settings[SettingsFirebaseClientIDKey]
                                                          trackingID:nil
                                                     androidClientID:nil
                                                         databaseURL:settings[SettingsFirebaseDatabaseUrlKey]
                                                       storageBucket:nil
                                                   deepLinkURLScheme:nil];
        
        //configure the app /// TODO : see how to create many apps at the same time
        if(FIRApp.defaultApp.options == nil){
            [FIRApp configureWithOptions:options];
        }
        
        //authent
        [[FIRAuth auth] signInWithCustomToken:settings[SettingsFirebaseTokenKey]
                                   completion:^(FIRUser *_Nullable user, NSError *_Nullable error)
         {
             //retrieve the database
             NSString *refPath =[NSString stringWithFormat:@"hangouts/%@/connecteds",[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]];
             self.databaseReference = [[FIRDatabase database] referenceWithPath:refPath];//get hangout id
         }];
    }
}

-(void)registerConnectedUser
{
    self.connectedUserReference = [self.databaseReference childByAutoId];
    //store the reference
    [self.connectedUserReference setValue:[TWICUserManager sharedInstance].currentUser[UserIdKey]
                      withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
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
