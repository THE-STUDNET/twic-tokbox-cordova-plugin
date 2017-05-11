//
//  TWICAlertViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 03/05/2017.
//
//

#import "TWICAlertViewController.h"
#import "TWICConstants.h"
#import "TWICUserManager.h"

@interface TWICAlertViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (nonatomic, assign) TWICAlertViewStyle alertStyle;
@property (nonatomic, strong) NSString *alertTitleString;
@property (nonatomic, strong) NSDictionary *alertedUser;
@property (nonatomic, strong) NSDictionary *alertAuthorizationData;
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

-(void)configureWithAuthorization:(NSDictionary *)authorizationData
{
    self.alertAuthorizationData = authorizationData;
    NSString *authorizationType = [[authorizationData allKeys]firstObject];
    self.alertedUser = authorizationData[authorizationType];
    NSString *askForType=nil;
    if([authorizationType isEqualToString:UserAskScreen]){
        self.alertStyle = TWICAlertViewStyleScreen;
        askForType = @"screen";
    }else if([authorizationType isEqualToString:UserAskMicrophone]){
        self.alertStyle = TWICAlertViewStyleMicrophone;
        askForType = @"microphone";
    }else if([authorizationType isEqualToString:UserAskCamera]){
        self.alertStyle = TWICAlertViewStyleCamera;
        askForType = @"camera";
    }
    if([self.alertedUser[UserIdKey] isEqualToNumber:[TWICUserManager sharedInstance].currentUser[UserIdKey]]){
        self.alertTitleString = [NSString stringWithFormat:@"Do you want to share your %@",askForType];
    }else{
        self.alertTitleString = [NSString stringWithFormat:@"Allow %@ to share his %@",self.alertedUser[UserFirstnameKey],askForType];
    }    
    [self refreshUI];
}

-(void)refreshUI{
    if(self.style == TWICAlertViewStyleCamera){
        self.alertImageView.image = [UIImage imageNamed:@"camera"];
    }else if(self.style==TWICAlertViewStyleMicrophone){
        self.alertImageView.image = [UIImage imageNamed:@"microphone"];
    }else if(self.style == TWICAlertViewStyleScreen){
        self.alertImageView.image = [UIImage imageNamed:@"screen"];
    }
    self.alertTitle.text = self.alertTitleString;
}

-(TWICAlertViewStyle)style{
    return self.alertStyle;
}

-(NSDictionary *)user{
    return self.alertedUser;
}

-(NSDictionary *)authorizationData{
    return self.alertAuthorizationData;
}


- (IBAction)accept:(id)sender
{
    [self.delegate twicAlertViewControllerDidAccept:self];
}

- (IBAction)decline:(id)sender
{
    [self.delegate twicAlertViewControllerDidCancel:self];
}
@end
