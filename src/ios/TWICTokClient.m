//
//  TWICTokClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 12/04/2017.
//
//

#import "TWICTokClient.h"
#import <OpenTok/OpenTok.h>
#import "TWICSettingsManager.h"
#import "TWICAPIClient.h"
#import "TWICUserManager.h"
#import "TWICHangoutManager.h"
#import "TWICFirebaseClient.h"
#import "TWICMessageManager.h"

@interface TWICTokClient()<OTSessionDelegate,OTPublisherKitDelegate,OTSubscriberKitDelegate>

@property (strong, nonatomic) NSMutableDictionary *allStreams;
@property (strong, nonatomic) NSMutableDictionary *allSubscribers;
@property (strong, nonatomic) NSMutableDictionary *allConnections;
@property (strong, nonatomic) NSMutableArray      *allConnectionsIds;
@property (strong, nonatomic) NSMutableArray      *backgroundConnectedStreams;

@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) NSString *archiveId;
@end

@implementation TWICTokClient

+ (TWICTokClient *)sharedInstance
{
    static TWICTokClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICTokClient alloc] init];
        // initialize constants
        _sharedClient.allStreams = [[NSMutableDictionary alloc] init];
        _sharedClient.allSubscribers = [[NSMutableDictionary alloc] init];
        _sharedClient.allConnections = [[NSMutableDictionary alloc] init];
        _sharedClient.allConnectionsIds = [[NSMutableArray alloc] init];
        _sharedClient.backgroundConnectedStreams = [[NSMutableArray alloc] init];
        // application background/foreground monitoring for publish/subscribe video
        // toggling
        [[NSNotificationCenter defaultCenter] addObserver:_sharedClient
                                                 selector:@selector(enteringBackgroundMode:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:_sharedClient
                                                 selector:@selector(leavingBackgroundMode:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

    });
    return _sharedClient;
}

#pragma mark - Private
- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [NSError errorWithDomain:ERROR_DOMAIN code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}


#pragma mark - Session Management
-(void)connect{
    [[TWICAPIClient sharedInstance]tokboxDataWithCompletionBlock:^(NSDictionary *data)
     {
         //set role to current user
         if(data[@"role"]==nil){
             [[TWICUserManager sharedInstance] setRoleToCurrentUser:@"user"];
         }else{
             [[TWICUserManager sharedInstance] setRoleToCurrentUser:data[@"role"]];
         }
         
         //connect to the session
         [self connectToSession:data[@"session"] withUserToken:data[@"token"]];
     }
                                                    failureBlock:^(NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:error.localizedDescription];
     }];

}

-(void)disconnect{
    [self.session disconnect:nil];
}

-(void)connectToSession:(NSString *)sessionID withUserToken:(NSString *)userToken
{
    self.session = [[OTSession alloc] initWithApiKey:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsTokboxApiKey]
                                       sessionId:sessionID
                                        delegate:self];
    
    [self.session connectWithToken:userToken error:nil];
}

-(void)setupPublisherWithCompletionBlock:(void(^)())completionBlock
                            failureBlock:(void (^)(NSError *error))failureBlock
{
    // create one time publisher and style publisher
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             self.canPublish = granted;
             if(granted)
             {
                 OTError *error = nil;
                 self.publisher = [[OTPublisher alloc] initWithDelegate:self];
                 self.publisher.view.userInteractionEnabled = YES;
                 
                 if(error){
                     failureBlock(error);
                 }
                 else{
                     completionBlock();
                 }
             }
             else
             {
                 failureBlock([self errorWithCode:0 message:@"iOS Authorization failed"]);
             }
         });
     }];
}

-(void)unpublish
{
    [self.session unpublish:self.publisher error:nil];
    self.publisher = nil;
    
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_PUBLISHER_DESTROYED object:nil];
}

-(void)publishVideo:(BOOL)video audio:(BOOL)audio
{
    if(!self.publisher){
        [self setupPublisherWithCompletionBlock:^
        {
            self.publisher.publishVideo = video;
            self.publisher.publishAudio = audio;

            [self.session publish:self.publisher error:nil];
            [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_PUBLISHER_PUBLISHING object:nil];
        }
                                   failureBlock:^(NSError *error)
        {
            [self showAlert:error.localizedDescription];
        }];
    }else{
        self.publisher.publishVideo = video;
        self.publisher.publishAudio = audio;
        [self.session publish:self.publisher error:nil];
        [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_PUBLISHER_PUBLISHING object:nil];
    }
}

