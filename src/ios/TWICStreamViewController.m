//
//  StreamViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 09/03/2017.
//
//

#import "TWICStreamViewController.h"
#import "TWICConstants.h"
#import <OpenTok/OpenTok.h>

@interface TWICStreamViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
//TokBox
@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;

@property (nonatomic, assign) TWICStreamDisplay streamDisplay;
@end

@implementation TWICStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TWIC_COLOR_GREY;
}

-(void)configureWithUser:(id)data twicStreamDisplay:(TWICStreamDisplay)streamDisplay
{
    self.streamDisplay = streamDisplay;
}

-(void)dealloc{
    if(self.streamDisplay == TWICStreamDisplayFullScreen){
        [self stopPublishing];
    }
    [self disconnectSession];
}
#pragma mark - Actions
- (void)connectSession {
    _session = [[OTSession alloc] initWithApiKey:TOK_API_KEY sessionId:TOK_SESSION_ID delegate:self];
    [_session connectWithToken:TOK_TOKEN error:nil];
}

- (void)disconnectSession
{
    NSError *error=nil;
    [self.session disconnect:&error];
    if(error){
        [SVProgressHUD showWithStatus:error.localizedDescription];
    }
}

- (void)stopPublishing
{
    NSError *error;
    [self.session unpublish:self.publisher error:&error];
    if(error){
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

- (void)startPublishing
{
    NSError *error;
    [self.session publish:self.publisher error:&error];
    if(error){
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

#pragma mark - OTSession Callbacks
//connected to the session
- (void)sessionDidConnect:(OTSession*)session
{
    self.session = session;
    
    if(self.streamDisplay == TWICStreamDisplayFullScreen)//add a publisher
    {
        //authorize capture
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 if (self.session.capabilities.canPublish)
                 {
                     self.publisher = [[OTPublisher alloc] initWithDelegate:self];
                     [self.publisher.view setFrame:CGRectMake(10, 10, 120, 120)];
                     self.publisher.view.layer.borderColor = [UIColor whiteColor].CGColor;
                     self.publisher.view.layer.cornerRadius = 5.0f;
                     self.publisher.view.layer.borderWidth = 1.0f;
                     self.publisher.view.clipsToBounds = YES;
                     [self.publisher setPublishAudio:YES];
                     [self.publisher setPublishVideo:YES];
                     [self.view addSubview:self.publisher.view];
                 }
                 else
                 {
                     [SVProgressHUD showErrorWithStatus:@"Can't publish"];
                 }
             }
             else
             {
                 [SVProgressHUD showErrorWithStatus:@"Authorization failed"];
             }
         }];
    }
}

//new ststream created
- (void)session:(OTSession*)session streamCreated:(OTStream*)stream
{
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    [session subscribe:self.subscriber error:nil];
}

//did connect to a stream
- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    [subscriber.view setFrame:self.view.bounds];
    [self.view insertSubview:subscriber.view atIndex:0];
}

- (void)session:(OTSession*)session streamDestroyed:(OTStream *)stream
{
    if ([self.subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
    }
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    [self.publisher.view removeFromSuperview];
    self.publisher = nil;
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}
- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
}
- (void)subscriber:(OTSubscriberKit*)subscriber didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@", subscriber.stream.streamId, error);
}
@end
