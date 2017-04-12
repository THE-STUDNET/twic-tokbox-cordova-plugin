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

//User data
#define TWIC_USER_AVATAR_URL_KEY        @"avatar_url"
#define TWIC_USER_FIRSTNAME_KEY         @"firstname"
#define TWIC_USER_LASTNAME_KEY          @"lastname"
#define TWIC_USER_ACTIONS_KEY           @"actions"
#define TWIC_USER_ACTION_TITLE_KEY      @"action_title"
#define TWIC_USER_ACTION_IMAGE_KEY      @"action_image"
#define TWIC_USER_ACTION_IS_ADMIN_KEY   @"action_isAdmin"
#define TWIC_USER_TOK_TOKEN             @"tok_token"

//Notifications
#define TWIC_NOTIFICATION_SESSION_CONNECTED      @"tok_session_connected"
#define TWIC_NOTIFICATION_SESSION_DISCONNECTED   @"tok_session_disconnected"
#define TWIC_NOTIFICATION_STREAM_CREATED         @"tok_stream_created"
#define TWIC_NOTIFICATION_STREAM_DESTROYED       @"tok_stream_destroyed"
#define TWIC_NOTIFICATION_TOUCH_PUBLISHED_STREAM @"tok_touch_publised_stream"
//TOK
#define TOK_API_KEY @"45720402"

#define TOK_SESSION_ID @"1_MX40NTcyMDQwMn5-MTQ5MTU1NzI2NzU1OH54Y0lZOXAzbDhOMnFIQUJISzE3Z29NTUZ-UH4"

//CROBERT
//#define TOK_TOKEN_ROBERT @"T1==cGFydG5lcl9pZD00NTcyMDQwMiZzaWc9MjRlOTAyZGZmNTliYjlkZTI0Y2JkNjE2MzMzNTE1MTJkMDdlMzY3ZTpzZXNzaW9uX2lkPTFfTVg0ME5UY3lNRFF3TW41LU1UUTRPREkzTkRjeU5UYzRNbjVTZEVwQldYRmtObVJGVHlzclptZzBZbkp3U25sbGJtaC1VSDQmY3JlYXRlX3RpbWU9MTQ5MTU1NjczOSZub25jZT0wLjAzODA1MTY4MDQxMjE4NjQzJnJvbGU9cHVibGlzaGVyJmV4cGlyZV90aW1lPTE0OTQxNDg3MzYmY29ubmVjdGlvbl9kYXRhPSU3QiUyMmlkJTIyJTNBMSU3RA=="
//PAUL
#define TOK_TOKEN_PAUL @"T1==cGFydG5lcl9pZD00NTcyMDQwMiZzaWc9YTU2MzQxYmUxMTIzMzY2NWQxMjg5OTMxMDllMWFkMGM4YzZhODI1ZTpzZXNzaW9uX2lkPTFfTVg0ME5UY3lNRFF3TW41LU1UUTVNVFUxTnpJMk56VTFPSDU0WTBsWk9YQXpiRGhPTW5GSVFVSklTekUzWjI5TlRVWi1VSDQmY3JlYXRlX3RpbWU9MTQ5MTU1NzI2NyZyb2xlPXB1Ymxpc2hlciZub25jZT0xNDkxNTU3MjY3Ljg2MTEyMTM4MDUyNTI4JmV4cGlyZV90aW1lPTE0OTQxNDkyNjcmY29ubmVjdGlvbl9kYXRhPSU3QiUyMmlkJTIyJTNBMSU3RA=="

#endif /* TWICConstants_h */