#pragma mark - Session events
- (void)sessionDidConnect:(OTSession*)session
{
    //register hangout.join on API
    [[TWICAPIClient sharedInstance]registerEventName:HangoutEventJoin
                                     completionBlock:^() {}
                                        failureBlock:^(NSError *error) {}];
    
    //firebase write
    [[TWICFirebaseClient sharedInstance]registerConnectedUser];
    
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_CONNECTED object:session];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    //firebase write
    [[TWICFirebaseClient sharedInstance]unregisterConnectedUser];
    
    // remove all subscriber views from video container
    for (int i = 0; i < [self.allConnectionsIds count]; i++)
    {
        OTSubscriber *subscriber = [self.allSubscribers valueForKey:[self.allConnectionsIds objectAtIndex:i]];
        [subscriber.view removeFromSuperview];
    }
    
    [self.publisher.view removeFromSuperview];
    
    [self.allSubscribers removeAllObjects];
    [self.allConnections removeAllObjects];
    [self.allConnectionsIds removeAllObjects];
    [self.allStreams removeAllObjects];
    self.publisher = nil;
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_DISCONNECTED object:session];
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection
{
    //user management
    //check if the user is in the list of existing users
    NSData *data = [connection.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    //store the connection
    [self.allConnections setObject:connection forKey:connection.connectionId];
    
    //register new or existing user
    __block NSDictionary *user = [[TWICUserManager sharedInstance] userWithUserID:dataJson[UserIdKey]];
    if(user==nil)
    {
        //retrieve the details for this user
        [[TWICUserManager sharedInstance] loadDetailsForUserID:dataJson[UserIdKey]
                                            completionBlock:^()
         {
             user = [[TWICUserManager sharedInstance] userWithUserID:dataJson[UserIdKey]];
             [self processUserConnected:user connection:connection];
             [self processAutoRecordManagement];
         }
                                               failureBlock:^(NSError *error) {}];
    }
    else
    {
        if([[TWICUserManager sharedInstance]isCurrentUser:user] == NO){
            [self processUserConnected:user connection:connection];
            [self processAutoRecordManagement];
        }
    }
}

-(void)processAutoRecordManagement{
    //recording management
    if([[[TWICHangoutManager sharedInstance]optionForKey:HangoutOptionRecord]boolValue]){
        //need to check if the nb or sutorecord user is the same has the number of connected users
        NSNumber *nbAutoRecordUsers = [[TWICHangoutManager sharedInstance] optionForKey:HangoutOptionNbUserAutoRecord];
        BOOL startRecording=NO;
        if(nbAutoRecordUsers){
            if([nbAutoRecordUsers intValue]<=[TWICUserManager sharedInstance].connectedUsersCount-1){//-1 because of me !
                startRecording = YES;
            }
        }else{
            startRecording = YES;
        }
        //start the record
        if(startRecording)
        {
            [[TWICAPIClient sharedInstance]startArchivingHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                                       completionBlock:^{}
                                                          failureBlock:^(NSError *error) {}
             ];
        }
    }
}

-(void)processUserConnected:(NSDictionary *)user connection:(OTConnection*)connection{
    //store the connection id for the user, the user can have multiple connection ids
    
    //update user connection state
    [[TWICUserManager sharedInstance] setConnectedUserStateForUserID:user[UserIdKey]];
    
    //check if he was asking for permissions
    if([[TWICUserManager sharedInstance] isUserAskingCameraPermission:user]){
        [self sendSignal:SignalTypeCameraAuthorization toUser:user];
    }
    if([user[UserAskMicrophone]boolValue]){
        [self.session signalWithType:SignalTypeCancelMicrophoneAuthorization string:nil connection:connection retryAfterReconnect:YES error:nil];
    }
    
    //send a message
    [[TWICMessageManager sharedInstance]addMessage:@{MessageTextKey:[NSString stringWithFormat:@"%@ joins the hangout",[[TWICUserManager sharedInstance]displayNameForUser:user]],
                                                     MessageUserIdKey:user[UserIdKey],
                                                     MessageIdKey:[[TWICMessageManager sharedInstance]lastMessageID],
                                                     MessageReadKey:@(NO)}];
    
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection
{
    //update user interface with the user disconnected
    NSData *data = [connection.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    [[TWICUserManager sharedInstance] setDisconnectedUserStateForUserID:dataJson[UserIdKey]];
    
    NSDictionary *user = [[TWICUserManager sharedInstance]userWithUserID:dataJson[UserIdKey]];
    
    //post message
    [[TWICMessageManager sharedInstance]addMessage:@{MessageTextKey:[NSString stringWithFormat:@"%@ leaves the hangout",[[TWICUserManager sharedInstance]displayNameForUser:user]],
                                                     MessageUserIdKey:user[UserIdKey],
                                                     MessageIdKey:[[TWICMessageManager sharedInstance]lastMessageID],
                                                     MessageReadKey:@(NO)}];
    
    [self.allConnections removeObjectForKey:connection.connectionId];
}


- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    [self showAlert:[NSString stringWithFormat:@"There was an error connecting to session %@",session.sessionId]];
    [self endCallAction:nil];
}

- (void)session:(nonnull OTSession*)session streamCreated:(nonnull OTStream*)stream
{
    // create remote subscriber
    [self createSubscriber:stream];
}

- (void)session:(nonnull OTSession*)session streamDestroyed:(nonnull OTStream*)stream
{
    // get subscriber for this stream
    OTSubscriber *subscriber = [self.allSubscribers objectForKey:stream.connection.connectionId];
    
    //retrieve the user
    NSData *data = [stream.connection.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    NSDictionary *user = [[TWICUserManager sharedInstance]userWithUserID:dataJson[UserIdKey]];

    //need to check the reason "force unpublished?"
    //add a message
    [[TWICMessageManager sharedInstance]addMessage:@{MessageTextKey:[NSString stringWithFormat:@"%@ stream has been turned off",[[TWICUserManager sharedInstance]displayNameForUser:user]],
                                                     MessageUserIdKey:user[UserIdKey],
                                                     MessageIdKey:[[TWICMessageManager sharedInstance]lastMessageID],
                                                     MessageReadKey:@(NO)}];
    
    // remove from superview
    [subscriber.view removeFromSuperview];
    
    [self.allSubscribers removeObjectForKey:stream.connection.connectionId];
    [self.allConnectionsIds removeObject:stream.connection.connectionId];
    [self.allStreams removeObjectForKey:stream.connection.connectionId];
    
    //disconnect the user
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SUBSCRIBER_DISCONNECTED object:subscriber];
}

#pragma mark - Signal Management

- (void)session:(nonnull OTSession*)session receivedSignalType:(NSString* _Nullable)type fromConnection:(OTConnection* _Nullable)connection withString:(NSString* _Nullable)string
{
    //retrieve the current user
    NSDictionary *currentUser = [TWICUserManager sharedInstance].currentUser;
    //retrieve the signaled user
    NSData *data = [connection.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    NSDictionary *signaledUser = [[TWICUserManager sharedInstance] userWithUserID:dataJson[UserIdKey]];
    BOOL isCurrentUser = [[TWICUserManager sharedInstance]isCurrentUser:signaledUser];
    
    if([type isEqualToString:SignalTypeCameraAuthorization])
    {
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            //check if this user has already send this request
            if([[TWICUserManager sharedInstance]isUserAskingCameraPermission:signaledUser] == NO){
                [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:signaledUser[UserIdKey] toValue:YES];
                [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_ASK_CAMERA_AUTHORIZATION object:signaledUser];
            }
        }
    }
    else if([type isEqualToString:SignalTypeMicrophoneAuthorization])
    {
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            //check if this user has already send this request
            if([[TWICUserManager sharedInstance]isUserAskingMicrophonePermission:signaledUser] == NO){
                [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:signaledUser[UserIdKey] toValue:YES];
                [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_ASK_MICROPHONE_AUTHORIZATION object:signaledUser];
            }
        }
    }
    else if([type isEqualToString:SignalTypeCancelScreenAuthorization]){
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskScreen]){
            //check if this user has already send this request
            if([[TWICUserManager sharedInstance]isUserAskingMicrophonePermission:signaledUser] == NO){
                [[TWICUserManager sharedInstance]setAskPermission:UserAskScreen forUserID:signaledUser[UserIdKey] toValue:YES];
                [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_USER_ASK_SCREEN_AUTHORIZATION object:signaledUser];
            }
        }
    }
    else if([type isEqualToString:SignalTypeCancelCameraAuthorization])
    {
        //does the user is the current user and was asking for permission
        if(isCurrentUser && [signaledUser[UserAskCamera]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:signaledUser[UserIdKey] toValue:NO];
        }
        
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_CANCEL_CAMERA_AUTHORIZATION object:signaledUser];
        }
    }
    else if([type isEqualToString:SignalTypeCancelMicrophoneAuthorization])
    {
        //does the user is the current user and was asking for permission
        if(isCurrentUser && [signaledUser[UserAskMicrophone]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:signaledUser[UserIdKey] toValue:NO];
        }
        
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_CANCEL_MICROPHONE_AUTHORIZATION object:signaledUser];
        }
    }
    else if([type isEqualToString:SignalTypeCameraRequested])//only received for me
    {
        if([currentUser[UserAskCamera]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:currentUser[UserIdKey] toValue:NO];
            //signal cancel for other users
            [self.session signalWithType:SignalTypeCancelCameraAuthorization string:nil connection:connection error:nil];
            //publish camera
            [self publishVideo:YES audio:YES];
        }
        else
        {
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_CAMERA_REQUESTED object:currentUser];
        }
    }
    else if([type isEqualToString:SignalTypeMicrophoneRequested])//only received for me
    {
        if([currentUser[UserAskMicrophone]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:currentUser[UserIdKey] toValue:NO];
            //signal cancel for other users
            [self.session signalWithType:SignalTypeCancelMicrophoneAuthorization string:nil connection:connection error:nil];
            //publish audio
            [self publishVideo:self.publisher.publishVideo audio:YES];
        }
        else
        {
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_MICROPHONE_REQUESTED object:currentUser];
        }
    }
    else if([type isEqualToString:SignalTypeForceMuteStream])
    {
        //flag my user or the stream that he was forcemute !
        [TWICTokClient sharedInstance].publisher.publishAudio = NO;
    }
    else if([type isEqualToString:SignalTypeForceUnmuteStream])
    {
        [TWICTokClient sharedInstance].publisher.publishAudio = YES;
    }
    else if([type isEqualToString:SignalTypeForceUnpublishStream])
    {
        [self unpublish];
    }
    else if([type isEqualToString:SignalTypeForceUnpublishScreen]){
        //nothing to do on mobile side
    }
    else if([type isEqualToString:SignalTypeKickUser]){
        [self disconnect];
    }
    else if([type isEqualToString:SignalTypeScreenRequested]){
        //should never appear on mobile
    }
}

