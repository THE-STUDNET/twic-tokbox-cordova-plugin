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
                              SettingsUrlKey:@"https://new2017-263e1.firebaseio.com",
                              SettingsAuthTokenKey:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsImRlYnVnIjpmYWxzZSwiZXhwIjoxNTA2MDk2Njg3LCJkIjp7InVpZCI6IjEifSwidiI6MCwiaWF0IjoxNDg4MjczNDg1fQ.QbOwg_gMTodjO8TRRVdll4bVewwuVFl_GLzyOTWEkZE"
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
