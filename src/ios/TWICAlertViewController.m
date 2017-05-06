//
//  TWICAlertViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 03/05/2017.
//
//

#import "TWICAlertViewController.h"
#import "TWICConstants.h"

@interface TWICAlertViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (nonatomic, assign) TWICAlertViewStyle alertStyle;
@property (nonatomic, strong) NSString *alertTitleString;
@end

@implementation TWICAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureSkin];
}
-(void)viewWillAppear:(BOOL)animated{
    [self refreshUI];
}
-(void)configureSkin{
    self.acceptButton.backgroundColor = TWIC_COLOR_GREEN;
    self.declineButton.backgroundColor = TWIC_COLOR_RED;
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.acceptButton.layer.cornerRadius = TWIC_CORNER_RADIUS;
    self.declineButton.layer.cornerRadius = TWIC_CORNER_RADIUS;
}

- (IBAction)accept:(id)sender
{
    [self.delegate twicAlertViewControllerDidAccept:self];
}

- (IBAction)decline:(id)sender
{
    [self.delegate twicAlertViewControllerDidCancel:self];
}

-(void)configureWithStyle:(TWICAlertViewStyle)style title:(NSString *)title
{
    self.alertStyle = style;
    self.alertTitleString = title;
}

-(TWICAlertViewStyle)style
{
    return self.alertStyle;
}

-(void)refreshUI{
    if(self.style == TWICAlertViewStyleCamera){
        self.alertImageView.image = [UIImage imageNamed:@"camera"];
    }else if(self.style==TWICAlertViewStyleMicrophone){
        self.alertImageView.image = [UIImage imageNamed:@"microphone"];
    }
    self.alertTitle.text = self.alertTitleString;
}
@end
