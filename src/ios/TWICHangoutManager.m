//
//  TWICHangoutManager.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 20/04/2017.
//
//

#import "TWICHangoutManager.h"
#import "TWICAPIClient.h"
#import "TWICUserManager.h"

@interface TWICHangoutManager()

@end
@implementation TWICHangoutManager

+ (TWICHangoutManager *)sharedInstance
{
    static TWICHangoutManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICHangoutManager alloc] init];
    });
    return _sharedClient;
}

-(void)configureHangoutDataWithCompletionBlock:(void(^)())completionBlock
                                  failureBlock:(void (^)(NSError *error))failureBlock
{
    [[TWICAPIClient sharedInstance]hangoutDataWithCompletionBlock:^(NSDictionary *data)
    {
//#warning - REMOVE THAT ON RELEASE !!!!! => REMOVE AUTO PUBLISH KEY
//        NSMutableDictionary *optionsData = [data[HangoutOptionsKey] mutableCopy];
//        NSMutableDictionary *rulesData = [optionsData[HangoutRulesKey] mutableCopy];
//        rulesData[HangoutActionAutoPublishCamera] = @(YES);
//        rulesData[HangoutActionAutoPublishMicrophone] = @(YES);
//        rulesData[HangoutActionPublish]=@(YES);
//        NSMutableDictionary *debugData = [data mutableCopy];
//        optionsData[HangoutRulesKey] = rulesData;
//        debugData[HangoutOptionsKey] = optionsData;
        self.hangoutData = data;
        completionBlock();
    }
                                                     failureBlock:^(NSError *error)
    {
        failureBlock(error);
    }];
}

-(BOOL)canUser:(NSDictionary *)user doAction:(NSString *)actionName
{
    //retrieve the role of the user
    NSString *userRoleKey = user[UserRoleKey];
    
    //revrieve action
    id option = self.hangoutData[HangoutOptionsKey][HangoutRulesKey][actionName];
    if([option isKindOfClass:[NSArray class]]){
        NSDictionary *rolesData = [option firstObject];
        if([rolesData isKindOfClass:[NSDictionary class]]){
            NSArray *roleValues = rolesData[HangoutRolesKey];
            BOOL allowed = [roleValues containsObject:userRoleKey];
            return allowed;
        }
    }
    return [option boolValue];
}

-(id)optionForKey:(NSString *)optionKey{
    return [self.hangoutData[HangoutOptionsKey] valueForKey:optionKey];
}
@end
