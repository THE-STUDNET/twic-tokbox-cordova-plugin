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

@interface TWICTokClient()<OTSessionDelegate,OTPublisherKitDelegate,OTSubscriberKitDelegate>

@property(strong, nonatomic) NSMutableDictionary *allStreams;
@property(strong, nonatomic) NSMutableDictionary *allSubscribers;
@property(strong, nonatomic) NSMutableArray *allConnectionsIds;
@property(strong, nonatomic) NSMutableArray *backgroundConnectedStreams;

@property (strong, nonatomic) OTSession* session;
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

#pragma mark - Session Management
-(void)connect{
    [[TWICAPIClient sharedInstance]tokboxDataWithCompletionBlock:^(NSDictionary *data)
     {
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
    
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_CONNECTED object:session];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    // remove all subscriber views from video container
    for (int i = 0; i < [self.allConnectionsIds count]; i++)
    {
        OTSubscriber *subscriber = [self.allSubscribers valueForKey:
                                    [self.allConnectionsIds objectAtIndex:i]];
        [subscriber.view removeFromSuperview];
    }
    
    [self.publisher.view removeFromSuperview];
    
    [self.allSubscribers removeAllObjects];
    [self.allConnectionsIds removeAllObjects];
    [self.allStreams removeAllObjects];
    self.publisher = nil;
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_DISCONNECTED object:session];
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection
{
    //connection du user
    
    //check if the user is in the list of existing users
    NSData *data = [connection.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
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
         }
                                               failureBlock:^(NSError *error) {}];
    }
    else
    {
        if([[TWICUserManager sharedInstance]isCurrentUser:user] == NO){
            [self processUserConnected:user connection:connection];
        }
    }
}

-(void)processUserConnected:(NSDictionary *)user connection:(OTConnection*)connection{
    //store the connection id for the user, the user can have multiple connection ids
    
    //update user connection state
    [[TWICUserManager sharedInstance] setConnectedUserStateForUserID:user[UserIdKey]];
    
    //check if he was asking for permissions
    if([user[UserAskScreen]boolValue]){
        [self.session signalWithType:SignalTypeCameraAuthorization string:nil connection:connection retryAfterReconnect:YES error:nil];
    }
    if([user[UserAskMicrophone]boolValue]){
        [self.session signalWithType:SignalTypeCancelMicrophoneAuthorization string:nil connection:connection retryAfterReconnect:YES error:nil];
    }
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection
{
    //update user interface with the user disconnected
    NSData *data = [connection.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataJson = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    [[TWICUserManager sharedInstance] setConnectedUserStateForUserID:dataJson[UserIdKey]];
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
    
    // remove from superview
    [subscriber.view removeFromSuperview];
    
    [self.allSubscribers removeObjectForKey:stream.connection.connectionId];
    [self.allConnectionsIds removeObject:stream.connection.connectionId];
    
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
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_ASK_CAMERA_AUTHORIZATION object:signaledUser];
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:signaledUser[UserIdKey] toValue:YES];
        }
    }
    else if([type isEqualToString:SignalTypeCancelCameraAuthorization])
    {
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_CANCEL_CAMERA_AUTHORIZATION object:signaledUser];
        }
        //does the user is the current user and was asking for permission
        if(isCurrentUser && [signaledUser[UserAskCamera]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:signaledUser[UserIdKey] toValue:NO];
        }
    }
    else if([type isEqualToString:SignalTypeCancelMicrophoneAuthorization])
    {
        //check if this user has already send this request
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_CANCEL_MICROPHONE_AUTHORIZATION object:signaledUser];
        }
        
        //does the user is the current user and was asking for permission
        if(isCurrentUser && [signaledUser[UserAskMicrophone]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:signaledUser[UserIdKey] toValue:NO];
        }
    }
    else if([type isEqualToString:SignalTypeMicrophoneAuthorization])
    {
        //check if this user has already send this request
        //can the current user process the request
        if([[TWICHangoutManager sharedInstance] canUser:currentUser doAction:HangoutActionAskDevice]){
            [NOTIFICATION_CENTER postNotificationName:NOTIFICATION_USER_ASK_MICROPHONE_AUTHORIZATION object:signaledUser];
            [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:signaledUser[UserIdKey] toValue:YES];
        }
    }
    else if([type isEqualToString:SignalTypeCameraRequested])//only received for me
    {
        if([currentUser[UserAskCamera]boolValue]){
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:currentUser[UserIdKey] toValue:NO];
            //signal cancel for other users
            [self.session signalWithType:SignalTypeCancelCameraAuthorization string:nil connection:connection error:nil];
            //publish camera
            self.publisher.publishVideo = YES;
            self.publisher.publishAudio = YES;
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
            self.publisher.publishAudio = YES;
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
}

-(void)broadcastSignal:(NSString *)signalName{
    [self.session signalWithType:signalName string:nil connection:nil error:nil];
}

-(void)sendSignal:(NSString *)signalName toUser:(NSDictionary*)user{
    OTStream *userStream = [self streamForUser:user];
    if(userStream){
        [self.session signalWithType:signalName string:nil connection:userStream.connection error:nil];
    }
}


-(OTError *)sendSignalType:(NSString *)signalType connection:(OTConnection *)connection
{
    OTError *error = nil;
    [self.session signalWithType:signalType string:nil connection:connection error:&error];
    return error;
}

- (void)session:(nonnull OTSession*)session archiveStartedWithId:(nonnull NSString*)archiveId name:(NSString* _Nullable)name
{
    //raise event to update ui
}

- (void)session:(nonnull OTSession*)session archiveStoppedWithId:(nonnull NSString *)archiveId
{
    //raise event to update ui
}


#pragma mark - Publisher events
-(void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error
{
    [self showAlert:[NSString stringWithFormat:@"There was an error publishing."]];
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
    NSLog(@"subscriber could not connect to stream");
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
#warning TO BE CHANGED ==> CAN I AUTO-PUBLISH ??
    self.publisher.publishVideo = YES;
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from video session"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

-(OTSubscriber *)subscriberForStreamID:(NSString *)streamID
{
    return [self.allSubscribers objectForKey:streamID];
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

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [NSError errorWithDomain:ERROR_DOMAIN code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}
@end
