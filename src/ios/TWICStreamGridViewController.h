//
//  StreamGridViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>


@protocol TWICStreamGridViewControllerDelegate <NSObject>

-(void)TWICStreamGridViewController:(id)sender didSelectUser:(NSDictionary *)user;

@end


@interface TWICStreamGridViewController : UIViewController
@property(nonatomic, weak)id<TWICStreamGridViewControllerDelegate>delegate;

-(void)configureWithUsers:(NSArray *)users;
@end
