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
                              SettingsFirebaseDatabaseUrlKey:@"https://version2-bd6b5.firebaseio.com",
                              SettingsFirebaseTokenKey:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay1jZjY0ekB2ZXJzaW9uMi1iZDZiNS5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsInN1YiI6ImZpcmViYXNlLWFkbWluc2RrLWNmNjR6QHZlcnNpb24yLWJkNmI1LmlhbS5nc2VydmljZWFjY291bnQuY29tIiwiYXVkIjoiaHR0cHM6XC9cL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbVwvZ29vZ2xlLmlkZW50aXR5LmlkZW50aXR5dG9vbGtpdC52MS5JZGVudGl0eVRvb2xraXQiLCJpYXQiOjE1MDgzMjcxODksImV4cCI6MTUwODMzMDc4OSwidWlkIjo2fQ.Cvp4atdwyt4wkkwU8djgo70A7N_l9pB45yI9nAf7Uoq1TOf78_O9gEDjvpKf_V4Kx1HdTBDW2pngYHg0A4pe-SPcStBRKNWJ2ry3Kyc2bQSkfeEvh23-d9F4zkmwJSNrhNJe3bo3gt0aqfxOewC6dN1yBX_2AqOECPDYCnr4XKjaaF3HYB8pwppsnuvopsKXmygjVRUF0vCjFBeBcmW-TsVxzj5XTswL1u7hsiaoYgnBKGU6pxHFX0In-qvJ20pN6vtoAnxiom-y16hsBwXPpglDeQShtvckrsshBWeagFQftdt2YQTDaaeFdpMUMoW0-iysL9up3_uDfbn8ZVNPfQ",
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
