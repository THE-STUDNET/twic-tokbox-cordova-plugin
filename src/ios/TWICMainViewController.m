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
#import "TWICHangoutManager.h"
#import "UIImageView+AFNetworking.h"
#import "TWICAlertsViewController.h"
#import "TWICSettingsManager.h"
#import "TWICSocketIOClient.h"
#import "TWICChatTableViewController.h"
#import "TWICMessageManager.h"

#define PUBLISHER_VIEW_FRAME_WIDTH     120
#define PUBLISHER_VIEW_FRAME_HEIGHT    140
#define PUBLISHER_VIEW_FRAME_DEFAULT_Y 10
#define PUBLISHER_VIEW_FRAME_DEFAULT_X -10

#define USER_BUTTONS_DEFAULT_TOP_CONSTRAINT 8

#define FOOTER_VIEW_DEFAULT_HEIGHT      112

@interface TWICMainViewController ()<UITextFieldDelegate,TWICStreamGridViewControllerDelegate,TWICUserActionsViewControllerDelegate,TWICAlertViewControllerDelegate,TWICMenuViewControllerDelegate,TWICAlertsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView             *headerView;
@property (weak, nonatomic) IBOutlet UIView             *supportView;
@property (weak, nonatomic) IBOutlet UIView             *footerView;
@property (weak, nonatomic) IBOutlet UIButton           *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton           *recordButton;
@property (weak, nonatomic) IBOutlet UILabel            *numberUsersLabel;
@property (weak, nonatomic) IBOutlet UIButton           *usersButton;
@property (weak, nonatomic) IBOutlet UIButton           *sendButton;
@property (weak, nonatomic) IBOutlet UITextField        *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView        *speakingImageView;
@property (weak, nonatomic) IBOutlet UILabel            *currentSpeakerDisplayName;
@property (weak, nonatomic) IBOutlet UIButton           *chatButton;
@property (weak, nonatomic) IBOutlet UIView             *chatNewMessageView;

@property (nonatomic, strong) TWICStreamGridViewController *twicStreamGridViewController;
@property (nonatomic, copy  ) NSString                     *currentSubcriberStreamID;
@property (nonatomic, assign) BOOL                         backButton;

@property (nonatomic, strong) GRKBlurView      *blurView;
@property (nonatomic, strong) UIViewController *popupViewController;

//current user buttons
@property (weak, nonatomic) IBOutlet UIView             *currentUserButtonsView;
@property (weak, nonatomic) IBOutlet UIButton           *currentUserCameraButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentUserButtonsViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton           *currentUserMicrophoneButton;

//users ask permissions
@property (weak, nonatomic) IBOutlet UIView      *userAuthorizationView;
@property (weak, nonatomic) IBOutlet UILabel     *userAuthorizationNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAuthorizationAvatarImageView;
@property (weak, nonatomic) IBOutlet UIButton    *userAuthorizationButton;
@property (weak, nonatomic) IBOutlet UIImageView *userAuthorizationTypeImageView;

//chat
@property (weak, nonatomic) TWICChatTableViewController *chatTableViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatContentView;
@property (nonatomic, assign) BOOL isChatOpened;

@end

