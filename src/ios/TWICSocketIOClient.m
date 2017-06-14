//
//  SocketIOClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import "TWICSocketIOClient.h"
#import "SVProgressHUD.h"
#import "TWICSettingsManager.h"

@import SocketIO;

@interface TWICSocketIOClient()
@property (nonatomic, strong)SocketIOClient *socket;
@end

@implementation TWICSocketIOClient

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
        NSDictionary *wssettings = [[TWICSettingsManager sharedInstance] settingsForKey:SettingsWSKey];
        
        NSURL* url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"wss://%@",wssettings[SettingsDomainKey]]];
        _socket = [[SocketIOClient alloc] initWithSocketURL:url
                                                     config:@{@"log": @YES,
                                                              @"selfSigned":@YES,
                                                              @"forceWebsockets":@NO,
                                                              @"doubleEncodeUTF8":@NO,
                                                              @"forceNew":@YES,
                                                              @"secure":wssettings[SettingsSecureKey]}];
    }
    return _socket;
}

-(void)connect{
    __weak __typeof(self) weakSelf = self;
    
    [self.socket connect];
    
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSUUID  *UUID = [NSUUID UUID];
        NSString* stringUUID = [UUID UUIDString];
        NSDictionary *wssettings = [[TWICSettingsManager sharedInstance] settingsForKey:SettingsWSKey];
        
        NSDictionary *dataToSend = @{@"id":[[TWICSettingsManager sharedInstance] settingsForKey:SettingsUserIdKey],
                                     @"authentification":wssettings[SettingsAuthTokenKey],
                                     @"connection_token":stringUUID};
        
        [weakSelf.socket emit:action_authentify with:@[dataToSend]];
    }];
    
    [self.socket on:event_authenticated callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"%@",data);
    }];
    
    [self.socket on:event_ch_message callback:^(NSArray * data, SocketAckEmitter * ack) {
        if([data count] > 0){
            [weakSelf.delegate twicSocketIOClient:self didReceiveMessage:[data firstObject]];
        }
    }];
    
    [self.socket on:@"connect_timeout" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect_timeout");
    }];

    [self.socket on:@"connect_error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect_error");
    }];
}

-(void)sendEvent:(NSString *)event data:(id)data{

}
@end
