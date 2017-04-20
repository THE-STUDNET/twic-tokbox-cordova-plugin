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
#import "TWICUserManagement.h"

@interface TWICMenuAccordionHeaderView()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *connectionStatusView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIImageView *chevronImageView;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *screenImageView;
@end

@implementation TWICMenuAccordionHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureSkin];
}

-(void)configureSkin{
    self.connectionStatusView.layer.cornerRadius = self.connectionStatusView.frame.size.width / 2;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.separatorView.backgroundColor = TWIC_COLOR_GREY;
    self.displayNameLabel.textColor = [UIColor whiteColor];
    self.connectionStatusView.backgroundColor = TWIC_COLOR_RED;
}

-(void)configureWithUser:(NSDictionary *)user
{
    self.chevronImageView.image = [UIImage imageNamed:@"down-arrow"];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[[TWICUserManagement sharedInstance]avatarURLStringForUser:user]]];
    self.displayNameLabel.text = [NSString stringWithFormat:@"%@ %@",user[UserFirstnameKey],user[UserLastnameKey]];
}

-(void)willOpen
{
    self.chevronImageView.image = [UIImage imageNamed:@"up-arrow"];
}

-(void)willClose
{
    self.chevronImageView.image = [UIImage imageNamed:@"down-arrow"];
}
@end
