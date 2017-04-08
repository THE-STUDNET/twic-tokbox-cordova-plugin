//
//  TWICUserActionsViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 07/04/2017.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UserActionTypeMicrophone,
    UserActionTypeCamera,
    UserActionTypeRotate,
    UserActionTypeStop
} UserActionType;


@protocol TWICUserActionsViewControllerDelegate <NSObject>

-(void)TWICUserActionsViewController:(id)sender didTouchAction:(UserActionType)actionType;

@end

@interface TWICUserActionsViewController : UIViewController

@property(nonatomic, assign)id<TWICUserActionsViewControllerDelegate>delegate;

@end
