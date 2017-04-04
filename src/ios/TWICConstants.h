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
#import "AFNetworking.h"

#define TWIC_COLOR_RED          [@"#DF5656" representedColor]
#define TWIC_COLOR_GREY         [@"#494C56" representedColor]
#define TWIC_COLOR_GREEN        [@"#54B55A" representedColor]
#define TWIC_CORNER_RADIUS      5
#define TWIC_ALPHA              0.8f

#define TWIC_STORYBOARD         [UIStoryboard storyboardWithName:@"TWICCordovaPlugin" bundle:nil]

//User data
#define TWIC_USER_AVATAR_URL_KEY        @"avatar_url"
#define TWIC_USER_FIRSTNAME_KEY         @"firstname"
#define TWIC_USER_LASTNAME_KEY          @"lastname"
#define TWIC_USER_ACTIONS_KEY           @"actions"
#define TWIC_USER_ACTION_TITLE_KEY      @"action_title"
#define TWIC_USER_ACTION_IMAGE_KEY      @"action_image"
#define TWIC_USER_ACTION_IS_ADMIN_KEY   @"action_isAdmin"

#endif /* TWICConstants_h */