-(void)broadcastSignal:(NSString *)signalName{
    [self.session signalWithType:signalName string:nil connection:nil error:nil];
}

-(void)sendSignal:(NSString *)signalName toUser:(NSDictionary*)user{
    OTConnection *userConnection = [self connectionForUser:user];
    if(userConnection){
        [self.session signalWithType:signalName string:nil connection:userConnection error:nil];
    }
}


-(OTError *)sendSignalType:(NSString *)signalType connection:(OTConnection *)connection
{
    OTError *error = nil;
    [self.session signalWithType:signalType string:nil connection:connection error:&error];
    return error;
}

#pragma mark - Archive events
- (void)session:(nonnull OTSession*)session archiveStartedWithId:(nonnull NSString*)archiveId name:(NSString* _Nullable)name
{
    self.archiveId = archiveId;
    
    //add message
    [[TWICMessageManager sharedInstance]addMessage:@{MessageTextKey:@"Recording started",
                                                     MessageIdKey:[[TWICMessageManager sharedInstance]lastMessageID],
                                                     MessageReadKey:@(NO)}];
    
    //raise event to update ui
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_ARCHIVE_STARTED object:archiveId];
}

- (void)session:(nonnull OTSession*)session archiveStoppedWithId:(nonnull NSString *)archiveId
{
    self.archiveId = nil;
    
    //add message
    [[TWICMessageManager sharedInstance]addMessage:@{MessageTextKey:@"Recording stopped",
                                                     MessageIdKey:[[TWICMessageManager sharedInstance]lastMessageID],
                                                     MessageReadKey:@(NO)}];
    //raise event to update ui
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_ARCHIVE_STOPPED object:archiveId];
}