@implementation TWICMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sessionConnected:) name:TWIC_NOTIFICATION_SESSION_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sessionDisconnected:) name:TWIC_NOTIFICATION_SESSION_DISCONNECTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(archivingStarted:) name:TWIC_NOTIFICATION_SESSION_ARCHIVE_STARTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(archivingStopped:) name:TWIC_NOTIFICATION_SESSION_ARCHIVE_STOPPED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(subscriberConnected:) name:TWIC_NOTIFICATION_SUBSCRIBER_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(subscriberDisconnected:) name:TWIC_NOTIFICATION_SUBSCRIBER_DISCONNECTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(publisherDestroyed:) name:TWIC_NOTIFICATION_PUBLISHER_DESTROYED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(publisherPublishing:) name:TWIC_NOTIFICATION_PUBLISHER_PUBLISHING object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userConnected:) name:TWIC_NOTIFICATION_USER_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userDisconnected:) name:TWIC_NOTIFICATION_USER_DISCONNECTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(currentUserCameraRequested:) name:NOTIFICATION_USER_CAMERA_REQUESTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(currentUserMicrophoneRequested:) name:NOTIFICATION_USER_MICROPHONE_REQUESTED object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userAskMicrophoneAuthorization:) name:NOTIFICATION_USER_ASK_MICROPHONE_AUTHORIZATION object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userAskCameraAuthorization:) name:NOTIFICATION_USER_ASK_CAMERA_AUTHORIZATION object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(userAskScreenAuthorization:) name:TWIC_NOTIFICATION_USER_ASK_SCREEN_AUTHORIZATION object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(newMessage:) name:TWIC_NOTIFICATION_NEW_MESSAGE object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(messagesLoaded:) name:TWIC_NOTIFICATION_MESSAGES_LOADED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(latestMessagesLoaded:) name:TWIC_NOTIFICATION_LATEST_MESSAGES_LOADED object:nil];
    
    [self configureSkin];
    [self configureLocalizable];
    [self refreshUI];
    
    //connect the session
    [[TWICTokClient sharedInstance] connect];
    
    //Chat
    [self configureChatViewController];
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
    self.messageTextField.text = nil;
    self.messageTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Type your message"
                                                                                 attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
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
    self.chatButton.tintColor = [UIColor whiteColor];
    
    [self.recordButton setImage:[UIImage imageNamed:[TWICTokClient sharedInstance].archiving?@"record":@"unrecord"] forState:UIControlStateNormal];
    
    [self configureView:self.disconnectButton];
    [self configureView:self.usersButton];
    [self configureView:self.sendButton];
    [self configureView:self.messageTextField];
    [self configureView:self.chatButton];
    
    self.currentSpeakerDisplayName.textColor = [UIColor whiteColor];
    self.currentSpeakerDisplayName.alpha = TWIC_ALPHA;
    self.currentSpeakerDisplayName.hidden = YES;
    self.speakingImageView.hidden = YES;
    
    self.currentUserButtonsView.hidden = YES;
    self.currentUserButtonsView.backgroundColor = CLEAR_COLOR;
    self.currentUserCameraButton.backgroundColor = CLEAR_COLOR;
    self.currentUserMicrophoneButton.backgroundColor = CLEAR_COLOR;
    
    self.userAuthorizationView.hidden = YES;
    self.userAuthorizationView.backgroundColor = CLEAR_COLOR;
    self.userAuthorizationButton.backgroundColor = CLEAR_COLOR;
    self.userAuthorizationNumberLabel.backgroundColor = CLEAR_COLOR;
    self.userAuthorizationTypeImageView.backgroundColor = CLEAR_COLOR;
    self.userAuthorizationAvatarImageView.backgroundColor = CLEAR_COLOR;
    self.userAuthorizationAvatarImageView.layer.cornerRadius = self.userAuthorizationAvatarImageView.frame.size.width / 2;
    
    self.chatNewMessageView.backgroundColor = TWIC_COLOR_BLUE;
    self.chatNewMessageView.layer.cornerRadius = self.chatNewMessageView.frame.size.width / 2;
    self.chatNewMessageView.hidden = YES;
    self.chatButton.hidden = YES;
    [self hideChatControls];
    [self hideChatViewController];
}

-(void)configureView:(UIView*)view{
    view.backgroundColor = [UIColor blackColor];
    view.alpha = TWIC_ALPHA;
    view.layer.cornerRadius = TWIC_CORNER_RADIUS;
    view.clipsToBounds = YES;
}

-(void)refreshUI{
    self.numberUsersLabel.text = [NSString stringWithFormat:@"%d",(int)[TWICUserManager sharedInstance].usersCount - 1];
    
    //publish or requests buttons
    if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionPublish])
    {
        self.currentUserButtonsViewTopConstraint.constant = -USER_BUTTONS_DEFAULT_TOP_CONSTRAINT;
        [self.currentUserMicrophoneButton setImage:[UIImage imageNamed:@"publish-microphone"] forState:UIControlStateNormal];
        [self.currentUserCameraButton setImage:[UIImage imageNamed:@"publish-camera"] forState:UIControlStateNormal];
    }
    else
    {
        self.currentUserButtonsViewTopConstraint.constant = USER_BUTTONS_DEFAULT_TOP_CONSTRAINT;
        [self.currentUserMicrophoneButton setImage:[UIImage imageNamed:@"request-microphone"] forState:UIControlStateNormal];
        [self.currentUserCameraButton setImage:[UIImage imageNamed:@"request-camera"] forState:UIControlStateNormal];
    }
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
    
    //change the current speaker label
    NSDictionary *user = [[TWICTokClient sharedInstance]userForSubscriberStreamID:subscriberID];
    if(user){
        self.currentSpeakerDisplayName.text = [[TWICUserManager sharedInstance]displayNameForUser:user];
        self.currentSpeakerDisplayName.hidden = NO;
        self.speakingImageView.hidden = NO;
    }
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
        
        
        //increase the height constraint for buttons
        self.currentUserButtonsViewTopConstraint.constant = PUBLISHER_VIEW_FRAME_HEIGHT + PUBLISHER_VIEW_FRAME_DEFAULT_Y;
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

