//
//  TWICTokClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 12/04/2017.
//
//

#import "TWICTokClient.h"
#import <OpenTok/OpenTok.h>

@interface TWICTokClient()<OTSessionDelegate,OTPublisherKitDelegate,OTSubscriberKitDelegate>
@property (strong, nonatomic) NSDictionary *user;

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
-(void)connectToSession:(NSString *)sessionID withUser:(NSDictionary *)user
{
    self.user = user;
    self.session = [[OTSession alloc] initWithApiKey:TOK_API_KEY
                                       sessionId:TOK_SESSION_ID
                                        delegate:self];
    
    [self.session connectWithToken:user[TWIC_USER_TOK_TOKEN] error:nil];
    
    //now publish
    [self setupPublisher];
}

-(void)setupPublisher
{
    self.publisher = [[OTPublisher alloc] initWithDelegate:self];
    self.publisher.view.userInteractionEnabled = YES;
}

#pragma mark - Session events
- (void)sessionDidConnect:(OTSession*)session
{
    if (self.session.capabilities.canPublish)
    {
        // create one time publisher and style publisher
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 self.publisher.publishAudio = YES;
                 self.publisher.publishVideo = YES;
                 OTError *error = nil;
                 [self.session publish:self.publisher error:nil];
                 if(error){
                     [self showAlert:error.localizedDescription];
                 }
             }
             else
             {
                 [self showAlert:@"iOS Authorization failed"];
             }
         }];
    }
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

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"connectionDestroyed: %@", connection);
}

- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection
{
    NSLog(@"addConnection: %@", connection);
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
@end
