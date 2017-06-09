//
//  TWICChatTableViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 08/06/2017.
//
//

#import <UIKit/UIKit.h>
#import "TWICSocketIOClient.h"

@interface TWICChatTableViewController : UITableViewController<TWICSocketIOClientDelegate>

-(void)configureWithMessages:(NSArray*)messages;

@end
