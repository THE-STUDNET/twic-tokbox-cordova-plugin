//
//  StreamViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 09/03/2017.
//
//

#import <UIKit/UIKit.h>
#import "TWICConstants.h"

@interface TWICStreamViewController : UIViewController

@property (nonatomic, strong) OTStream *stream;

//configure
-(void)configureWithStream:(OTStream*)stream;

-(void)disconnect;
-(void)connectStream;
-(void)startPublishing;
@end
