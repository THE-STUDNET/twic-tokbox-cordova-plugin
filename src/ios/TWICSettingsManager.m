//
//  TWICSettingsManager.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 18/04/2017.
//
//

#import "TWICSettingsManager.h"
@interface TWICSettingsManager()

@property (nonatomic, strong) NSDictionary *settings;

@end

@implementation TWICSettingsManager

+ (TWICSettingsManager *)sharedInstance
{
    static TWICSettingsManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICSettingsManager alloc] init];
        [_sharedClient configureWithDefaultSettings];
    });
    return _sharedClient;
}


-(void)configureWithSettings:(NSDictionary*)settings
{
    self.settings = settings;    
}

-(void)configureWithDefaultSettings{
    self.settings = @{SettingsApiKey:@{
                              SettingsDomainKey:@"api-new.thestudnet.com",
                              SettingsAuthTokenKey:@"6bba0cbefecadc382612fad814b8c802e",
                              SettingsAuthorizationHeaderKey:@"x-auth-token",
                              SettingsProtocolKey:@"https",
                              SettingsPathsKey:@{@"jsonrpc":@"api.json-rpc"}
                              },
                      SettingsDmsKey:@{
                              SettingsDomainKey:@"static-new.thestudnet.com",
                              SettingsProtocolKey:@"https",
                              SettingsPathsKey:@{@"datas":@"data",
                                                 @"upload":@"save",
                                                 @"download":@"download"}
                              },
                      SettingsFirebaseKey:@{
                              SettingsFirebaseGoogleAppIdKey:@"1:676747833735:ios:91cf23adbd90d67c",
                              SettingsFirebaseGCMSenderIdKey:@"676747833735",
                              SettingsFirebaseGoogleAppIdKey:@"AIzaSyAI49slJORKGIsfToSN-Q1eB7S079a9ATc",
                              SettingsFirebaseClientIDKey:@"676747833735-f05geh1chf15r7v4v7bp78n6bsfi0rjl.apps.googleusercontent.com",
                              SettingsFirebaseDatabaseUrlKey:@"https://version2-bd6b5.firebaseio.com"
                              },
                      SettingsWSKey:@{
                              SettingsAuthTokenKey:@"8475756d6741e60a5c04cbcb34ec79a66f1aa38e",
                              SettingsDomainKey:@"ws-new.thestudnet.com",
                              SettingsPortKey:@"443",
                              SettingsSecureKey:@(YES)
                              },
                      SettingsTokboxApiKey:@"45720402",
                      SettingsUserIdKey:@(6),
                      SettingsHangoutIdKey:@(13)};
}

-(id)settingsForKey:(NSString *)key{
    return [self.settings objectForKey:key];
}

@end
