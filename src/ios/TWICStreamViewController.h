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

@interface TWICStreamViewController : UIViewController

-(void)configureWithUser:(id)data twicStreamDisplay:(TWICStreamDisplay)streamDisplay;

-(void)connectSession;
-(void)disconnectSession;
-(void)startPublishing;
-(void)stopPublishing;
@end