-(void)configureChatViewController{
    self.chatTableViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICChatTableViewController description]];
    [self.chatContentView addSubview:self.chatTableViewController.view];
    [self.chatTableViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatContentView.mas_top);
        make.bottom.equalTo(self.chatContentView.mas_bottom);
        make.left.equalTo(self.chatContentView.mas_left);
        make.right.equalTo(self.chatContentView.mas_right);
    }];
    [self.chatTableViewController didMoveToParentViewController:self];
    [self addChildViewController:self.chatTableViewController];
    
    if([[TWICMessageManager sharedInstance] allMessages].count > 0){
        [self showChatControls];
    }else{
        [self hideChatControls];
    }   
}

-(void)showChatViewController
{
    self.isChatOpened = YES;
    [self.chatTableViewController refreshUI];
    self.footerHeightConstraint.constant = self.view.frame.size.height * 0.66;
    //mak all messages as read
    [[TWICMessageManager sharedInstance]markMessagesAsRead];
    //hide the new message view
    self.chatNewMessageView.hidden = YES;
}

-(void)hideChatViewController
{
    self.isChatOpened = NO;
    self.footerHeightConstraint.constant = FOOTER_VIEW_DEFAULT_HEIGHT;
}

-(void)hideChatControls{
    if(self.isChatOpened == NO){
        self.chatButton.hidden = YES;
        self.chatNewMessageView.hidden = YES;
    }
}

-(void)showChatControls{
    if(self.isChatOpened == NO)
    {
        self.chatButton.hidden = NO;
        //check the number of unread messages
        if([[TWICMessageManager sharedInstance]unreadMessagesCount] > 0)
        {
            self.chatNewMessageView.hidden = NO;
        }
    }
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
    if(self.messageTextField.text.length > 0 && [self.messageTextField.text isEqualToString:@"Type your message"] == NO){
        //need to send data
        [[TWICAPIClient sharedInstance]sendMessage:self.messageTextField.text
                                   toHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                   completionBlock:^(NSDictionary *message){}
                                      failureBlock:^(NSError *error)
         {
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         }];
        
        self.messageTextField.text = @"Type your message";
    }
}

- (IBAction)users:(id)sender {
    UINavigationController *navVC = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"Navigation%@",[TWICMenuViewController description]]];
    TWICMenuViewController *vc = (TWICMenuViewController *)navVC.topViewController;
    vc.delegate = self;
    vc.isAdmin = YES;
    [navVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];//hack mandatory !
    [self presentViewController:navVC animated:YES completion:nil];
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
        
        //recalculate the good constraints for action buttons
        if(self.currentUserButtonsView){
            self.currentUserButtonsViewTopConstraint.constant = USER_BUTTONS_DEFAULT_TOP_CONSTRAINT;
        }

        //add grid
        [self addStreamGridViewController];
        
        //remove speaking info
        self.speakingImageView.hidden = YES;
        self.currentSpeakerDisplayName.hidden = YES;
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

- (IBAction)openChat:(id)sender
{
    if(self.footerHeightConstraint.constant == FOOTER_VIEW_DEFAULT_HEIGHT){
        [self showChatViewController];
    }else{
        [self hideChatViewController];
    }
    
}

#pragma mark - TokSession Management
-(void)sessionConnected:(NSNotification *)notification
{
    [self addStreamGridViewController];
    
    //auto publishing ?
    if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishMicrophone] ||
       [[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishCamera])
    {
        if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishCamera])
        {
            [[TWICTokClient sharedInstance]publishVideo:YES audio:YES];
        }
        else if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionAutoPublishCamera])
        {
            [[TWICTokClient sharedInstance]publishVideo:NO audio:YES];
        }
    }
    else
    {
        //display request or publishing buttons
        self.currentUserButtonsView.hidden = NO;
    }
    
    //can archive
    self.recordButton.enabled = [[TWICHangoutManager sharedInstance]canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionArchive];
    
    //archiving
    [self.recordButton setImage:[UIImage imageNamed:[TWICTokClient sharedInstance].archiving?@"record":@"unrecord"] forState:UIControlStateNormal];
    
    //chat
    [[TWICMessageManager sharedInstance]loadMessages];
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

