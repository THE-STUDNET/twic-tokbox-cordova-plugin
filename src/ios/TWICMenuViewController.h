//
//  TWICMenuViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>

@protocol TWICMenuViewControllerDelegate <NSObject>

-(void)TWICMenuViewController:(id)sender didSelectAction:(id)action forUser:(id)user;

@end

@interface TWICMenuViewController : UIViewController
@property(nonatomic, weak)id<TWICMenuViewControllerDelegate>delegate;
@property(nonatomic, assign) BOOL isAdmin;
@end
