//
//  FirebaseClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import <Foundation/Foundation.h>

@interface TWICFirebaseClient : NSObject

+ (TWICFirebaseClient *)sharedInstance;

//init with embedded values
-(void)configure;

//init with custom values
- (void)configureWithGoogleAppID:(NSString *)googleAppID
                        bundleID:(NSString *)bundleID
                     GCMSenderID:(NSString *)GCMSenderID
                          APIKey:(NSString *)APIKey
                        clientID:(NSString *)clientID
                      trackingID:(NSString *)trackingID
                 androidClientID:(NSString *)androidClientID
                     databaseURL:(NSString *)databaseURL
                   storageBucket:(NSString *)storageBucket
               deepLinkURLScheme:(NSString *)deepLinkURLScheme;

-(void)writeStringValue:(NSString *)stringValue;

@end
