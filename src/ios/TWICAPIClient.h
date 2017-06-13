//
//  TWICPlatformClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 18/04/2017.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


static NSString *HangoutEventJoin                 = @"hangout.join";
static NSString *HangoutEventLeave                = @"hangout.leave";
static NSString *HangoutEventUsersPoke            = @"hangout.userspoke";
static NSString *HangoutEventShareCamera          = @"hangout.sharecamera";
static NSString *HangoutEventShareMicrophone      = @"hangout.sharemicrophone";
static NSString *HangoutEventMessage              = @"hangout.message";
static NSString *HangoutEventStartRecord          = @"hangout.startrecord";
static NSString *HangoutEventStopRecord           = @"hangout.stoprecord";
static NSString *HangoutEventLaunchUserCamera     = @"hangout.launchusercamera";
static NSString *HangoutEventLaunchUserMicrophone = @"hangout.launchusermicrophone";
static NSString *HangoutEventLaunchUserScreen     = @"hangout.launchuserscreen";
static NSString *HangoutEventAskMicrophoneAuth    = @"hangout.ask_microphone_auth";
static NSString *HangoutEventAskCameraAuth        = @"hangout.ask_camera_auth";

@interface TWICAPIClient : AFHTTPSessionManager
+ (TWICAPIClient *)sharedInstance;

/*Error convenience method*/
- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

-(void)hangoutDataWithCompletionBlock:(void(^)(NSDictionary *data))completionBlock
                         failureBlock:(void (^)(NSError *error))failureBlock;

-(void)tokboxDataWithCompletionBlock:(void(^)(NSDictionary *data))completionBlock
                        failureBlock:(void (^)(NSError *error))failureBlock;

-(void)detailForUser:(NSNumber*)userId
     completionBlock:(void(^)(NSDictionary *data))completionBlock
        failureBlock:(void (^)(NSError *error))failureBlock;

-(void)detailForUsers:(NSArray*)userIds
      completionBlock:(void(^)(NSArray *data))completionBlock
         failureBlock:(void (^)(NSError *error))failureBlock;

-(void)registerEventName:(NSString *)eventName
         completionBlock:(void(^)())completionBlock
            failureBlock:(void (^)(NSError *error))failureBlock;

-(void)startArchivingHangoutWithID:(NSString *)hangoutID
                   completionBlock:(void(^)())completionBlock
                      failureBlock:(void (^)(NSError *error))failureBlock;

-(void)stopArchivingHangoutWithID:(NSString *)hangoutID
                  completionBlock:(void(^)())completionBlock
                     failureBlock:(void (^)(NSError *error))failureBlock;

-(void)listMessageForHangoutWithID:(NSString *)hangoutID
                   completionBlock:(void(^)(NSArray *messages))completionBlock
                      failureBlock:(void (^)(NSError *error))failureBlock;

@end