#pragma mark - Tok Publisher Management
-(void)publisherDestroyed:(NSNotification *)notification{
    
    if(self.twicStreamGridViewController)
    {
        [self.twicStreamGridViewController refresh];
    }
    [self.view setNeedsDisplay];
    //add current user action buttons
    self.currentUserButtonsView.hidden = NO;
}

-(void)publisherPublishing:(NSNotification *)notification{
    if(self.twicStreamGridViewController)
    {
        [self.twicStreamGridViewController refresh];
    }
    //remove current user action buttons
    self.currentUserButtonsView.hidden = YES;
}

#pragma mark - Tok Archiving Management
-(void)archivingStarted:(NSNotification*)notification{
    [self.recordButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
}

-(void)archivingStopped:(NSNotification*)notification{
    [self.recordButton setImage:[UIImage imageNamed:@"unrecord"] forState:UIControlStateNormal];
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
    //blur
    self.blurView  = [[GRKBlurView alloc]initWithFrame:self.supportView.frame];
    self.blurView.alpha = 0;
    [self.blurView setTargetImageFromView:self.view];
    self.blurView.blurRadius = 30.0f;
    [self.view addSubview:self.blurView];
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurviewTouched:)];
    [self.blurView addGestureRecognizer:tapAction];
    
    UPDATE_VIEW_FRAME_SIZE(self.popupViewController.view, CGSizeMake(301*MAIN_SCREEN.bounds.size.width/414, 258*MAIN_SCREEN.bounds.size.height/736));
    self.popupViewController.view.clipsToBounds = YES;
    self.popupViewController.view.layer.cornerRadius = TWIC_CORNER_RADIUS;
    self.popupViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [self.view addSubview:self.popupViewController.view];
    self.popupViewController.view.center = self.view.center;
    [self.popupViewController didMoveToParentViewController:self];
    [super addChildViewController:self.popupViewController];

    //animate the display !
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.popupViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        self.blurView.alpha = 1;
        //resign first responder if exist
        [self.view endEditing:YES];
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

-(void)TWICUserActionsViewController:(id)sender didTouchAction:(CurrentUserActionType)actionType
{
    //do something with the action !
    [self removePopupView];
    
    switch (actionType) {
        case CurrentUserActionTypeStop:
            [[TWICTokClient sharedInstance] unpublish];
            break;
        case CurrentUserActionTypeCamera:{
            [TWICTokClient sharedInstance].publisher.publishVideo = ![TWICTokClient sharedInstance].publisher.publishVideo;
            break;
        }
        case CurrentUserActionTypeRotate:
            if([TWICTokClient sharedInstance].publisher.cameraPosition == AVCaptureDevicePositionFront)
            {
                [TWICTokClient sharedInstance].publisher.cameraPosition = AVCaptureDevicePositionBack;
            }else{
                [TWICTokClient sharedInstance].publisher.cameraPosition = AVCaptureDevicePositionFront;
            }
            break;
        case CurrentUserActionTypeMicrophone:
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
    [(TWICAlertViewController*)self.popupViewController configureWithAuthorization:@{UserAskCamera:[TWICUserManager sharedInstance].currentUser}];
    ((TWICAlertViewController*)self.popupViewController).delegate = self;
    [self showPopupView];
}

-(void)currentUserMicrophoneRequested:(NSNotification*)notification
{
    self.popupViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICAlertViewController description]];
    [(TWICAlertViewController*)self.popupViewController configureWithAuthorization:@{UserAskMicrophone:[TWICUserManager sharedInstance].currentUser}];
    ((TWICAlertViewController*)self.popupViewController).delegate = self;
    [self showPopupView];
}


#pragma mark - AlertViewControllerDelegate
-(void)twicAlertViewControllerDidAccept:(id)sender{
    if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleCamera)
    {
        [[TWICTokClient sharedInstance] publishVideo:YES audio:YES];
    }
    else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleMicrophone)
    {
        [[TWICTokClient sharedInstance] publishVideo:NO audio:YES];
    }
    else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleScreen)
    {
        //nothing to do on mobile
    }
    //hide popup
    [self removePopupView];
}

-(void)twicAlertViewControllerDidCancel:(id)sender{
    [self removePopupView];
}

