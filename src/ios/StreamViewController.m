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
    @property (strong, nonatomic) OTSession* session;
    @property (strong, nonatomic) OTPublisher* publisher;
    @property (strong, nonatomic) OTSubscriber* subscriber;
@end

@implementation StreamViewController

static double widgetHeight = 240;
static double widgetWidth = 320;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
     {
         if(granted){
             _session = [[OTSession alloc] initWithApiKey:API_KEY
                                                sessionId:SESSION_ID
                                                 delegate:self];
             [_session connectWithToken:TOKEN error:nil];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:@"Authorization failed"];
         }
     }];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//connected to the session
- (void)sessionDidConnect:(OTSession*)session
{
    if (session.capabilities.canPublish) {
//        self.publisher = [[OTPublisher alloc] initWithDelegate:self];
//        [session publish:self.publisher error:nil];
//        [self.publisher.view setFrame:CGRectMake(10, 20, 175, 175)];
//        [self.view addSubview:self.publisher.view];
    } else {
        [SVProgressHUD showErrorWithStatus:@"CANNOT PUBLISH !"];
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
    [subscriber.view setFrame:CGRectMake(10, 200, 175, 175)];
    [self.view addSubview:subscriber.view];
}

- (void)session:(OTSession*)session streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([self.subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [_subscriber.view removeFromSuperview];
        _subscriber = nil;
    }
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSLog(@"Session disconnected");
}

- (void) session:(OTSession*)session didFailWithError:(OTError*)error
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
