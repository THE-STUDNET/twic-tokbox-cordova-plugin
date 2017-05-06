//
//  TWICUserActionsViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 07/04/2017.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CurrentUserActionTypeMicrophone,
    CurrentUserActionTypeCamera,
    CurrentUserActionTypeRotate,
    CurrentUserActionTypeStop
} CurrentUserActionType;


@protocol TWICUserActionsViewControllerDelegate <NSObject>

-(void)TWICUserActionsViewController:(id)sender didTouchAction:(CurrentUserActionType)actionType;

@end

@interface TWICUserActionsViewController : UIViewController

@property(nonatomic, assign)id<TWICUserActionsViewControllerDelegate>delegate;

@end
