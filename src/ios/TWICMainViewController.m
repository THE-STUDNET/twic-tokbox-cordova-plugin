//
//  TWICMainViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICMainViewController.h"
#import "TWICConstants.h"
#import "TWICMenuViewController.h"
#import "TWICStreamGridViewController.h"
#import "Masonry.h"
#import "TWICTokClient.h"
#import "GRKBlurView.h"
#import "TWICUserActionsViewController.h"
#import "TWICUserManager.h"
#import "TWICAPIClient.h"
#import "TWICAlertViewController.h"

#define PUBLISHER_VIEW_FRAME_WIDTH      120
#define PUBLISHER_VIEW_FRAME_HEIGHT     140
#define PUBLISHER_VIEW_FRAME_DEFAULT_Y  10
#define PUBLISHER_VIEW_FRAME_DEFAULT_X  -10

@interface TWICMainViewController ()<UITextFieldDelegate,TWICStreamGridViewControllerDelegate,TWICUserActionsViewControllerDelegate,TWICAlertViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *supportView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *numberUsersLabel;
@property (weak, nonatomic) IBOutlet UIButton *usersButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *speakingImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeakerDisplayName;


@property (nonatomic, strong)TWICStreamGridViewController *twicStreamGridViewController;
//@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, copy) NSString *currentSubcriberStreamID;
@property (nonatomic, assign) BOOL backButton;

@property (nonatomic, strong) GRKBlurView *blurView;
@property (nonatomic, strong) TWICUserActionsViewController *userActionsViewController;
@property (nonatomic, strong) TWICAlertViewController *alertViewController;
@property (nonatomic, strong) UIViewController *popupViewController;
@end

@implementation TWICMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sessionConnected:) name:TWIC_NOTIFICATION_SESSION_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sessionDisconnected:) name:TWIC_NOTIFICATION_SESSION_DISCONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(subscriberConnected:) name:TWIC_NOTIFICATION_SUBSCRIBER_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(subscriberDisconnected:) name:TWIC_NOTIFICATION_SUBSCRIBER_DISCONNECTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userConnected:) name:TWIC_NOTIFICATION_USER_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userDisconnected:) name:TWIC_NOTIFICATION_USER_DISCONNECTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(currentUserCameraRequested:) name:NOTIFICATION_USER_CAMERA_REQUESTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(currentUserMicrophoneRequested:) name:NOTIFICATION_USER_MICROPHONE_REQUESTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userAskMicrophoneAuthorization:) name:NOTIFICATION_USER_ASK_MICROPHONE_AUTHORIZATION object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userAskCameraAuthorization:) name:NOTIFICATION_USER_ASK_CAMERA_AUTHORIZATION object:nil];
    
    [self configureSkin];
    [self configureLocalizable];
    [self refreshUI];
    
    //connect the session
    [[TWICTokClient sharedInstance] connect];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Skining

-(void)configureLocalizable{
    self.messageTextField.text = @"Type your message";
}

-(void)configureSkin{
    self.headerView.backgroundColor = CLEAR_COLOR;
    self.footerView.backgroundColor = CLEAR_COLOR;
    self.recordButton.backgroundColor = CLEAR_COLOR;
    self.numberUsersLabel.textColor = [UIColor whiteColor];
    self.messageTextField.textColor = [UIColor whiteColor];
    
    UIView *insetView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.messageTextField.bounds.size.height)];
    insetView.backgroundColor = CLEAR_COLOR;
    self.messageTextField.leftView = insetView;
    self.messageTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.disconnectButton.tintColor = [UIColor whiteColor];
    self.usersButton.tintColor = [UIColor whiteColor];
    self.sendButton.tintColor = [UIColor whiteColor];
    
    [self configureView:self.disconnectButton];
    [self configureView:self.usersButton];
    [self configureView:self.sendButton];
    [self configureView:self.messageTextField];
    
    self.currentSpeakerDisplayName.textColor = [UIColor whiteColor];
    self.currentSpeakerDisplayName.alpha = TWIC_ALPHA;
    self.currentSpeakerDisplayName.hidden = YES;
    self.speakingImageView.hidden = YES;
}

