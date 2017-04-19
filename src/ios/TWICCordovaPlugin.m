#import "TWICCordovaPlugin.h"
#import <Cordova/CDV.h>
#import "TWICConstants.h"

#import "TWICMainViewController.h"
#import "TWICFirebaseClient.h"
#import "TWICSocketIOClient.h"
#import "TWICSettingsManager.h"
#import "TWICPlatformClient.h"

@interface TWICCordovaPlugin()<TWICSocketIOClientDelegate>

@end

@implementation TWICCordovaPlugin

- (void)launchHangout:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* msg = [command.arguments objectAtIndex:0];
    if (msg == nil || [msg length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsString:msg];
    }
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];

    //settings
    if(command.arguments.count > 0)
    {
        NSData *argumentsData = [[command.arguments firstObject] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonArguments = [NSJSONSerialization JSONObjectWithData:argumentsData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
        if(error){
            NSLog(@"%@",error);
        }
        [[TWICSettingsManager  sharedInstance] configureWithSettings:jsonArguments];
    }else{
        [[TWICSettingsManager  sharedInstance] configureWithDefaultSettings];
    }
    
    
    //main
    UINavigationController *vc = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Navigation%@",[TWICMainViewController description]]];
    [self.viewController presentViewController:vc animated:YES completion:nil];

    //firebase configuration
    //[[TWICFirebaseClient sharedInstance] configure];
    //[[TWICFirebaseClient sharedInstance] writeStringValue:[NSString stringWithFormat:@"Hello world from iOS %@",[NSDate date]]];

    //socketio
    //[TWICSocketIOClient sharedInstance].delegate = self;
    //[[TWICSocketIOClient sharedInstance]connect];
    
    //twic platform
    [[TWICPlatformClient sharedInstance]hangoutDataWithCompletionBlock:^(NSDictionary *data)
    {
        [[TWICPlatformClient sharedInstance] detailForUsers:data[@"users"]
                                            completionBlock:^(NSArray *data)
        {
            
        }
                                               failureBlock:^(NSError *error)
        {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    }
                                                           failureBlock:^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
    [[TWICPlatformClient sharedInstance]tokboxDataWithCompletionBlock:^(NSDictionary *data)
     {
/*
 session = "1_MX40NTcyMDQwMn5-MTQ5MjYxNzQ0MjQ0Mn4vZlNNY2NRM1QvWWNCNFg0a2pwaEhOSW5-UH4";
 token = "T1==cGFydG5lcl9pZD00NTcyMDQwMiZzaWc9MTEwNGQ5MTk5OTlmYWQ0YTc5M2Q1NGViZjVmZWZmZTNmNTcxMTU0ZDpzZXNzaW9uX2lkPTFfTVg0ME5UY3lNRFF3TW41LU1UUTVNall4TnpRME1qUTBNbjR2WmxOTlkyTlJNMVF2V1dOQ05GZzBhMnB3YUVoT1NXNS1VSDQmY3JlYXRlX3RpbWU9MTQ5MjYyMDU0MCZyb2xlPW1vZGVyYXRvciZub25jZT0xNDkyNjIwNTQwLjg2MTExOTcxMTgwOTUxJmV4cGlyZV90aW1lPTE0OTUyMTI1NDAmY29ubmVjdGlvbl9kYXRhPSU3QiUyMmlkJTIyJTNBNiU3RA==";
 */
     }
                                                          failureBlock:^(NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:error.localizedDescription];
     }];
}

- (void)configure:(CDVInvokedUrlCommand*)command
{
  [self launchHangout:command];
}

-(void)twicSocketIOClient:(id)sender didReceiveMessage:(NSDictionary *)messageObject{
    [SVProgressHUD setMaximumDismissTimeInterval:3];
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",messageObject]];
}
@end