-(BOOL)archiving{
    return self.archiveId!=nil;
}

#pragma mark - Publisher events
-(void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error
{
    [self showAlert:[NSString stringWithFormat:@"There was an error publishing: %@",error.localizedDescription]];
    [self endCallAction:nil];
}

- (void)publisher:(OTPublisherKit *)publisher streamCreated:(OTStream *)stream
{
    // create self subscriber
    //[self createSubscriber:stream];
}

#pragma mark - Subscriber events
- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber
{
    // create subscriber
    OTSubscriber *sub = (OTSubscriber *)subscriber;
    [self.allSubscribers setObject:subscriber forKey:sub.stream.connection.connectionId];
    [self.allConnectionsIds addObject:sub.stream.connection.connectionId];
    [self.allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
    
    //video is now available
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SUBSCRIBER_CONNECTED object:sub];
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    [self showAlert:[NSString stringWithFormat:@"The subscriber could not connect to stream: %@",error.localizedDescription]];
}

- (void)createSubscriber:(OTStream *)stream
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground ||
        [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
    {
        [self.backgroundConnectedStreams addObject:stream];
    }
    else
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
    }
}

- (void)enteringBackgroundMode:(NSNotification*)notification
{
    self.publisher.publishVideo = NO;
}

- (void)leavingBackgroundMode:(NSNotification*)notification
{
    //auto publishing ?
    if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishMicrophone] ||
       [[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishCamera])
    {
        if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishCamera])
        {
            [self publishVideo:YES audio:YES];
        }
        else if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishCamera])
        {
            [self publishVideo:NO audio:YES];
        }
    }
    
    //now subscribe to any background connected streams
    for (OTStream *stream in self.backgroundConnectedStreams)
    {
        // create subscriber
        OTSubscriber *subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        // subscribe now
        OTError *error = nil;
        [_session subscribe:subscriber error:&error];
        if (error)
        {
            [self showAlert:[error localizedDescription]];
        }
    }
    [self.backgroundConnectedStreams removeAllObjects];
}

