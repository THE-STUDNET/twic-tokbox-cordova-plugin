#import "TWICCordovaPlugin.h"
#import <Cordova/CDV.h>
#import "SVProgressHUD.h"


#import "StreamViewController.h"
#import "TWICFirebaseClient.h"
#import "TWICSocketIOClient.h"

@interface TWICCordovaPlugin()

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
    
    //otsession
    StreamViewController *streamViewController = [[StreamViewController alloc]initWithNibName:[StreamViewController description] bundle:nil];
    [self.viewController presentViewController:streamViewController animated:YES completion:nil];
    
    //firebase configuration
    [[TWICFirebaseClient sharedInstance] configure];
    [[TWICFirebaseClient sharedInstance] writeStringValue:[NSString stringWithFormat:@"Hello world from iOS %@",[NSDate date]]];
    
    //socketio
    [[TWICSocketIOClient sharedInstance]connect];
}

- (void)configure:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}
@end
