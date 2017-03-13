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
static NSString *_domain     = @"ws-new.thestudnet.com";

static NSString *event_connect              = @"connect";
static NSString *event_authenticated        = @"authenticated";
static NSString *event_ch_message           = @"ch.message";
static NSString *event_connection_timeout   = @"connect_timeout";
static NSString *event_connection_error     = @"connect_error";
static NSString *action_authentify           = @"authentify";

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
        NSURL* url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"wss://%@",_domain]];
        _socket = [[SocketIOClient alloc] initWithSocketURL:url
                                                     config:@{@"log": @YES,
                                                              @"selfSigned":@YES,
                                                              @"forceWebsockets":@NO,
                                                              @"doubleEncodeUTF8":@NO,
                                                              @"forceNew":@YES,
                                                              @"secure":@YES}];
    }
    return _socket;
}

-(void)connect{
    __weak __typeof(self) weakSelf = self;
    
    [self.socket connect];
    
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSUUID  *UUID = [NSUUID UUID];
        NSString* stringUUID = [UUID UUIDString];
        
        NSDictionary *dataToSend = @{@"id":@(1),
                                     @"authentification":_auth_token,
                                     @"connection_token":stringUUID};
        
        [weakSelf.socket emit:action_authentify with:@[dataToSend]];
    }];
    
    [self.socket on:event_authenticated callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"%@",data);
    }];
    
    [self.socket on:event_ch_message callback:^(NSArray * data, SocketAckEmitter * ack) {
        NSLog(@"%@",data);
    }];
    
    [self.socket on:@"connect_timeout" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect_timeout");
    }];

    [self.socket on:@"connect_error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect_error");
    }];
}
@end
