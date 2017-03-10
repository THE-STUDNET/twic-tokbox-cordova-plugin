//
//  StreamViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 09/03/2017.
//
//

#import "StreamViewController.h"
#import "SVProgressHUD.h"
#import <OpenTok/OpenTok.h>

#define API_KEY @"45720402"
#define SESSION_ID @"1_MX40NTcyMDQwMn5-MTQ4ODI3NDcyNTc4Mn5SdEpBWXFkNmRFTysrZmg0YnJwSnllbmh-UH4"
#define TOKEN @"T1==cGFydG5lcl9pZD00NTcyMDQwMiZzaWc9MmM4YTkyMDFhMzMwYzkyM2JiMzc4ZjUzMjJlNzZhNDY4ODZmM2I0YjpzZXNzaW9uX2lkPTFfTVg0ME5UY3lNRFF3TW41LU1UUTRPREkzTkRjeU5UYzRNbjVTZEVwQldYRmtObVJGVHlzclptZzBZbkp3U25sbGJtaC1VSDQmY3JlYXRlX3RpbWU9MTQ4ODI3NDcyNiZyb2xlPW1vZGVyYXRvciZub25jZT0xNDg4Mjc0NzI2LjAxNzQxNzQ4NjU1MzI1JmV4cGlyZV90aW1lPTE0OTA4NjY3MjYmY29ubmVjdGlvbl9kYXRhPSU3QiUyMmlkJTIyJTNBMSU3RA=="

@interface StreamViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
//outlets
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *actionButtons;
@property (weak, nonatomic) IBOutlet UIButton *connectSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UIButton *stopPublishingButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectSession;
//TokBox
@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;
@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //buttons
    [_actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.layer.cornerRadius = 5;
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.alpha = .5;
    }];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//connected to the session
- (void)sessionDidConnect:(OTSession*)session
{
    self.session = session;
    
    //authorize capture
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
     {
         if(granted){
             if (self.session.capabilities.canPublish)
             {
                 self.startPublishingButton.enabled = YES;
                 self.stopPublishingButton.enabled = YES;
                 
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

#pragma mark - Actions

- (IBAction)connectSession:(id)sender {
    _session = [[OTSession alloc] initWithApiKey:API_KEY
                                       sessionId:SESSION_ID
                                        delegate:self];
    [_session connectWithToken:TOKEN error:nil];
    
}

- (IBAction)disconnectSession:(id)sender {
    NSError *error=nil;
    [self.session disconnect:&error];
    if(error){
        [SVProgressHUD showWithStatus:error.localizedDescription];
    }
}

- (IBAction)stopPublishing:(id)sender {
    NSError *error;
    [self.session unpublish:self.publisher error:&error];
    if(error){
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

- (IBAction)startPublishing:(id)sender
{
    NSError *error;
    [self.session publish:self.publisher error:&error];
    if(error){
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}



@end
