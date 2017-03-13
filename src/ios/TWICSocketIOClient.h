//
//  SocketIOClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import <Foundation/Foundation.h>


@protocol TWICSocketIOClientDelegate <NSObject>

-(void)twicSocketIOClient:(id)sender didReceiveMessage:(NSDictionary *)messageObject;

@end

@interface TWICSocketIOClient : NSObject

+ (TWICSocketIOClient *)sharedInstance;

@property(nonatomic, assign)id<TWICSocketIOClientDelegate> delegate;

-(void)connect;
-(void)sendEvent:(NSString *)event data:(id)data;

@end
