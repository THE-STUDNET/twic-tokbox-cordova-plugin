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
#import "GRKBlurView.h"


#define PUBLISHER_VIEW_FRAME_WIDTH      120
#define PUBLISHER_VIEW_FRAME_HEIGHT     140
#define PUBLISHER_VIEW_FRAME_DEFAULT_Y  10
#define PUBLISHER_VIEW_FRAME_DEFAULT_X  10

@interface TWICStreamViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
//TokBox
@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;

@property (nonatomic, assign) TWICStreamDisplay streamDisplay;
@property (nonatomic, strong) GRKBlurView *blurView;
@property (nonatomic, strong) NSDictionary *user;
@end

@implementation TWICStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TWIC_COLOR_GREY;
}

-(void)configureWithUser:(NSDictionary *)user twicStreamDisplay:(TWICStreamDisplay)streamDisplay
{
    self.streamDisplay = streamDisplay;
    self.user = user;
    [self connectSession];
}

-(void)dealloc{
    if(self.streamDisplay == TWICStreamDisplayFullScreen){
        [self stopPublishing];
    }
    [self disconnectSession];
}
#pragma mark - Actions
- (void)connectSession {
    _session = [[OTSession alloc] initWithApiKey:TOK_API_KEY
                                       sessionId:TOK_SESSION_ID
                                        delegate:self];
    [_session connectWithToken:self.user[TWIC_USER_TOK_TOKEN] error:nil];
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
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.publisher = [[OTPublisher alloc] initWithDelegate:self];
                         [self.publisher.view setFrame:CGRectMake(MAIN_SCREEN.bounds.size.width - PUBLISHER_VIEW_FRAME_WIDTH - PUBLISHER_VIEW_FRAME_DEFAULT_X, PUBLISHER_VIEW_FRAME_DEFAULT_Y, PUBLISHER_VIEW_FRAME_WIDTH, PUBLISHER_VIEW_FRAME_HEIGHT)];
                         self.publisher.view.layer.borderColor = [UIColor whiteColor].CGColor;
                         self.publisher.view.layer.cornerRadius = 5.0f;
                         self.publisher.view.layer.borderWidth = 1.0f;
                         self.publisher.view.clipsToBounds = YES;
                         UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(publisherTouched:)];
                         [self.publisher.view addGestureRecognizer:tapAction];
                         [self.publisher setPublishAudio:YES];
                         [self.publisher setPublishVideo:YES];
                         [self.view addSubview:self.publisher.view];
                     });
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

-(void)publisherTouched:(UIGestureRecognizer*)gesture{
    if(self.delegate){
        [self.delegate TWICStreamViewControllerDidTouchPublishedStream:self];
    }
    //add blur view
    [self addBlurView];
    
    //configure action view
    
}

-(void)addBlurView{
    if(self.blurView){
        [self.blurView removeFromSuperview];
        self.blurView = nil;
    }
    self.blurView  = [[GRKBlurView alloc]initWithFrame:self.subscriber.view.frame];
    [self.blurView setTargetImageFromView:self.subscriber.view];
    self.blurView.blurRadius = 30.0f;
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurviewTouched:)];
    [self.publisher.view addGestureRecognizer:tapAction];
    [self.subscriber.view addSubview:self.blurView];
}

-(void)blurviewTouched:(UIGestureRecognizer*)gesture{
    [self.blurView removeFromSuperview];
    self.blurView = nil;
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
//animation
//
//-(void)openActionView{
//UIWindow* mainWindow = [APPLICATION keyWindow];
//self.progressVC.view.frame = CGRectMake(0, 0, mainWindow.bounds.size.width/1.05, mainWindow.bounds.size.height/1.05);
//self.progressVC.view.layer.cornerRadius = IMAGE_CORNER_RADIUS;
//self.progressVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
//self.progressVC.view.center = mainWindow.center;
//[mainWindow addSubview:self.progressVC.view];
//[UIView animateWithDuration:0.3/1.5 animations:^{
//    self.progressVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
//} completion:^(BOOL finished) {
//    [UIView animateWithDuration:0.3/2 animations:^{
//        self.progressVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.3/2 animations:^{
//            self.progressVC.view.transform = CGAffineTransformIdentity;
//        }];
//    }];
//}];
//
//[self addChildViewController:self.progressVC];
//[self.progressVC didMoveToParentViewController:self];
//}
//
//#pragma mark - Intervention progress delegate
//-(void)interventionInProgressViewControllerDidClose:(id)sender{
//    WEAKSELF;
//    [UIView animateWithDuration:0.3f animations:^
//     {
//         weakSelf.progressVC.view.alpha = 0;
//     }
//                     completion:^(BOOL finished)
//     {
//         [weakSelf.progressVC.view removeFromSuperview];
//         weakSelf.progressVC = nil;
//         
//         //check state
//         if([weakSelf.intervention.in_status isEqualToString:InterventionStatusConfirmed]){
//             //open score view
//             [weakSelf score:nil];
//         }
//     }];
//}


@end
