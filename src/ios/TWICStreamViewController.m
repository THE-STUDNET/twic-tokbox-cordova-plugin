//
//  StreamViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 09/03/2017.
//
//

#import "TWICStreamViewController.h"
#import <OpenTok/OpenTok.h>
#import "TWICTokClient.h"
#import "Masonry.h"

@interface TWICStreamViewController ()<OTSubscriberKitDelegate, OTPublisherDelegate>
//TokBox
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;


@property (nonatomic, assign) BOOL isConnecting;
@end

@implementation TWICStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TWIC_COLOR_GREY;
}

-(void)configureWithStream:(OTStream *)stream
{
    self.stream = stream;
}

-(void)connectStream
{
    //subscribe to the stream
    self.subscriber = [[OTSubscriber alloc] initWithStream:self.stream delegate:self];
    //add the subriber to the session
    [[TWICTokClient sharedInstance].session subscribe:self.subscriber error:nil];
}

-(void)disconnect;
{
    //remove the stream from the session
    if(self.subscriber)
    {
        [[TWICTokClient sharedInstance].session unsubscribe:self.subscriber error:nil];
        [self.subscriber.view removeFromSuperview];
        self.subscriber.delegate = nil;
        self.subscriber = nil;
    }
    
    if(self.publisher){
        [[TWICTokClient sharedInstance].session unpublish:self.publisher error:nil];
        [self.publisher.view removeFromSuperview];
        self.publisher.delegate = nil;
        self.publisher = nil;
    }
}

- (void)startPublishing
{
    //authorize capture
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted)
     {
         if(granted)
         {
             if ([TWICTokClient sharedInstance].session.capabilities.canPublish)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                    {
                        self.publisher = [[OTPublisher alloc] initWithDelegate:self];
                        UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(publisherTouched:)];
                        [self.publisher.view addGestureRecognizer:tapAction];
                        [self.publisher setPublishAudio:YES];
                        [self.publisher setPublishVideo:YES];
                        self.publisher.view.clipsToBounds = YES;
                        [self.view addSubview:self.publisher.view];
                        [self.publisher.view mas_makeConstraints:^(MASConstraintMaker *make)
                         {
                             make.top.equalTo(self.view.mas_top);
                             make.bottom.equalTo(self.view.mas_bottom);
                             make.left.equalTo(self.view.mas_left);
                             make.right.equalTo(self.view.mas_right);
                         }];
                        [[TWICTokClient sharedInstance].session publish:self.publisher error:nil];
                    });
             }
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:@"iOS Authorization failed"];
         }
     }];
}


#pragma mark - Stream callbacks
//did connect to a stream
- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    [subscriber.view setFrame:self.view.bounds];
    [self.view insertSubview:subscriber.view atIndex:0];
}

- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
}
- (void)subscriber:(OTSubscriberKit*)subscriber didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@", subscriber.stream.streamId, error);
}

#pragma mark - View events

-(void)publisherTouched:(UIGestureRecognizer*)gesture{
    [NOTIFICATION_CENTER postNotificationName:TWIC_NOTIFICATION_TOUCH_PUBLISHED_STREAM object:self];
}
@end
