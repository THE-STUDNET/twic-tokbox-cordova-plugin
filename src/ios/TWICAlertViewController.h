//
//  TWICAlertViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 03/05/2017.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TWICAlertViewStyleMicrophone,
    TWICAlertViewStyleCamera,
    TWICAlertViewStyleScreen,
} TWICAlertViewStyle;

@protocol TWICAlertViewControllerDelegate <NSObject>

-(void)twicAlertViewControllerDidAccept:(id)sender;
-(void)twicAlertViewControllerDidCancel:(id)sender;

@end

@interface TWICAlertViewController : UIViewController

@property(nonatomic, weak) id<TWICAlertViewControllerDelegate> delegate;

-(void)configureWithAuthorization:(NSDictionary *)authorizationData;


@property(readonly)TWICAlertViewStyle style;
@property (readonly) NSDictionary *user;
@property(readonly) NSDictionary *authorizationData;
@end
