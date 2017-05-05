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
#import "TWICConstants.h"
#import "TWICTokClient.h"

@interface TWICUserManager()

@property (nonatomic, strong) NSMutableArray *users;

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
        for(NSDictionary *userData in data)
        {
            [self.users addObject:[self createUserWithData:userData]];
        }
        
        completionBlock();
    }
                                           failureBlock:^(NSError *error)
    {
        failureBlock(error);
    }];
}

-(NSMutableDictionary*)createUserWithData:(NSDictionary *)data{
    NSMutableDictionary *user = [data mutableCopy];
    if([self isCurrentUser:user]){
        user[UserConnectionStateKey] = @(UserConnectionStateConnected);
    }else{
        user[UserConnectionStateKey] = @(UserConnectionStateUknown);
    }
    //all permissions to no
    user[UserAskCamera] = @(NO);
    user[UserAskMicrophone] = @(NO);
    user[UserAskScreen] = @(NO);
    return user;
}

-(NSArray *)actionsForUser:(NSDictionary *)user
{
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Send a direct message to %@",user[UserFirstnameKey]],UserActionImageKey:@"chat"}];//chat is available for everybody
    if([[TWICHangoutManager sharedInstance]canUser:self.currentUser doAction:HangoutActionAskDevice]){
        [actions addObject:@{UserActionTitleKey:@"Send a request for the camera",UserActionImageKey:@"camera"}];
        [actions addObject:@{UserActionTitleKey:@"Send a request for the microphone",UserActionImageKey:@"microphone-white"}];
    }
    if([[TWICHangoutManager sharedInstance]canUser:self.currentUser doAction:HangoutActionKick])
    {
        if([user[UserConnectionStateKey]boolValue])
        {
            [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Kick %@ from the live",user[UserFirstnameKey]],UserActionIsAdminKey:@(1)}];
        }
    }
    return actions;
}

-(BOOL)isUserSharingAudio:(NSDictionary*)user{
    OTStream *userStream = [[TWICTokClient sharedInstance]streamForUser:user];
    return userStream.hasAudio;
}
-(BOOL)isUserSharingScreen:(NSDictionary*)user{
    OTStream *userStream = [[TWICTokClient sharedInstance]streamForUser:user];
    return userStream.videoType == OTStreamVideoTypeScreen && userStream.hasVideo;
}
-(BOOL)isUserSharingCamera:(NSDictionary*)user{
    OTStream *userStream = [[TWICTokClient sharedInstance]streamForUser:user];
    return userStream.videoType == OTStreamVideoTypeCamera && userStream.hasVideo;
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
        if([user[UserIdKey] isEqualToNumber:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsUserIdKey]]){
            return user;
        }
    }
    return nil;
}

-(NSDictionary *)userWithUserID:(NSNumber *)userID
{
    for(NSDictionary *user in self.users){
        if([user[UserIdKey] isEqualToNumber:userID]){
            return user;
        }
    }
    return nil;
}

-(BOOL)isCurrentUser:(NSDictionary *)user
{
    return [[self currentUser][UserIdKey]isEqualToNumber:user[UserIdKey]];
}

-(void)loadDetailsForUserID:(NSNumber*)userID
            completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *))failureBlock
{
    [[TWICAPIClient sharedInstance]detailForUser:userID
                                 completionBlock:^(NSDictionary *userData)
    {
        [self.users addObject:[self createUserWithData:userData]];
        completionBlock();
    }
                                    failureBlock:^(NSError *error)
    {
        failureBlock(error);
    }];
}

-(void)setConnectedUserStateForUserID:(NSNumber *)userID{
    NSMutableDictionary *user = (NSMutableDictionary*)[self userWithUserID:userID];
    user[UserConnectionStateKey] = @(UserConnectionStateConnected);
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_USER_CONNECTED object:user];
}
-(void)setDisconnectedUserStateForUserID:(NSNumber *)userID
{
    NSMutableDictionary *user = (NSMutableDictionary*)[self userWithUserID:userID];
    user[UserConnectionStateKey] = @(UserConnectionStateDisconnected);
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_USER_DISCONNECTED object:user];
}

-(void)setAskPermission:(NSString *)askPermission forUserID:(NSNumber *)userID toValue:(BOOL)value{
    NSMutableDictionary *user = (NSMutableDictionary*)[self userWithUserID:userID];
    user[askPermission] = @(value);
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_USER_ASKPERMISSION_UPDATED object:user];
}

-(NSInteger)connectedUsersCount{
    __block NSInteger number = 0;
    [self.users  enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if([user[UserConnectionStateKey]integerValue] == UserConnectionStateConnected){
            number ++;
        }
    }];
    return number;
}

-(NSInteger)usersCount{
    return self.users.count;
}

-(NSArray *)allUsers
{
    return self.users;
}
@end
