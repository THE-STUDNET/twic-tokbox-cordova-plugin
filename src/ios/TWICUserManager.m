//
//  TWICUserManager.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 20/04/2017.
//
//

#import "TWICUserManager.h"
#import "TWICAPIClient.h"
#import "TWICSettingsManager.h"
#import "TWICHangoutManager.h"

@interface TWICUserManager()

@end

@implementation TWICUserManager

+ (TWICUserManager *)sharedInstance
{
    static TWICUserManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICUserManager alloc] init];
        _sharedClient.users = [NSMutableArray array];
    });
    return _sharedClient;
}

-(void)configureWithUserIds:(NSArray*)userIds
            completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *))failureBlock
{
    [[TWICAPIClient sharedInstance] detailForUsers:userIds
                                   completionBlock:^(NSArray *data)
    {
        //build user actions
        for(NSDictionary *user in data)
        {
            NSMutableDictionary *tmpUser = [user mutableCopy];
            tmpUser[UserActionsKey] = [self actionsForUser:user];
            [self.users addObject:tmpUser];
        }
        
        completionBlock();
    }
                                           failureBlock:^(NSError *error)
    {
        failureBlock(error);
    }];
}

-(NSString *)avatarURLStringForUser:(NSDictionary *)user
{
    NSDictionary *dmsSettings = [[TWICSettingsManager sharedInstance] settingsForKey:SettingsDmsKey];
    NSString *urlString=[NSString stringWithFormat:@"%@://%@/%@/%@",dmsSettings[SettingsProtocolKey],dmsSettings[SettingsDomainKey],dmsSettings[SettingsPathsKey][@"datas"],user[UserAvatarKey]];
    return urlString;
}

-(NSDictionary *)currentUser
{
    for(NSDictionary *user in self.users){
        if([user[UserIdKey] isEqualToString:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsUserIdKey]]){
            return user;
        }
    }
    return nil;
}

-(NSArray *)actionsForUser:(NSDictionary *)user
{
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:@{UserActionTitleKey:@"Send a direct message to Marc",UserActionImageKey:@"chat"}];//chat is available for everybody
    if([[TWICHangoutManager sharedInstance]canUser:user doAction:HangoutActionAskDevice]){
        [actions addObject:@{UserActionTitleKey:@"Send a request for the camera",UserActionImageKey:@"camera"}];
        [actions addObject:@{UserActionTitleKey:@"Send a request for the microphone",UserActionImageKey:@"microphone-white"}];
    }
    if([[TWICHangoutManager sharedInstance]canUser:user doAction:HangoutActionKick]){
        [actions addObject:@{UserActionTitleKey:@"Kick Marc from the live",UserActionIsAdminKey:@(1)}];
    }
    return actions;
}
@end