-(void)configureView:(UIView*)view{
    view.backgroundColor = [UIColor blackColor];
    view.alpha = TWIC_ALPHA;
    view.layer.cornerRadius = TWIC_CORNER_RADIUS;
    view.clipsToBounds = YES;
}

-(void)refreshUI{
    self.numberUsersLabel.text = [NSString stringWithFormat:@"%d",(int)[TWICUserManager sharedInstance].usersCount - 1];
}

-(void)presentFullScreenSubscriberWithID:(NSString *)subscriberID{
    //store the current subscriber id
    self.currentSubcriberStreamID = subscriberID;
    
    //add subscriber view
    OTSubscriber *subscriber = [[TWICTokClient sharedInstance] subscriberForStreamID:subscriberID];
    [self.supportView addSubview:subscriber.view];
    [subscriber.view mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.supportView.mas_top);
         make.bottom.equalTo(self.supportView.mas_bottom);
         make.left.equalTo(self.supportView.mas_left);
         make.right.equalTo(self.supportView.mas_right);
     }];
    
    //add publisher view
    [self addPublisherView];
}

-(void)addPublisherView{
    if([TWICTokClient sharedInstance].publisher)
    {
        [self.supportView addSubview:[TWICTokClient sharedInstance].publisher.view];
        [[TWICTokClient sharedInstance].publisher.view mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(self.supportView.mas_top).offset(PUBLISHER_VIEW_FRAME_DEFAULT_Y);
             make.right.equalTo(self.supportView.mas_right).offset(PUBLISHER_VIEW_FRAME_DEFAULT_X);
             make.width.mas_equalTo(PUBLISHER_VIEW_FRAME_WIDTH);
             make.height.mas_equalTo(PUBLISHER_VIEW_FRAME_HEIGHT);
         }];

        [TWICTokClient sharedInstance].publisher.view.layer.borderColor = [UIColor whiteColor].CGColor;
        [TWICTokClient sharedInstance].publisher.view.layer.cornerRadius = 5.0f;
        [TWICTokClient sharedInstance].publisher.view.layer.borderWidth = 1.0f;
        [TWICTokClient sharedInstance].publisher.view.clipsToBounds = YES;
        UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(publisherTouched:)];
        [[TWICTokClient sharedInstance].publisher.view addGestureRecognizer:tapAction];
    }
}

-(void)publisherTouched:(UIGestureRecognizer *)recognizer{
    //add actions view
    [self addActionsView];
}

-(void)addStreamGridViewController
{
    self.twicStreamGridViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamGridViewController description]];
    self.twicStreamGridViewController.delegate = self;
    [self.supportView addSubview:self.twicStreamGridViewController.view];
    [self.twicStreamGridViewController.view mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self.supportView.mas_top);
         make.bottom.equalTo(self.supportView.mas_bottom);
         make.left.equalTo(self.supportView.mas_left);
         make.right.equalTo(self.supportView.mas_right);
     }];
    [super addChildViewController:self.twicStreamGridViewController];
    [self.twicStreamGridViewController didMoveToParentViewController:self];
}

#pragma mark - Keyboard Management
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    self.bottomConstraint.constant = 0;
}

#pragma mark - Buttons Management
- (IBAction)send:(id)sender {
    [self.messageTextField resignFirstResponder];
    //need to send data
    self.messageTextField.text = @"Type your message";
}

- (IBAction)users:(id)sender {
    UINavigationController *navVC = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Navigation%@",[TWICMenuViewController description]]];
    TWICMenuViewController *vc = (TWICMenuViewController *)navVC.topViewController;
    vc.isAdmin = YES;
    [navVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];//hack mandatory !
    [self presentViewController:navVC animated:YES completion:nil];
}

