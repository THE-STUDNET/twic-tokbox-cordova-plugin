//
//  TWICTokClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 12/04/2017.
//
//

#import <Foundation/Foundation.h>
#import "TWICConstants.h"

static NSString *SignalTypeCameraAuthorization           = @"hgt_camera_authorization";
static NSString *SignalTypeCancelCameraAuthorization     = @"hgt_cancel_camera_authorization";
static NSString *SignalTypeCancelMicrophoneAuthorization = @"hgt_cancel_microphone_authorization";
static NSString *SignalTypeMicrophoneAuthorization       = @"hgt_microphone_authorization";
static NSString *SignalTypeCameraRequested               = @"hgt_camera_requested";
static NSString *SignalTypeMicrophoneRequested           = @"hgt_microphone_requested";
static NSString *SignalTypeForceMuteStream               = @"hgt_force_mute_stream";
static NSString *SignalTypeForceUnmuteStream             = @"hgt_force_unmute_stream";
static NSString *SignalTypeKickUser                      = @"hgt_kick_user";
static NSString *SignalTypeForceUnpublishStream          = @"hgt_force_unpublish_stream";
static NSString *SignalTypeForceUnpublishScreen          = @"hgt_force_unpublish_screen";
static NSString *SignalTypeScreenRequested               = @"hgt_screen_requested";
static NSString *SignalTypeCancelScreenAuthorization     = @"hgt_cancel_screen_authorization";

@interface TWICTokClient : NSObject

+ (TWICTokClient *)sharedInstance;

-(void)connect;
-(void)disconnect;

//publish/unpublish publisher stream
-(void)unpublish;
-(void)publishVideo:(BOOL)video audio:(BOOL)audio;
@property(nonatomic, assign)BOOL canPublish;//is user authorized to publish

//signaling
-(void)broadcastSignal:(NSString *)signalName;
-(void)sendSignal:(NSString *)signalName toUser:(NSDictionary*)user;

//kick
-(void)kickUser:(NSDictionary *)user;
-(void)forceUnpublishStreamOfUser:(NSDictionary *)user;
-(void)forceUnpublishScreenOfUser:(NSDictionary *)user;

//session object that is used in stream view
@property (strong, nonatomic) OTPublisher*  publisher;

//streams
-(OTSubscriber *)subscriberForStreamID:(NSString *)streamID;
-(NSArray *)orderedStreamIDs;
-(NSArray *)streamsForUser:(NSDictionary*)user;

//archiving
@property(nonatomic, readonly)BOOL archiving;

//users <=> streams
-(NSDictionary *)userForStreamID:(NSString *)streamID;
@end
