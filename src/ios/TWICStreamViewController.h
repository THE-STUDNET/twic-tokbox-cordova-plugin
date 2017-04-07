//
//  StreamViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 09/03/2017.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TWICStreamDisplayFullScreen,
    TWICStreamDisplayGrid,
} TWICStreamDisplay;


@protocol TWICStreamViewControllerDelegate <NSObject>

-(void)TWICStreamViewControllerDidTouchPublishedStream:(id)sender;

@end
@interface TWICStreamViewController : UIViewController
//configure
-(void)configureWithUser:(id)data twicStreamDisplay:(TWICStreamDisplay)streamDisplay;
//actions
-(void)disconnectSession;
-(void)stopPublishing;
//delegate
@property (nonatomic, weak)id<TWICStreamViewControllerDelegate>delegate;
@end
