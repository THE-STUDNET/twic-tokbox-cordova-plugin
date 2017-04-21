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
    NSString *userRoleKey = [user[UserRolesKey]firstObject];
    
    //revrieve action
    id option = self.hangoutData[HangoutOptionsKey][actionName];
    if([option isKindOfClass:[NSDictionary class]]){
        return [option containsValueForKey:userRoleKey];
    }
    return [option boolValue];
}


@end
