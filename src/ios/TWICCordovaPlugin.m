#import "TWICCordovaPlugin.h"
#import <Cordova/CDV.h>
#import "TWICConstants.h"

#import "TWICMainViewController.h"
#import "TWICFirebaseClient.h"
#import "TWICSocketIOClient.h"
#import "TWICSettingsManager.h"
#import "TWICAPIClient.h"
#import "TWICUserManager.h"
#import "TWICHangoutManager.h"

@interface TWICCordovaPlugin()<TWICSocketIOClientDelegate>

@end

@implementation TWICCordovaPlugin

- (void)launchHangout:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if (command.arguments.count == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
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
    }
    else
    {
        [[TWICSettingsManager  sharedInstance] configureWithDefaultSettings];
    }
    
    //retrieve hangoud data
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[TWICHangoutManager sharedInstance] configureHangoutDataWithCompletionBlock:^
    {
        [[TWICUserManager sharedInstance]configureWithUserIds:[TWICHangoutManager sharedInstance].hangoutData[@"users"]
                                              completionBlock:^
         {
             [SVProgressHUD dismiss];
             [self launchMainViewController];
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

    //firebase configuration
    //[[TWICFirebaseClient sharedInstance] configure];
    //[[TWICFirebaseClient sharedInstance] writeStringValue:[NSString stringWithFormat:@"Hello world from iOS %@",[NSDate date]]];

    //socketio
    //[TWICSocketIOClient sharedInstance].delegate = self;
    //[[TWICSocketIOClient sharedInstance]connect];
}

-(void)launchMainViewController{
    //main
    UINavigationController *vc = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Navigation%@",[TWICMainViewController description]]];
    [self.viewController presentViewController:vc animated:YES completion:nil];
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
