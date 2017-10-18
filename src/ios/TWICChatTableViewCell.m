//
//  TWICChatTableViewCell.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 08/06/2017.
//
//

#import "TWICChatTableViewCell.h"
#import "TWICConstants.h"
#import "TWICUserManager.h"
#import "UIImageView+AFNetworking.h"
#import "TWICUserManager.h"
#import "TWICMessageManager.h"

@interface TWICChatTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel     *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *messageLabel;
@property (weak, nonatomic) IBOutlet UIView      *supportView;

@end

@implementation TWICChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureSkin];
}

-(void)prepareForReuse{
    [super prepareForReuse];
}

-(void)configureSkin{
    self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width / 2;
    self.userDisplayNameLabel.textColor = TWIC_COLOR_BLACK;
    self.userDisplayNameLabel.font = [UIFont boldSystemFontOfSize:12];
    self.messageLabel.textColor = TWIC_COLOR_GREY;
    self.messageLabel.font = [UIFont systemFontOfSize:12];
    self.supportView.backgroundColor = [UIColor whiteColor];
    self.supportView.layer.cornerRadius = TWIC_CORNER_RADIUS;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];    
}

-(void)configureWithMessage:(NSDictionary *)message
{
    if(message[MessageUserIdKey]){
        NSDictionary *user = [[TWICUserManager sharedInstance]userWithUserID:message[MessageUserIdKey]];
        self.userDisplayNameLabel.text = [[TWICUserManager sharedInstance]displayNameForUser:user];
        [self.userAvatarImageView setImageWithURL:[NSURL URLWithString:[[TWICUserManager sharedInstance]avatarURLStringForUser:user]]];
        
        //if my message, then color in blue
        if([[TWICUserManager sharedInstance] isCurrentUser:user]){
            self.supportView.backgroundColor = TWIC_COLOR_BLUE;
            self.userDisplayNameLabel.textColor = [UIColor whiteColor];
            self.messageLabel.textColor = [UIColor whiteColor];
        }else{
            self.supportView.backgroundColor = [UIColor whiteColor];
            self.userDisplayNameLabel.textColor = TWIC_COLOR_BLACK;
            self.messageLabel.textColor = TWIC_COLOR_GREY;
        }
    }else{
        self.userDisplayNameLabel.text = @"Automatic message";
        self.userAvatarImageView.image = [UIImage imageNamed:@"user"];
    }
    
    self.messageLabel.text = message[@"text"];
    
    //mark message as read if needed
    if([message[MessageReadKey]boolValue] ==  NO){
    }
}

-(CGFloat)height{
    CGRect rect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - self.messageLabel.frame.origin.x - self.supportView.frame.origin.x - 8, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.messageLabel.font} context:nil];
    CGFloat rowHeight = 32 + self.messageLabel.frame.origin.y + rect.size.height;
    return rowHeight;
}

@end
