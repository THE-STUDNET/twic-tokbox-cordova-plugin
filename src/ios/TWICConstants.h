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

//TOK
#define TOK_API_KEY @"45720402"
#define TOK_SESSION_ID @"1_MX40NTcyMDQwMn5-MTQ4ODI3NDcyNTc4Mn5SdEpBWXFkNmRFTysrZmg0YnJwSnllbmh-UH4"
#define TOK_TOKEN @"T1==cGFydG5lcl9pZD00NTcyMDQwMiZzaWc9MmM4YTkyMDFhMzMwYzkyM2JiMzc4ZjUzMjJlNzZhNDY4ODZmM2I0YjpzZXNzaW9uX2lkPTFfTVg0ME5UY3lNRFF3TW41LU1UUTRPREkzTkRjeU5UYzRNbjVTZEVwQldYRmtObVJGVHlzclptZzBZbkp3U25sbGJtaC1VSDQmY3JlYXRlX3RpbWU9MTQ4ODI3NDcyNiZyb2xlPW1vZGVyYXRvciZub25jZT0xNDg4Mjc0NzI2LjAxNzQxNzQ4NjU1MzI1JmV4cGlyZV90aW1lPTE0OTA4NjY3MjYmY29ubmVjdGlvbl9kYXRhPSU3QiUyMmlkJTIyJTNBMSU3RA=="

#endif /* TWICConstants_h */
