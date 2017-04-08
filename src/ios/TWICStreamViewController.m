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
#import "TWICUserActionsViewController.h"


#define PUBLISHER_VIEW_FRAME_WIDTH      120
#define PUBLISHER_VIEW_FRAME_HEIGHT     140
#define PUBLISHER_VIEW_FRAME_DEFAULT_Y  10
#define PUBLISHER_VIEW_FRAME_DEFAULT_X  10

@interface TWICStreamViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate,TWICUserActionsViewControllerDelegate>
//TokBox
@property (strong, nonatomic) OTSession* session;
@property (strong, nonatomic) OTPublisher* publisher;
@property (strong, nonatomic) OTSubscriber* subscriber;

@property (nonatomic, assign) TWICStreamDisplay streamDisplay;
@property (nonatomic, strong) GRKBlurView *blurView;
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) TWICUserActionsViewController *userActionsViewController;
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
#pragma mark - Session callbacks

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
    if(self.subscriber)
    {
        [self.subscriber.view removeFromSuperview];
        self.subscriber = nil;
    }
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

#pragma mark - View events

-(void)publisherTouched:(UIGestureRecognizer*)gesture{
    if(self.delegate){
        [self.delegate TWICStreamViewControllerDidTouchPublishedStream:self];
    }

    //configure action view
    [self addActionsView];
}

-(void)addActionsView{
    
    if(self.userActionsViewController)//already presented !
        return;
    //actions
    self.userActionsViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICUserActionsViewController description]];
    self.userActionsViewController.delegate = self;
    UPDATE_VIEW_FRAME_SIZE(self.userActionsViewController.view, CGSizeMake(300*MAIN_SCREEN.bounds.size.width/414, 260*MAIN_SCREEN.bounds.size.height/736));
    self.userActionsViewController.view.clipsToBounds = YES;
    self.userActionsViewController.view.layer.cornerRadius = TWIC_CORNER_RADIUS;
    self.userActionsViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [self.view addSubview:self.userActionsViewController.view];
    self.userActionsViewController.view.center = self.view.center;
    [self.userActionsViewController didMoveToParentViewController:self];
    [self addChildViewController:self.userActionsViewController];
    
    //blur
    self.blurView  = [[GRKBlurView alloc]initWithFrame:self.subscriber.view.frame];
    self.blurView.alpha = 0;
    [self.blurView setTargetImageFromView:self.subscriber.view];
    self.blurView.blurRadius = 30.0f;
    [self.subscriber.view addSubview:self.blurView];
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurviewTouched:)];
    [self.blurView addGestureRecognizer:tapAction];
    
    //animate the display !
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.userActionsViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        self.blurView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.userActionsViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.userActionsViewController.view.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

-(void)TWICUserActionsViewController:(id)sender didTouchAction:(UserActionType)actionType
{
    //do something with the action !
    [self removeActionView];
}

-(void)blurviewTouched:(UIGestureRecognizer*)gesture{
    [self removeActionView];
}

-(void)removeActionView{
    [UIView animateWithDuration:0.3f animations:^
     {
         self.userActionsViewController.view.alpha = 0;
         self.blurView.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [self.userActionsViewController.view removeFromSuperview];
         self.userActionsViewController = nil;
         [self.blurView removeFromSuperview];
         self.blurView = nil;
     }];
}
@end
