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
    if([user[UserConnectionStateKey]intValue] == UserConnectionStateConnected)
    {
        [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Send a direct message to %@",user[UserFirstnameKey]],UserActionImageKey:@"chat",UserActionTypeKey:@(UserActionTypeSendDirectMessage)}];//chat is available for everybody
        if([[TWICHangoutManager sharedInstance]canUser:self.currentUser doAction:HangoutActionAskDevice])
        {
            if([self isUserSharingCamera:user] == NO)
            {
                if([user[UserAskCamera]boolValue])
                {
                    [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Allow %@ to share his camera",user[UserFirstnameKey]],UserActionImageKey:@"camera",UserActionTypeKey:@(UserActionTypeAllowShareCamera)}];
                }
                else
                {
                    [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Ask %@ to share his camera",user[UserFirstnameKey]],UserActionImageKey:@"camera",UserActionTypeKey:@(UserActionTypeAskShareCamera)}];
                }
            }
            if([self isUserSharingAudio:user] == NO)
            {
                if([user[UserAskMicrophone]boolValue])
                {
                    [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Allow %@ to share his microphone",user[UserFirstnameKey]],UserActionImageKey:@"microphone-white",UserActionTypeKey:@(UserActionTypeAllowShareMicrophone)}];
                }
                else
                {
                    [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Ask %@ to share his micropone",user[UserFirstnameKey]],UserActionImageKey:@"microphone-white",UserActionTypeKey:@(UserActionTypeAskShareMicrophone)}];
                }
            }
            if([self isUserSharingScreen:user]==NO){
                if([user[UserAskScreen]boolValue])
                {
                    [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Allow %@ to share his screen",user[UserFirstnameKey]],UserActionImageKey:@"screen-white",UserActionTypeKey:@(UserActionTypeAllowShareScreen)}];
                }
                else
                {
                    //not possible to share screen on mobile
                }
            }
        }
        //allow to kick
        if([[TWICHangoutManager sharedInstance]canUser:self.currentUser doAction:HangoutActionKick])
        {
            [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Kick %@ from the live",user[UserFirstnameKey]],UserActionIsRedKey:@(1),UserActionTypeKey:@(UserActionTypeKick)}];
        }
        //allow to force unpublish
        if([[TWICHangoutManager sharedInstance]canUser:self.currentUser doAction:HangoutActionForceUnpusblish])
        {
            if([self isUserSharingCamera:user] || [self isUserSharingAudio:user])
            {
                [actions addObject:@{UserActionTitleKey:[NSString stringWithFormat:@"Force %@ to unpublish camera/microphone",user[UserFirstnameKey]],UserActionIsRedKey:@(1),UserActionTypeKey:@(UserActionTypeForceUnpublishStream)}];
            }
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
    if(userID){
        for(NSDictionary *user in self.users){
            if([user[UserIdKey] isEqualToNumber:userID]){
                return user;
            }
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

-(NSArray *)allUsers{
    return self.users;
}

-(BOOL)isUserAskingMicrophonePermission:(NSDictionary*)user
{
    return [user[UserAskMicrophone]boolValue];
}
-(BOOL)isUserAskingCameraPermission:(NSDictionary*)user
{
    return [user[UserAskCamera]boolValue];
}
-(BOOL)isUserAskingScreenPermission:(NSDictionary*)user
{
    return [user[UserAskScreen]boolValue];
}
-(BOOL)isUserAskingPermission:(NSDictionary*)user
{
    return [self isUserAskingMicrophonePermission:user] || [self isUserAskingCameraPermission:user] || [self isUserAskingScreenPermission:user];
}

-(NSArray *)waitingAuthorizationsUsers
{
    NSMutableArray *users = [NSMutableArray array];
    for(NSDictionary *user in self.users){
        if([self isUserAskingPermission:user]){
            [users addObject:user];
        }
    }
    return users;
}
-(int)numberOfWaitingAuthorizations
{
    int number = 0;
    for(NSDictionary *user in [self waitingAuthorizationsUsers]){
        if([self isUserAskingScreenPermission:user]){
            number++;
        }
        if([self isUserAskingMicrophonePermission:user]){
            number++;
        }
        if([self isUserAskingCameraPermission:user]){
            number++;
        }
    }
    return number;
}

-(NSString *)displayNameForUser:(NSDictionary *)user
{
    return [NSString stringWithFormat:@"%@ %@",user[UserFirstnameKey],user[UserLastnameKey]];
}
@end
