//
//  SocketIOClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import "SocketIOClient.h"
#import <socket_IO/SocketIO.h>
#import <socket_IO/SocketIOPacket.h>

@interface SocketIOClient()<SocketIODelegate>

@property (nonatomic, strong) SocketIO *socket;

@end

@implementation SocketIOClient

static NSString *_auth_token = @"2437e141f8ed03a110e3292ce54c741eff6164d5";
static NSString *_domain = @"ws-new.thestudnet.com";
static int _port = 443;

static NSString *event_authentify = @"authentify";
static NSString *event_authenticated = @"authenticated";
static NSString *event_ch_message = @"ch.message";

+ (SocketIOClient *)sharedInstance
{
    static SocketIOClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SocketIOClient alloc] init];
    });
    return _sharedClient;
}

-(void)connect{
    self.socket = [[SocketIO alloc] initWithDelegate:self];
    self.socket.useSecure = YES;
    [self.socket connectToHost:_domain onPort:_port];
}


- (void) socketIODidConnect:(SocketIO *)socket
{
    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [UUID UUIDString];
    
    NSDictionary *data = @{@"user_id":@"1",
                           @"authentification":_auth_token,
                           @"connection_token":stringUUID};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:nil];
    
    [self.socket sendEvent:event_authentify withData:jsonData];
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socketIODidDisconnect");
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    NSLog(@"%@",data);
}
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    NSLog(@"%@",data);
}
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    NSLog(@"%@",data);
}
- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    NSLog(@"%@",data);
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
}

@end
