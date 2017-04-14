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

@property (nonatomic, weak) UIView *streamedView;

@end

@implementation TWICStreamCollectionViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self configureSkin];
}

-(void)configureSkin{
    self.contentView.backgroundColor = CLEAR_COLOR;
}

-(void)prepareForReuse{
    [self.streamedView removeFromSuperview];
}

-(void)configureWithStreamedView:(UIView *)view{
    self.streamedView = view;
    [self.contentView insertSubview:view atIndex:0];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
    }];
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = TWIC_CORNER_RADIUS;
}

-(void)configureWithSubscriber:(OTSubscriber*)subscriber
{
    [self configureWithStreamedView:subscriber.view];
}

-(void)configureWithPublisher:(OTPublisher*)publisher
{
    [self configureWithStreamedView:publisher.view];
}
@end
