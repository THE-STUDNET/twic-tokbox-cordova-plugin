//
//  TWICConstants.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#ifndef TWICConstants_h
#define TWICConstants_h

#import "GONMacros_all.h"
#import "NSString+Color.h"
#import "SVProgressHUD.h"
#import <OpenTok/OpenTok.h>

#define TWIC_COLOR_RED          [@"#DF5656" representedColor]
#define TWIC_COLOR_GREY         [@"#494C56" representedColor]
#define TWIC_COLOR_GREEN        [@"#54B55A" representedColor]
#define TWIC_COLOR_BLACK        [@"#444444" representedColor]
#define TWIC_COLOR_BLUE         [@"5886EE"  representedColor]
#define TWIC_CORNER_RADIUS      5
#define TWIC_ALPHA              0.8f

#define TWIC_STORYBOARD         [UIStoryboard storyboardWithName:@"TWICCordovaPlugin" bundle:nil]

//Notifications
#define TWIC_NOTIFICATION_SESSION_CONNECTED               @"tok_session_connected"
#define TWIC_NOTIFICATION_SESSION_DISCONNECTED            @"tok_session_disconnected"
#define TWIC_NOTIFICATION_SUBSCRIBER_CONNECTED            @"tok_subscriber_connected"
#define TWIC_NOTIFICATION_SUBSCRIBER_DISCONNECTED         @"tok_subscriber_disconnected"
#define TWIC_NOTIFICATION_SUBSCRIBER_VIDEO_CHANGED        @"tok_subscriber_video_changed"
#define TWIC_NOTIFICATION_USER_CONNECTED                  @"tok_user_connected"
#define TWIC_NOTIFICATION_USER_DISCONNECTED               @"tok_user_disconnected"
#define TWIC_NOTIFICATION_USER_ASKPERMISSION_UPDATED      @"tok_user_askpermission_updated"
#define NOTIFICATION_USER_ASK_CAMERA_AUTHORIZATION        @"tok_user_askcamera_authorization"
#define NOTIFICATION_USER_CANCEL_CAMERA_AUTHORIZATION     @"tok_user_cancelcamera_authorization"
#define NOTIFICATION_USER_ASK_MICROPHONE_AUTHORIZATION    @"tok_user_askmicrophone_authorization"
#define NOTIFICATION_USER_CANCEL_MICROPHONE_AUTHORIZATION @"tok_user_cancelmicrophone_authorization"
#define NOTIFICATION_USER_MICROPHONE_REQUESTED            @"tok_user_microphone_request"
#define NOTIFICATION_USER_CAMERA_REQUESTED                @"tok_user_camera_request"
#define TWIC_NOTIFICATION_PUBLISHER_DESTROYED             @"tok_publisher_destroyed"
#define TWIC_NOTIFICATION_PUBLISHER_PUBLISHING            @"tok_publisher_publishing"
#define TWIC_NOTIFICATION_USER_ASK_SCREEN_AUTHORIZATION   @"tok_user_askscreen_authorization"
#define TWIC_NOTIFICATION_USER_CANCEL_SCREEN_AUTHORIZATION @"tok_user_cancelscreen_authorization"
#define TWIC_NOTIFICATION_SESSION_ARCHIVE_STARTED         @"tok_session_archive_started"
#define TWIC_NOTIFICATION_SESSION_ARCHIVE_STOPPED         @"tok_session_archive_stoped"
//chat
#define TWIC_NOTIFICATION_NEW_MESSAGE                     @"new_message"
#define TWIC_NOTIFICATION_MESSAGES_LOADED                 @"messages_loaded"
#define TWIC_NOTIFICATION_LATEST_MESSAGES_LOADED          @"latest_messages_loaded"
#define TWIC_NOTIFICATION_HISTORICAL_MESSAGES_LOADED      @"historical_messages_loaded"

//TWICPlaftform
#define ERROR_DOMAIN                    @"com.twicplatform.error"


#endif /* TWICConstants_h */
