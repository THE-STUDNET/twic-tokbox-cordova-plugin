//
//  StreamGridViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>
#import "TWICConstants.h"

@protocol TWICStreamGridViewControllerDelegate <NSObject>

-(void)TWICStreamGridViewController:(id)sender didSelectSubscriberConnectionID:(NSString *)subscriberConnectionID;
-(void)TWICStreamGridViewControllerDidSelectPublisher:(id)sender;

@end


@interface TWICStreamGridViewController : UIViewController
@property(nonatomic, weak)id<TWICStreamGridViewControllerDelegate>delegate;
-(void)refresh;
@end
