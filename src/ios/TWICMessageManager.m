//
//  TWICMessageManager.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 14/06/2017.
//
//

#import "TWICMessageManager.h"
#import "TWICSocketIOClient.h"
#import "TWICAPIClient.h"
#import "TWICSettingsManager.h"
#import "TWICConstants.h"

@interface TWICMessageManager()<TWICSocketIOClientDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation TWICMessageManager

+ (TWICMessageManager *)sharedInstance
{
    static TWICMessageManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TWICMessageManager alloc] init];
        _sharedClient.messages = [NSMutableArray array];
        [TWICSocketIOClient sharedInstance].delegate = _sharedClient;
    });
    return _sharedClient;
}

-(void)loadMessages{
    //list all messages and flag them as unread
    [[TWICAPIClient sharedInstance]listMessageForHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                               completionBlock:^(NSArray *messages)
    {
        [self.messages removeAllObjects];
        if(messages.count > 0){
            [self insertNewMessages:messages];
            [self sortMessages];
        }
        [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_MESSAGES_LOADED object:nil];
    }
                                                  failureBlock:^(NSError *error) {}];

}

-(void)loadLatestMessages
{
    [[TWICAPIClient sharedInstance]listMessageForHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                                 fromMessageID:[self.messages[self.messages.count - 1][MessageIdKey]description]
                                               completionBlock:^(NSArray *messages)
    {
        if(messages.count > 0){
            [self insertNewMessages:messages];
            [self sortMessages];
            [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_LATEST_MESSAGES_LOADED object:@(YES)];
        }else{
            [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_LATEST_MESSAGES_LOADED object:@(NO)];
        }
        
    }
                                                  failureBlock:^(NSError *error){}];
}
-(void)loadHistoricalMessages
{
    [[TWICAPIClient sharedInstance]listMessageForHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                                 toMessageID:[self.messages[0][MessageIdKey]description]
                                               completionBlock:^(NSArray *messages)
     {
         if(messages.count > 0){
             [self insertNewMessages:messages];
             [self sortMessages];
             [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_HISTORICAL_MESSAGES_LOADED object:@(YES)];
         }else{
             [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_HISTORICAL_MESSAGES_LOADED object:@(NO)];
         }
         
     }
                                                  failureBlock:^(NSError *error){}];
}
-(void)insertNewMessages:(NSArray *)messages{
    for(NSDictionary *message in messages){
        NSMutableDictionary *localMessage = [message mutableCopy];
        localMessage[MessageReadKey] = @(NO);
        [self.messages addObject:localMessage];
    }
}
-(void)sortMessages{
    //sort the list by id
    [self.messages sortUsingComparator:^NSComparisonResult(NSDictionary *  _Nonnull obj1, NSDictionary *  _Nonnull obj2) {
        return [obj1[MessageIdKey]compare:obj2[MessageIdKey]];
    }];
}

-(NSArray *)allMessages{
    return self.messages;
}

-(int)unreadMessagesCount{
    int unreadMessagesCount = 0;
    for(NSDictionary *message in self.messages){
        if([message[MessageReadKey]boolValue] == NO){
            unreadMessagesCount++;
        }
    }
    return unreadMessagesCount;
}

-(void)markMessagesAsRead
{
    //call api
    [[TWICAPIClient sharedInstance]setConversatonAsReadForHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                                        completionBlock:^
    {
        for(NSMutableDictionary *message in self.messages){
            message[MessageReadKey] = @(YES);
        }
    }
                                                           failureBlock:^(NSError *error)
    {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void)addMessage:(NSDictionary *)message{
    [self.messages addObject:message];
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_NEW_MESSAGE object:MessageReadKey];
}

-(void)twicSocketIOClient:(id)sender didReceiveMessage:(NSDictionary *)messageObject
{
    [self loadLatestMessages];
}
-(NSString *)lastMessageID
{
    return self.messages[self.messages.count - 1][MessageIdKey];
}
@end