- (IBAction)endCallAction:(UIButton *)button
{
    if (self.session && self.session.sessionConnectionStatus == OTSessionConnectionStatusConnected)
    {
        // disconnect session
        [self.session disconnect:nil];
    }
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [APPLICATION.delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];        
    });
}

-(OTSubscriber *)subscriberForConnectionID:(NSString *)connectionID
{
    return [self.allSubscribers objectForKey:connectionID];
}

-(NSArray *)orderedSubscriberIDs
{
    return self.allConnectionsIds;
}

-(OTStream *)streamForUser:(NSDictionary*)user
{
    for(OTStream *stream in [self.allStreams allValues])
    {
        NSData *data = [stream.connection.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        if([user[UserIdKey] isEqualToNumber:dataJson[UserIdKey]]){
            return stream;
        }
    }
    return nil;
}

-(OTConnection *)connectionForUser:(NSDictionary *)user
{
    for(OTConnection *connection in [self.allConnections allValues])
    {
        NSData *data = [connection.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        if([user[UserIdKey] isEqualToNumber:dataJson[UserIdKey]]){
            return connection;
        }
    }
    return nil;
}

-(NSDictionary *)userForSubscriberConnectionID:(NSString *)connectionID{
    OTSubscriber *subscriber = self.allSubscribers[connectionID];
    if(subscriber){
        NSData *data = [subscriber.stream.connection.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        return [[TWICUserManager sharedInstance]userWithUserID:dataJson[UserIdKey]];
    }
    return nil;
}

-(void)kickUser:(NSDictionary *)user
{
    [self sendSignal:SignalTypeKickUser toUser:user];
}

-(void)forceUnpublishStreamOfUser:(NSDictionary *)user
{
    [self sendSignal:SignalTypeForceUnpublishStream toUser:user];
}
-(void)forceUnpublishScreenOfUser:(NSDictionary *)user
{
    [self sendSignal:SignalTypeForceUnpublishScreen toUser:user];
}

@end