- (IBAction)record:(id)sender {
    
}

- (IBAction)disconnect:(id)sender {
    if(self.backButton)
    {
        self.backButton = NO;

        //remove the current subscriber
        OTSubscriber *currentSubscriber = [[TWICTokClient sharedInstance] subscriberForStreamID:self.currentSubcriberStreamID];
        [currentSubscriber.view removeFromSuperview];
        
        //remove the publisher view
        [[TWICTokClient sharedInstance].publisher.view removeFromSuperview];

        //add grid
        [self addStreamGridViewController];
    }
    else
    {
        //disconnect, register disconnect event
        [[TWICAPIClient sharedInstance]registerEventName:HangoutEventLeave completionBlock:^{} failureBlock:^(NSError *error) {}];
        
        //disconnect tokbox
        [[TWICTokClient sharedInstance]disconnect];
        
        //hide display
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - TokSession Management
-(void)sessionConnected:(NSNotification *)notification
{
    [self addStreamGridViewController];
}

-(void)sessionDisconnected:(NSNotification *)notification
{
    //disconnect
    [self.twicStreamGridViewController.view removeFromSuperview];
    [self.twicStreamGridViewController removeFromParentViewController];
    self.twicStreamGridViewController = nil;
}

#pragma mark - Tok Subscribers Management
-(void)subscriberConnected:(NSNotification *)notification{
    if(self.twicStreamGridViewController)
    {
        [self.twicStreamGridViewController refresh];
    }
}

-(void)subscriberDisconnected:(NSNotification *)notification{
    if(self.twicStreamGridViewController)
    {
        [self.twicStreamGridViewController refresh];
    }
    else
    {
        //check if it's the current stream ?
        OTSubscriber *subscriber = notification.object;
        if([subscriber.stream.streamId isEqualToString:self.currentSubcriberStreamID]){
            [self disconnect:nil];
        }
    }
}

#pragma mark - Tok Users Management
-(void)userConnected:(NSNotification *)notification{
    //update the number of connected users
    [self refreshUI];
}
-(void)userDisconnected:(NSNotification*)notification{
    //update the number of connected users
    [self refreshUI];
}

#pragma mark - TWICStreamGridViewController delegate

-(void)TWICStreamGridViewControllerDidSelectPublisher:(id)sender{
    [self addActionsView];
}

-(void)TWICStreamGridViewController:(id)sender didSelectSubscriberID:(NSString *)subscriberID
{
    [self.twicStreamGridViewController.view removeFromSuperview];
    self.twicStreamGridViewController = nil;
    
    //present the subscriber in fullscreen
    [self presentFullScreenSubscriberWithID:subscriberID];
    
    self.backButton = YES;
}

#pragma mark - Popup views management
-(void)showPopupView{
    UPDATE_VIEW_FRAME_SIZE(self.popupViewController.view, CGSizeMake(300*MAIN_SCREEN.bounds.size.width/414, 260*MAIN_SCREEN.bounds.size.height/736));
    self.popupViewController.view.clipsToBounds = YES;
    self.popupViewController.view.layer.cornerRadius = TWIC_CORNER_RADIUS;
    self.popupViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [self.view addSubview:self.popupViewController.view];
    self.popupViewController.view.center = self.view.center;
    [self.popupViewController didMoveToParentViewController:self];
    [super addChildViewController:self.popupViewController];
    
    //blur
    self.blurView  = [[GRKBlurView alloc]initWithFrame:self.supportView.frame];
    self.blurView.alpha = 0;
    [self.blurView setTargetImageFromView:self.supportView];
    self.blurView.blurRadius = 30.0f;
    [self.supportView addSubview:self.blurView];
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurviewTouched:)];
    [self.blurView addGestureRecognizer:tapAction];
    
    //animate the display !
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.popupViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        self.blurView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.popupViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.popupViewController.view.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

-(void)removePopupView{
    [UIView animateWithDuration:0.3f animations:^
     {
         self.popupViewController.view.alpha = 0;
         self.blurView.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [self.popupViewController.view removeFromSuperview];
         self.popupViewController = nil;
         [self.blurView removeFromSuperview];
         self.blurView = nil;
     }];
}

#pragma mark - ActionsView Management
-(void)addActionsView{
    if(self.popupViewController)//already presented !
        return;
    
    //actions
    self.popupViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICUserActionsViewController description]];
    ((TWICUserActionsViewController*)self.popupViewController).delegate = self;
    
    //show the popup
    [self showPopupView];
}

