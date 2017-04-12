//
//  StreamGridViewController.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>
#import "TWICConstants.h"
#import "TWICStreamViewController.h"

@protocol TWICStreamGridViewControllerDelegate <NSObject>

-(void)TWICStreamGridViewController:(id)sender didSelectStream:(OTStream *)stream;
-(void)TWICStreamGridViewControllerDidSelectPublisherStream:(id)sender;

@end


@interface TWICStreamGridViewController : UIViewController
@property(nonatomic, weak)id<TWICStreamGridViewControllerDelegate>delegate;

-(void)addStreams:(NSMutableArray*)streams;
-(void)addStream:(OTStream*)stream;
-(void)removeStream:(OTStream*)stream;
-(void)removeAllStreams;
@end
