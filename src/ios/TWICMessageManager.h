//
//  TWICMessagesManager.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 14/06/2017.
//
//

#import <UIKit/UIKit.h>

//api
static NSString *MessageTextKey   = @"text";
static NSString *MessageIdKey     = @"id";
static NSString *MessageUserIdKey = @"user_id";

//local
static NSString *MessageReadKey = @"read";

@interface TWICMessageManager : NSObject

+ (TWICMessageManager *)sharedInstance;

-(void)loadMessages;
-(void)loadLatestMessages;
-(void)loadHistoricalMessages;
-(void)addMessage:(NSDictionary *)message;
-(NSString *)lastMessageID;

-(NSArray *)allMessages;
-(int)unreadMessagesCount;
-(void)markMessagesAsRead;

@end
