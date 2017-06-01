//
//  FirebaseClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 10/03/2017.
//
//

#import <Foundation/Foundation.h>

@interface TWICFirebaseClient : NSObject

+ (TWICFirebaseClient *)sharedInstance;

//init with embedded values
-(void)configure;

-(void)registerConnectedUser;
-(void)unregisterConnectedUser;

@end
