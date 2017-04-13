//
//  TWICTokClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 12/04/2017.
//
//

#import <Foundation/Foundation.h>
#import "TWICConstants.h"

@interface TWICTokClient : NSObject

+ (TWICTokClient *)sharedInstance;

-(void)connectToSession:(NSString *)sessionID withUser:(NSDictionary *)user;

//session object that is used in stream view
@property (strong, nonatomic) OTPublisher*  publisher;

-(OTSubscriber *)subscriberForStreamID:(NSString *)streamID;
-(NSArray *)orderedSubscriberIDs;
@end
