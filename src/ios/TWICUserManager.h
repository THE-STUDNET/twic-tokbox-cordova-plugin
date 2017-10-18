//
//  TWICUserManager.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 20/04/2017.
//
//

#import <Foundation/Foundation.h>

//API Attributes
static NSString *UserAmbassadorKey       = @"ambassador";
static NSString *UserAvatarKey           = @"avatar";
static NSString *UserBackgroundKey       = @"background";
static NSString *UserBirthDateKey        = @"birth_date";
static NSString *UserContactStateKey     = @"contact_state";
static NSString *UserContactsKey         = @"contacts_count";
static NSString *UserEmailKey            = @"email";
static NSString *UserFirstnameKey        = @"firstname";
static NSString *UserGenderKey           = @"gender";
static NSString *UserHasEmailNotifierKey = @"has_email_notifier";
static NSString *UserIdKey               = @"id";
static NSString *UserInterestKey         = @"interest";
static NSString *UserLastnameKey         = @"lastname";
static NSString *UserNationalityKey      = @"nationality";
static NSString *UserShortNameKey        = @"short_name";
static NSString *UserNicknameKey         = @"nickname";
static NSString *UserOrganizationIdKey   = @"organization_id";
static NSString *UserOriginKey           = @"origin";
static NSString *UserPositionKey         = @"position";
static NSString *UserRoleKey             = @"role";

//LOCAL Attributes
static NSString *UserConnectionStateKey  = @"connection_state";
static NSString *UserAskCamera           = @"ask_camera";
static NSString *UserAskMicrophone       = @"ask_microphone";
static NSString *UserAskScreen           = @"ask_screen";

static NSString *UserActionTitleKey      = @"action_title";
static NSString *UserActionImageKey      = @"action_image";
static NSString *UserActionIsRedKey      = @"action_is_red";
static NSString *UserActionTypeKey       = @"action_type";

typedef enum : NSUInteger {
    UserConnectionStateUknown,
    UserConnectionStateConnected,
    UserConnectionStateDisconnected,
} UserConnectionState;

typedef enum : NSUInteger {
    UserActionTypeSendDirectMessage,
    UserActionTypeAskShareCamera,
    UserActionTypeAllowShareCamera,
    UserActionTypeAskShareMicrophone,
    UserActionTypeAllowShareMicrophone,
    UserActionTypeAllowShareScreen,
    UserActionTypeKick,
    UserActionTypeForceUnpublishStream,
    UserActionTypeForceUnpublishScreen,
} UserActionType;

@interface TWICUserManager : NSObject
+ (TWICUserManager *)sharedInstance;

-(void)configureWithUserIds:(NSArray*)userIds
            completionBlock:(void(^)())completionBlock
               failureBlock:(void (^)(NSError *error))failureBlock;

//many user management
-(NSInteger)connectedUsersCount;
-(NSInteger)usersCount;
-(NSArray *)allUsers;
-(NSArray *)waitingAuthorizationsUsers;
-(int)numberOfWaitingAuthorizations;

//single user management
-(void)loadDetailsForUserID:(NSNumber*)userID
            completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *))failureBlock;
-(NSArray *)actionsForUser:(NSDictionary *)user;
-(NSString *)avatarURLStringForUser:(NSDictionary *)user;
-(NSDictionary *)currentUser;
-(NSDictionary *)userWithUserID:(NSNumber *)userID;
-(BOOL)isCurrentUser:(NSDictionary *)user;
-(void)setConnectedUserStateForUserID:(NSNumber *)userID;
-(void)setDisconnectedUserStateForUserID:(NSNumber *)userID;
-(void)setAskPermission:(NSString *)askPermission forUserID:(NSNumber *)userID toValue:(BOOL)value;
-(void)setRoleToCurrentUser:(NSString *)role;
-(BOOL)isUserSharingCamera:(NSDictionary*)user;
-(BOOL)isUserSharingScreen:(NSDictionary*)user;
-(BOOL)isUserSharingAudio:(NSDictionary*)user;
-(BOOL)isUserAskingMicrophonePermission:(NSDictionary*)user;
-(BOOL)isUserAskingCameraPermission:(NSDictionary*)user;
-(BOOL)isUserAskingScreenPermission:(NSDictionary*)user;
-(BOOL)isUserAskingPermission:(NSDictionary*)user;
-(NSString *)displayNameForUser:(NSDictionary *)user;
@end
