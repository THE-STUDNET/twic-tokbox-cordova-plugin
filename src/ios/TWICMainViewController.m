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
#import "TWICStreamViewController.h"
#import "Masonry.h"
#import "TWICTokClient.h"
#import "GRKBlurView.h"
#import "TWICUserActionsViewController.h"


#define PUBLISHER_VIEW_FRAME_WIDTH      120
#define PUBLISHER_VIEW_FRAME_HEIGHT     140
#define PUBLISHER_VIEW_FRAME_DEFAULT_Y  10
#define PUBLISHER_VIEW_FRAME_DEFAULT_X  10

@interface TWICMainViewController ()<UITextFieldDelegate,TWICStreamGridViewControllerDelegate,TWICUserActionsViewControllerDelegate>
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
@property (nonatomic, strong)TWICStreamViewController *twicStreamViewController;
@property (nonatomic, strong)TWICStreamViewController *twicStreamPublisherViewController;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *streams;
@property (nonatomic, assign) BOOL backButton;

@property (nonatomic, strong) GRKBlurView *blurView;
@property (nonatomic, strong) TWICUserActionsViewController *userActionsViewController;
@end

@implementation TWICMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(streamCreated:) name:TWIC_NOTIFICATION_STREAM_CREATED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(streamDestroyed:) name:TWIC_NOTIFICATION_STREAM_DESTROYED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sessionConnected:) name:TWIC_NOTIFICATION_SESSION_CONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sessionDisconnected:) name:TWIC_NOTIFICATION_SESSION_DISCONNECTED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(touchPublishedStream:) name:TWIC_NOTIFICATION_TOUCH_PUBLISHED_STREAM object:nil];

    [self configureSkin];
    [self configureLocalizable];
    [self refreshData];
    
    //connect the session
    self.streams = [NSMutableArray array];
    [[TWICTokClient sharedInstance] connectToSession:TOK_SESSION_ID withUser:self.users[0]];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)refreshData{
    self.users = [@[@{TWIC_USER_TOK_TOKEN:TOK_TOKEN_PAUL,TWIC_USER_FIRSTNAME_KEY:@"PAUL"},
                    @{TWIC_USER_TOK_TOKEN:TOK_TOKEN_PAUL,TWIC_USER_FIRSTNAME_KEY:@"PAUL"},
                    @{TWIC_USER_TOK_TOKEN:TOK_TOKEN_PAUL,TWIC_USER_FIRSTNAME_KEY:@"PAUL"}]mutableCopy];
    self.numberUsersLabel.text = [NSString stringWithFormat:@"%d",(int)self.users.count];
}

-(void)addSingleStreamViewControllerForStream:(OTStream *)stream
{
    //subscriber
    self.twicStreamViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
    [self addChildViewController:self.twicStreamViewController];
    [self.twicStreamViewController configureWithStream:stream];
    [self.twicStreamViewController connectStream];
    
    //add a publisher view if possible
    if ([TWICTokClient sharedInstance].session.capabilities.canPublish)
    {
        self.twicStreamPublisherViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
        [self.twicStreamPublisherViewController.view setFrame:CGRectMake(MAIN_SCREEN.bounds.size.width - PUBLISHER_VIEW_FRAME_WIDTH - PUBLISHER_VIEW_FRAME_DEFAULT_X, PUBLISHER_VIEW_FRAME_DEFAULT_Y, PUBLISHER_VIEW_FRAME_WIDTH, PUBLISHER_VIEW_FRAME_HEIGHT)];
        self.twicStreamPublisherViewController.view.layer.borderColor = [UIColor whiteColor].CGColor;
        self.twicStreamPublisherViewController.view.layer.cornerRadius = 5.0f;
        self.twicStreamPublisherViewController.view.layer.borderWidth = 1.0f;
        self.twicStreamPublisherViewController.view.clipsToBounds = YES;
        [self.view addSubview:self.twicStreamPublisherViewController.view];
        [super addChildViewController:self.twicStreamPublisherViewController];
        [self.twicStreamPublisherViewController didMoveToParentViewController:self];
        [self.twicStreamPublisherViewController startPublishing];
    }
}

-(void)addStreamGridViewController
{
    self.twicStreamGridViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamGridViewController description]];
    self.twicStreamGridViewController.delegate = self;
    [self addChildViewController:self.twicStreamGridViewController];
    [self.twicStreamGridViewController addStreams:self.streams];
}

-(void)addChildViewController:(UIViewController *)childController
{
    [self.supportView addSubview:childController.view];
    [childController.view mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.equalTo(self.supportView.mas_top);
        make.bottom.equalTo(self.supportView.mas_bottom);
        make.left.equalTo(self.supportView.mas_left);
        make.right.equalTo(self.supportView.mas_right);
    }];
    [super addChildViewController:childController];
    [childController didMoveToParentViewController:self];
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

        //remove stream vc
        [self.twicStreamViewController disconnect];
        [self.twicStreamViewController.view removeFromSuperview];
        self.twicStreamViewController = nil;
        
        //remove the publisher view
        [self.twicStreamViewController disconnect];
        [self.twicStreamPublisherViewController.view removeFromSuperview];
        self.twicStreamPublisherViewController = nil;

        //add grid
        [self addStreamGridViewController];
    }
    else
    {
        //disconnect
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
}

#pragma mark -TWICStreamGridViewController delegate
-(void)TWICStreamGridViewController:(id)sender didSelectStream:(OTStream *)stream
{
    //need to disconnect all streams
    [self.twicStreamGridViewController removeAllStreams];
    [self.twicStreamGridViewController.view removeFromSuperview];
    self.twicStreamGridViewController = nil;

    //add stream
    [self addSingleStreamViewControllerForStream:stream];

    self.backButton = YES;
}

-(void)TWICStreamGridViewControllerDidSelectPublisherStream:(id)sender
{
    [self addActionsView];
}

#pragma mark - TWICStreamViewController Notifications
-(void)touchPublishedStream:(NSNotification*)notification
{
    //add actions
    [self addActionsView];
}

#pragma mark - Tok Stream Management
-(void)streamCreated:(NSNotification *)notification
{
    [self.streams addObject:notification.object];
    if(self.twicStreamGridViewController)
    {
        [self.twicStreamGridViewController addStream:notification.object];
    }
}

-(void)streamDestroyed:(NSNotification *)notification
{
    [self.streams removeObject:notification.object];
    if(self.twicStreamGridViewController)
    {
        [self.twicStreamGridViewController removeStream:notification.object];
    }
    else if(self.twicStreamViewController)
    {
        //something to do...
    }
}

#pragma mark - ActionsView Management
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
    [super addChildViewController:self.userActionsViewController];
    
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
