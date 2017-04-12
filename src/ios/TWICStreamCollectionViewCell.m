//
//  StreamCollectionViewCell.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICStreamCollectionViewCell.h"
#import "TWICConstants.h"
#import "Masonry.h"

@interface TWICStreamCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *streamSupportView;
@property (weak, nonatomic) IBOutlet UILabel *streamTitleLabel;

@property (nonatomic, weak) TWICStreamViewController *streamViewController;

@end

@implementation TWICStreamCollectionViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self configureSkin];
}

-(void)configureSkin{
    self.contentView.backgroundColor = CLEAR_COLOR;
}

-(void)configureWithStreamViewController:(TWICStreamViewController*)streamViewController
{
    self.streamViewController = streamViewController;
    [self.contentView insertSubview:self.streamViewController.view atIndex:0];
    [self.streamViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
    }];
    self.streamViewController.view.clipsToBounds = YES;
    self.streamViewController.view.layer.cornerRadius = TWIC_CORNER_RADIUS;
}
@end
