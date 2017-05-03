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
@end

@implementation TWICAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureSkin];
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
    self.alertTitle.text = title;
    if(style == TWICAlertViewStyleCamera){
        self.alertImageView.image = [UIImage imageNamed:@"camera"];
    }else if(style==TWICAlertViewStyleMicrophone){
        self.alertImageView.image = [UIImage imageNamed:@"microphone"];
    }
}

-(TWICAlertViewStyle)style
{
    return self.alertStyle;
}
@end
