//
//  SocketIOClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import <Foundation/Foundation.h>

@interface SocketIOClient : NSObject

+ (SocketIOClient *)sharedInstance;


-(void)connect;

@end
