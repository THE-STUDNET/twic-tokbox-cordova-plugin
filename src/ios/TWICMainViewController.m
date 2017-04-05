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

@interface TWICMainViewController ()<UITextFieldDelegate,TWICStreamGridViewControllerDelegate>
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
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, assign) BOOL backButton;
@end

@implementation TWICMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self configureSkin];
    [self configureLocalizable];
    [self refreshData];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)refreshData{
    self.users = [@[@{},@{},@{},@{}]mutableCopy];
}

-(void)refreshUI{
    if(self.users.count == 1)
    {
        [self addStreamViewControllerForUser:[self.users firstObject]];
    }
    else if(self.users.count > 1)
    {
        [self addStreamGridViewControllerForUsers:self.users];
    }
    self.numberUsersLabel.text = [NSString stringWithFormat:@"%d",(int)self.users.count];
}

-(void)addStreamViewControllerForUser:(NSDictionary *)user
{
    self.twicStreamViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
    [self addChildViewController:self.twicStreamViewController];
    [self.twicStreamViewController configureWithUser:user twicStreamDisplay:TWICStreamDisplayFullScreen];
}

-(void)addStreamGridViewControllerForUsers:(NSArray *)users;
{
    self.twicStreamGridViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamGridViewController description]];
    self.twicStreamGridViewController.delegate = self;
    [self addChildViewController:self.twicStreamGridViewController];
    [self.twicStreamGridViewController configureWithUsers:self.users];
}

-(void)addChildViewController:(UIViewController *)childController{
    [self.supportView addSubview:childController.view];
    [childController.view mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.messageTextField.text = LOCALIZED_STRING(@"mainvc.placeholder");
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
    self.messageTextField.text = LOCALIZED_STRING(@"mainvc.placeholder");
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
        [self.twicStreamViewController.view removeFromSuperview];
        self.twicStreamViewController = nil;
        
        //add grid
        [self addStreamGridViewControllerForUsers:self.users];
    }
    else
    {
        //disconnect
    }
}

#pragma mark -TWICStreamGridViewController delegate
-(void)TWICStreamGridViewController:(id)sender didSelectUser:(NSDictionary *)user
{
    [self.twicStreamGridViewController.view removeFromSuperview];
    self.twicStreamGridViewController = nil;
    
    //add stream
    [self addStreamViewControllerForUser:user];
    
    self.backButton = YES;
}

@end
