//
//  TWICSettingsManager.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 18/04/2017.
//
//

#import <Foundation/Foundation.h>

static NSString *SettingsApiKey                 = @"api";
static NSString *SettingsDmsKey                 = @"dms";
static NSString *SettingsFirebaseKey            = @"firebase";
static NSString *SettingsWSKey                  = @"ws";
static NSString *SettingsTokboxApiKey           = @"tokbox_api_key";
static NSString *SettingsUserIdKey              = @"user_id";
static NSString *SettingsHangoutIdKey           = @"hangout_id";

static NSString *SettingsAuthTokenKey           = @"auth_token";
static NSString *SettingsAuthorizationHeaderKey = @"authorization_header";
static NSString *SettingsProtocolKey            = @"protocol";
static NSString *SettingsPathsKey               = @"paths";
static NSString *SettingsDomainKey              = @"domain";
static NSString *SettingsUrlKey                 = @"url";
static NSString *SettingsPortKey                = @"port";
static NSString *SettingsSecureKey              = @"secure";

static NSString *SettingsFirebaseDatabaseUrlKey = @"database_url";
static NSString *SettingsFirebaseGoogleAppIdKey = @"google_app_id";
static NSString *SettingsFirebaseGCMSenderIdKey = @"gcm_sender_id";
static NSString *SettingsFirebaseAPIKey         = @"api_key";
static NSString *SettingsFirebaseClientIDKey    = @"client_id";
static NSString *SettingsFirebaseTokenKey       = @"token";

@interface TWICSettingsManager : NSObject

+ (TWICSettingsManager *)sharedInstance;

-(void)configureWithSettings:(NSDictionary*)settings;

-(void)configureWithDefaultSettings;

-(id)settingsForKey:(NSString *)key;
@end
