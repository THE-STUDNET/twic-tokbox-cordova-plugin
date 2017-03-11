//
//  SocketIOClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import "TWICSocketIOClient.h"
@import SocketIO;

@interface TWICSocketIOClient()
@property (nonatomic, strong)SocketIOClient *socket;
@end

@implementation TWICSocketIOClient

static NSString *_auth_token = @"2437e141f8ed03a110e3292ce54c741eff6164d5";
static NSString *_domain = @"ws-new.thestudnet.com";
static int _port = 443;

static NSString *event_authentify = @"authentify";
static NSString *event_authenticated = @"authenticated";
static NSString *event_ch_message = @"ch.message";

+ (TWICSocketIOClient *)sharedInstance
{
    static TWICSocketIOClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICSocketIOClient alloc] init];
    });
    return _sharedClient;
}

-(SocketIOClient*)socket{
    if(!_socket)
    {
        NSURL* url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@:%d",_domain,_port]];
        _socket = [[SocketIOClient alloc] initWithSocketURL:url
                                                     config:@{@"log": @YES,
                                                              @"selfSigned":@YES,
                                                              @"forceWebsockets":@NO,
                                                              @"doubleEncodeUTF8":@NO}];
    }
    return _socket;
}

-(void)connect{
    [self.socket connectWithTimeoutAfter:5 withHandler:^
    {
        if(self.socket.status == SocketIOClientStatusConnected){
            NSUUID  *UUID = [NSUUID UUID];
            NSString* stringUUID = [UUID UUIDString];
            
            NSDictionary *data = @{@"user_id":@"1",
                                   @"authentification":_auth_token,
                                   @"connection_token":stringUUID};
            
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
    //                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
    //                                                             error:nil];
            
            [self.socket emit:event_authentify with:@[data]];
        }else{
            NSLog(@"%@",self.socket);
        }
    }];
    
    [self.socket on:event_authenticated callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack)
    {
        NSLog(@"%@",data);
        
    }];
    
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
    }];
}

- (void)engineDidErrorWithReason:(NSString * _Nonnull)reason{
    
}

/*
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
*/
@end
