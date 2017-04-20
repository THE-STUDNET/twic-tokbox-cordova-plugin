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
#define TWIC_CORNER_RADIUS      5
#define TWIC_ALPHA              0.8f

#define TWIC_STORYBOARD         [UIStoryboard storyboardWithName:@"TWICCordovaPlugin" bundle:nil]

//Notifications
#define TWIC_NOTIFICATION_SESSION_CONNECTED         @"tok_session_connected"
#define TWIC_NOTIFICATION_SESSION_DISCONNECTED      @"tok_session_disconnected"
#define TWIC_NOTIFICATION_SUBSCRIBER_CONNECTED      @"tok_subscriber_connected"
#define TWIC_NOTIFICATION_SUBSCRIBER_DISCONNECTED   @"tok_subscriber_disconnected"


//TWICPlaftform
#define ERROR_DOMAIN                    @"com.twicplatform.error"


#endif /* TWICConstants_h */
