#import "TWICCordovaPlugin.h"
#import <Cordova/CDV.h>
#import "TWICConstants.h"

#import "TWICMainViewController.h"
#import "TWICFirebaseClient.h"
#import "TWICSocketIOClient.h"

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
    
    //main
    UINavigationController *vc = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Navigation%@",[TWICMainViewController description]]];
    [self.viewController presentViewController:vc animated:YES completion:nil];
    
    //firebase configuration
    [[TWICFirebaseClient sharedInstance] configure];
    [[TWICFirebaseClient sharedInstance] writeStringValue:[NSString stringWithFormat:@"Hello world from iOS %@",[NSDate date]]];
    
    //socketio
    [TWICSocketIOClient sharedInstance].delegate = self;
    [[TWICSocketIOClient sharedInstance]connect];
}

- (void)configure:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

-(void)twicSocketIOClient:(id)sender didReceiveMessage:(NSDictionary *)messageObject{
    [SVProgressHUD setMaximumDismissTimeInterval:3];
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",messageObject]];
}
@end