-(void)TWICUserActionsViewController:(id)sender didTouchAction:(UserActionType)actionType
{
    //do something with the action !
    [self removePopupView];
    
    switch (actionType) {
        case UserActionTypeStop:
            [TWICTokClient sharedInstance].publisher.publishVideo = NO;
            [TWICTokClient sharedInstance].publisher.publishAudio = NO;
            break;
        case UserActionTypeCamera:
            [TWICTokClient sharedInstance].publisher.publishVideo = ![TWICTokClient sharedInstance].publisher.publishVideo;
            break;
        case UserActionTypeRotate:
            if([TWICTokClient sharedInstance].publisher.cameraPosition == AVCaptureDevicePositionFront)
            {
                [TWICTokClient sharedInstance].publisher.cameraPosition = AVCaptureDevicePositionBack;
            }else{
                [TWICTokClient sharedInstance].publisher.cameraPosition = AVCaptureDevicePositionFront;
            }
            break;
        case UserActionTypeMicrophone:
            [TWICTokClient sharedInstance].publisher.publishAudio = ![TWICTokClient sharedInstance].publisher.publishAudio;
            break;
    }
}

-(void)blurviewTouched:(UIGestureRecognizer*)gesture{
    [self removePopupView];
}

#pragma mark - Camera - Microphone requests
-(void)currentUserCameraRequested:(NSNotification*)notification
{
    self.popupViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICAlertViewController description]];
    [(TWICAlertViewController*)self.popupViewController configureWithStyle:TWICAlertViewStyleCamera title:[NSString stringWithFormat:@"Do you want to share your video"]];
    ((TWICAlertViewController*)self.popupViewController).delegate = self;
    [self showPopupView];
}
-(void)currentUserMicrophoneRequested:(NSNotification*)notification
{
    self.popupViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICAlertViewController description]];
    [(TWICAlertViewController*)self.popupViewController configureWithStyle:TWICAlertViewStyleCamera title:[NSString stringWithFormat:@"Do you want to share your microphone"]];
    ((TWICAlertViewController*)self.popupViewController).delegate = self;
}

-(void)twicAlertViewControllerDidCancel:(id)sender{
    if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleCamera){
        [TWICTokClient sharedInstance].publisher.publishVideo = NO;
        [TWICTokClient sharedInstance].publisher.publishAudio = NO;
    }else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleMicrophone){
        [TWICTokClient sharedInstance].publisher.publishAudio = NO;
    }
    [self removePopupView];
}

-(void)twicAlertViewControllerDidAccept:(id)sender{
    if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleCamera){
        [TWICTokClient sharedInstance].publisher.publishVideo = YES;
        [TWICTokClient sharedInstance].publisher.publishAudio = YES;
    }else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleMicrophone){
        [TWICTokClient sharedInstance].publisher.publishAudio = YES;
    }
    [self removePopupView];
}

#pragma mark - Camera Microphone User Authorizations
-(void)userAskMicrophoneAuthorization:(id)sender{
    if(self.twicStreamGridViewController){//grid
        
    }else{//fullscreen
        //display popup when full screen
    }
}

-(void)userAskCameraAuthorization:(id)sender{
    if(self.twicStreamGridViewController){//grid
        
    }else{//fullscreen
        //display popup when full screen
    }
}
@end
