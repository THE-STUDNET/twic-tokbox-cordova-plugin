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

@interface TWICMainViewController ()<UITextFieldDelegate>
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

@end

@implementation TWICMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self configureSkin];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

#pragma mark - Skining
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
}
@end
