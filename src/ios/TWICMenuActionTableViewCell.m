//
//  TWICMenuActionTableViewCell.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICMenuActionTableViewCell.h"
#import "TWICConstants.h"
#import "TWICUserManager.h"

@interface TWICMenuActionTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *adminActionTitleLabel;

@end

@implementation TWICMenuActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureSkin];
}

-(void)configureSkin{
    self.backgroundColor = CLEAR_COLOR;
    self.contentView.backgroundColor = CLEAR_COLOR;
    self.actionTitleLabel.textColor = [UIColor whiteColor];
    self.adminActionTitleLabel.textColor = [UIColor whiteColor];
    self.adminActionTitleLabel.backgroundColor = TWIC_COLOR_RED;
    self.adminActionTitleLabel.layer.cornerRadius = TWIC_CORNER_RADIUS;
    self.adminActionTitleLabel.clipsToBounds = YES;
}

-(void)configureWithAction:(NSDictionary *)action user:(NSDictionary *)user
{
    if(action[UserActionIsRedKey]){
        self.adminActionTitleLabel.text = action[UserActionTitleKey];
    }
    else
    {
        self.actionImageView.image = [UIImage imageNamed:action[UserActionImageKey]];
        self.actionTitleLabel.text = action[UserActionTitleKey];
    }    
}
@end
