//
//  AccordionHeaderView.m
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import "TWICMenuAccordionHeaderView.h"
#import "TWICConstants.h"
#import "UIImageView+AFNetworking.h"
#import "TWICUserManager.h"
#import "TWICTokClient.h"

@interface TWICMenuAccordionHeaderView()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView      *connectionStatusView;
@property (weak, nonatomic) IBOutlet UILabel     *displayNameLabel;
@property (weak, nonatomic) IBOutlet UIView      *separatorView;
@property (weak, nonatomic) IBOutlet UIImageView *chevronImageView;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *screenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;

@property (nonatomic, weak) NSDictionary *user;
@end

@implementation TWICMenuAccordionHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureSkin];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

-(void)configureSkin{
    self.backgroundColor = CLEAR_COLOR;
    self.contentView.backgroundColor = TWIC_COLOR_BLACK;
    self.connectionStatusView.layer.cornerRadius = self.connectionStatusView.frame.size.width / 2;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.avatarImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.avatarImageView.layer.borderWidth = 1;
    self.separatorView.backgroundColor = TWIC_COLOR_GREY;
    self.displayNameLabel.textColor = [UIColor whiteColor];
    self.displayNameLabel.font = [UIFont boldSystemFontOfSize:15];
    self.connectionStatusView.backgroundColor = TWIC_COLOR_RED;
    self.chevronImageView.image = [UIImage imageNamed:@"down-arrow"];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.chevronImageView.image = [UIImage imageNamed:@"down-arrow"];
}

-(void)configureWithUser:(NSDictionary *)user
{
    self.user = user;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[[TWICUserManager sharedInstance]avatarURLStringForUser:user]] placeholderImage:[UIImage imageNamed:@"user"]];
    self.displayNameLabel.text = [[TWICUserManager sharedInstance]displayNameForUser:user];
    if([user[UserConnectionStateKey]integerValue] == UserConnectionStateConnected){
        self.connectionStatusView.backgroundColor = TWIC_COLOR_GREEN;
    }else{
        self.connectionStatusView.backgroundColor = TWIC_COLOR_RED;
    }
    if([[TWICUserManager sharedInstance]actionsForUser:self.user].count > 0){
        self.chevronImageView.hidden = NO;
    }else{
        self.chevronImageView.hidden = YES;
    }
    [self refreshStreamStates];
}

-(void)refreshStreamStates{
    self.microphoneImageView.hidden = ![[TWICUserManager sharedInstance]isUserSharingAudio:self.user];
    self.screenImageView.hidden = ![[TWICUserManager sharedInstance]isUserSharingScreen:self.user];
    self.cameraImageView.hidden = ![[TWICUserManager sharedInstance]isUserSharingCamera:self.user];
}

-(void)willOpen{
    self.chevronImageView.image = [UIImage imageNamed:@"up-arrow"];
}

-(void)willClose{
    self.chevronImageView.image = [UIImage imageNamed:@"down-arrow"];
}
@end
