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
    [[TWICPlatformClient sharedInstance]handgoutDataWithCompletionBlock:^(NSDictionary *data)
    {
        
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
