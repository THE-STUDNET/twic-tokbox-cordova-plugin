//
//  SocketIOClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import <Foundation/Foundation.h>

@interface TWICSocketIOClient : NSObject

+ (TWICSocketIOClient *)sharedInstance;


-(void)connect;

@end