#pragma mark - AlertsViewControllerDelegate
-(void)twicAlertViewControllerDidFinish:(id)sender{
    [self removePopupView];
    //update or remove completely the authorization view
    [self updateUserAuthorizationView];
}

#pragma mark - Camera Microphone User Authorizations
-(void)userAskMicrophoneAuthorization:(NSNotification*)notification{
    [self updateUserAuthorizationView];
}

-(void)userAskCameraAuthorization:(NSNotification*)notification{
    [self updateUserAuthorizationView];
}
-(void)userAskScreenAuthorization:(NSNotification*)notification{
    [self updateUserAuthorizationView];
}

#pragma mark - Authorization view
-(void)updateUserAuthorizationView{
    //display the request button for 1 user or n users
    //need to retrieve the number of users that are asking authorization
    int nbOfRequests=[[TWICUserManager sharedInstance]numberOfWaitingAuthorizations];
    
    //display the request button for 1 user or n users
    if(nbOfRequests == 1)
    {
        NSDictionary *user = [[[TWICUserManager sharedInstance]waitingAuthorizationsUsers]firstObject];
        UIImage *imageType = nil;
        if([[TWICUserManager sharedInstance]isUserAskingCameraPermission:user]){
            imageType = [UIImage imageNamed:@"user-request-camera"];
        }
        else if([[TWICUserManager sharedInstance]isUserAskingMicrophonePermission:user])
        {
            imageType = [UIImage imageNamed:@"user-request-microphone"];
        }
        else if([[TWICUserManager sharedInstance]isUserSharingScreen:user])
        {
            imageType = [UIImage imageNamed:@"user-request-screen"];
        }
        self.userAuthorizationTypeImageView.image = imageType;
        [self.userAuthorizationAvatarImageView setImageWithURL:[NSURL URLWithString:[[TWICUserManager sharedInstance]avatarURLStringForUser:user]]];
        self.userAuthorizationNumberLabel.hidden = YES;
        self.userAuthorizationView.hidden = NO;
    }
    else if(nbOfRequests > 1)
    {
        //to be done later with the label !
        self.userAuthorizationNumberLabel.hidden = NO;
        self.userAuthorizationNumberLabel.text = [NSString stringWithFormat:@"%d",nbOfRequests];
        self.userAuthorizationAvatarImageView.image = nil;
        self.userAuthorizationAvatarImageView.hidden = YES;
        self.userAuthorizationTypeImageView.hidden = YES;
        self.userAuthorizationView.hidden = NO;
    }
    else
    {
        self.userAuthorizationView.hidden = YES;
    }
}

- (IBAction)openUserAuthorizationAlertView:(id)sender
{
    //need to retrieve the number of users that are asking authorization
    if([[TWICUserManager sharedInstance]numberOfWaitingAuthorizations] >= 0)
    {
        NSDictionary *user = [[[TWICUserManager sharedInstance]waitingAuthorizationsUsers]firstObject];
        NSString *askForType=nil;
        TWICAlertViewStyle askStyle=TWICAlertViewStyleScreen;
        if([[TWICUserManager sharedInstance] isUserAskingScreenPermission:user]){
            askForType = @"screen";
            askStyle = TWICAlertViewStyleScreen;
        }
        else if([[TWICUserManager sharedInstance] isUserAskingCameraPermission:user]){
            askForType=@"camera";
            askStyle = TWICAlertViewStyleCamera;
        }
        else{
            askForType=@"microphone";
            askStyle = TWICAlertViewStyleMicrophone;
        }
        //instantiate the twic alerts
        self.popupViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICAlertsViewController description]];
        ((TWICAlertsViewController*)self.popupViewController).delegate = self;
    }
    //show the popup
    [self showPopupView];
}

#pragma mark - Current User Request / Publish actions
- (IBAction)publishOrRequestCamera:(id)sender {
    if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionPublish])
    {
        [[TWICTokClient sharedInstance]publishVideo:YES audio:YES];
    }
    else
    {
        //signal everybody
        [[TWICTokClient sharedInstance]broadcastSignal:SignalTypeCameraAuthorization];
        
        //call api
        [[TWICAPIClient sharedInstance]registerEventName:HangoutEventAskCameraAuth completionBlock:^{} failureBlock:nil];
        
        //update current user
        [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:[TWICUserManager sharedInstance].currentUser[UserIdKey] toValue:YES];
    }
}

