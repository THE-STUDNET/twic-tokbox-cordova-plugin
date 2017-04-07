//
//  StreamCollectionViewCell.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICStreamCollectionViewCell.h"
#import "TWICConstants.h"
#import "TWICStreamViewController.h"
#import "Masonry.h"

@interface TWICStreamCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *streamSupportView;
@property (weak, nonatomic) IBOutlet UILabel *streamTitleLabel;

@property (nonatomic, strong) TWICStreamViewController *streamViewController;

@end

@implementation TWICStreamCollectionViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
    //stream vc
    self.streamViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
    [self.contentView insertSubview:self.streamViewController.view atIndex:0];
    [self.streamViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    [self configureSkin];
}

-(void)prepareForReuse{
    [self.streamViewController disconnectSession];
}

-(void)configureSkin{
    self.contentView.backgroundColor = CLEAR_COLOR;
    self.streamViewController.view.clipsToBounds = YES;
    self.streamViewController.view.layer.cornerRadius = TWIC_CORNER_RADIUS;
}

-(void)configureWithUser:(id)user
{
    [self.streamViewController configureWithUser:user twicStreamDisplay:TWICStreamDisplayGrid];
}

@end
