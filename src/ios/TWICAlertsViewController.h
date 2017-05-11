//
//  TWICAlertsViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 11/05/2017.
//
//

#import <UIKit/UIKit.h>

@protocol TWICAlertsViewControllerDelegate <NSObject>

-(void)twicAlertViewControllerDidFinish:(id)sender;

@end

@interface TWICAlertsViewController : UIViewController

@property (nonatomic, weak) id<TWICAlertsViewControllerDelegate> delegate;

@end
