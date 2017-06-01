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
    [self configureWithDatabaseURL:firebaseSettings[SettingsUrlKey]
               authenticationToken:firebaseSettings[SettingsAuthTokenKey]];
}

-(void)configureWithDatabaseURL:(NSString *)url
            authenticationToken:(NSString *)token
{
    //configure the app
    [FIRApp configure];
    
    [[FIRAuth auth] signInWithCustomToken:token
                               completion:^(FIRUser *_Nullable user, NSError *_Nullable error)
    {
        //retrieve the database
        self.databaseReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"hangouts/%@/connecteds",[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]]];//get hangout id
    }];
    
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
