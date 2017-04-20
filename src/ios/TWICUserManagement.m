//
//  TWICUserManagement.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 20/04/2017.
//
//

#import "TWICUserManagement.h"
#import "TWICPlatformClient.h"
#import "TWICSettingsManager.h"

@interface TWICUserManagement()

@property (nonatomic, strong) NSArray *users;

@end

@implementation TWICUserManagement

+ (TWICUserManagement *)sharedInstance
{
    static TWICUserManagement *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICUserManagement alloc] init];
        _sharedClient.users = [NSMutableArray array];
    });
    return _sharedClient;
}

-(void)configureWithUserIds:(NSArray*)userIds
            completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *))failureBlock
{
    [[TWICPlatformClient sharedInstance] detailForUsers:userIds
                                        completionBlock:^(NSArray *data)
    {
        self.users = data;
        completionBlock();
    }
                                           failureBlock:^(NSError *error)
    {
        failureBlock(error);
    }];
}

-(NSArray *)allUsers
{
    return self.users;
}

-(NSString *)avatarURLStringForUser:(NSDictionary *)user
{
    NSDictionary *dmsSettings = [[TWICSettingsManager sharedInstance] settingsForKey:SettingsDmsKey];
    NSString *urlString=[NSString stringWithFormat:@"%@://%@/%@/%@",dmsSettings[SettingsProtocolKey],dmsSettings[SettingsDomainKey],dmsSettings[SettingsPathsKey][@"datas"],user[UserAvatarKey]];
    return urlString;
}
@end