- (IBAction)publishOrRequestMicrophone:(id)sender {
    if([[TWICHangoutManager sharedInstance] canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionPublish])
    {
        [[TWICTokClient sharedInstance]publishVideo:[TWICTokClient sharedInstance].publisher.publishVideo audio:YES];
    }
    else
    {
        //signal everybody
        [[TWICTokClient sharedInstance]broadcastSignal:SignalTypeMicrophoneAuthorization];
        
        //call api
        [[TWICAPIClient sharedInstance]registerEventName:HangoutEventAskMicrophoneAuth completionBlock:^{} failureBlock:nil];
        
        //update currentuser
        [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:[TWICUserManager sharedInstance].currentUser[UserIdKey] toValue:YES];
    }
}

#pragma mark - TWICMenuViewControllerDelegate
-(void)TWICMenuViewController:(id)sender didSelectAction:(NSDictionary *)action forUser:(NSDictionary *)user
{
    UserActionType actionType = [action[UserActionTypeKey]integerValue];
    switch (actionType) {
        case UserActionTypeAskShareCamera:
        case UserActionTypeAllowShareCamera:
            //tok signaling
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeCameraRequested toUser:user];
            //api event
            [[TWICAPIClient sharedInstance]registerEventName:HangoutEventLaunchUserCamera
                                             completionBlock:^{}
                                                failureBlock:^(NSError *error) {}];
            break;
        case UserActionTypeAskShareMicrophone:
        case UserActionTypeAllowShareMicrophone:
            //tok signaling
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeMicrophoneRequested toUser:user];
            //api event
            [[TWICAPIClient sharedInstance]registerEventName:HangoutEventLaunchUserMicrophone
                                             completionBlock:^{}
                                                failureBlock:^(NSError *error) {}];
            break;
        case UserActionTypeKick:
            //tok signaling
            [[TWICTokClient sharedInstance]kickUser:user];
            //api event
            [[TWICAPIClient sharedInstance]registerEventName:HangoutActionKick
                                             completionBlock:^{}
                                                failureBlock:^(NSError *error) {}];
            break;
        case UserActionTypeSendDirectMessage:
            break;
        case UserActionTypeForceUnpublishStream:
            [[TWICTokClient sharedInstance]forceUnpublishStreamOfUser:user];
            break;
        case UserActionTypeForceUnpublishScreen:
            [[TWICTokClient sharedInstance]forceUnpublishScreenOfUser:user];
            break;
        case UserActionTypeAllowShareScreen:
            //tok signaling
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeScreenRequested toUser:user];
            //api event
            [[TWICAPIClient sharedInstance]registerEventName:HangoutEventLaunchUserScreen
                                             completionBlock:^{}
                                                failureBlock:^(NSError *error) {}];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Archive actions
- (IBAction)record:(id)sender {
    if([[TWICHangoutManager sharedInstance]canUser:[TWICUserManager sharedInstance].currentUser doAction:HangoutActionArchive]){
        if([TWICTokClient sharedInstance].archiving){
            //update ui immediately
            [self.recordButton setImage:[UIImage imageNamed:@"unrecord"] forState:UIControlStateNormal];
            //stop archiving
            [[TWICAPIClient sharedInstance]stopArchivingHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                                      completionBlock:^{}
                                                         failureBlock:^(NSError *error)
            {
                //rollback the ui
                [self.recordButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
            
            [[TWICAPIClient sharedInstance] registerEventName:HangoutEventStopRecord
                                              completionBlock:^{}
                                                 failureBlock:^(NSError *error) {}];
        }else{
            //update ui immediately
            [self.recordButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
            //start archiving
            [[TWICAPIClient sharedInstance]startArchivingHangoutWithID:[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]
                                                      completionBlock:^{}
                                                         failureBlock:^(NSError *error)
             {
                 //update ui immediately
                 [self.recordButton setImage:[UIImage imageNamed:@"unrecord"] forState:UIControlStateNormal];
                 [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             }];

            //stop archiving
            [[TWICAPIClient sharedInstance] registerEventName:HangoutEventStartRecord
                                              completionBlock:^{}
                                                 failureBlock:^(NSError *error) {}];
        }
    }
}

#pragma mark - Chat Management
-(void)newMessage:(NSNotification *)notification{
    [self showChatControls];
}
-(void)messagesLoaded:(NSNotification*)notification{
    if([[TWICMessageManager sharedInstance] allMessages].count > 0){
        [self showChatControls];
    }
}

-(void)latestMessagesLoaded:(NSNotification *)notification{
    if([[TWICMessageManager sharedInstance] allMessages].count > 0){
        [self showChatControls];
    }
}
@end
