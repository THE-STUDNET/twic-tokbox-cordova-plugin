//
//  TWICTokClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 12/04/2017.
//
//

#import "TWICTokClient.h"
#import <OpenTok/OpenTok.h>

@interface TWICTokClient()<OTSessionDelegate>
@property (strong, nonatomic) NSDictionary *user;
@property (nonatomic, strong) NSDictionary *subscribers;
@property (nonatomic, strong) OTPublisher *publisher;
@end

@implementation TWICTokClient

+ (TWICTokClient *)sharedInstance
{
    static TWICTokClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICTokClient alloc] init];
    });
    return _sharedClient;
}

#pragma mark - Session Management
-(void)connectToSession:(NSString *)sessionID withUser:(NSDictionary *)user
{
    self.session = [[OTSession alloc] initWithApiKey:TOK_API_KEY
                                       sessionId:TOK_SESSION_ID
                                        delegate:self];
    
    [self.session connectWithToken:user[TWIC_USER_TOK_TOKEN] error:nil];
}

- (void)sessionDidConnect:(OTSession*)session
{
    self.session = session;
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_CONNECTED object:session];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_SESSION_DISCONNECTED object:session];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

#pragma mark - Stream Management
- (void)session:(nonnull OTSession*)session streamCreated:(nonnull OTStream*)stream
{
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_STREAM_CREATED object:stream];
}
- (void)session:(nonnull OTSession*)session streamDestroyed:(nonnull OTStream*)stream
{
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_STREAM_DESTROYED object:stream];
}

@end
