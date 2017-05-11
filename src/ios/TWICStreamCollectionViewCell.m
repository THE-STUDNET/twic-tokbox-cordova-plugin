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
@property (weak, nonatomic) IBOutlet UIImageView *microphoneImageView;

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

-(void)configureWithStreamedView:(UIView *)view hasVideo:(BOOL)hasVideo hasAudio:(BOOL)hasAudio{
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
    self.streamedView.layer.borderColor = [CLEAR_COLOR CGColor];
//    if(!hasVideo && hasAudio){
//        self.microphoneImageView.hidden = NO;
//    }else{
//        self.microphoneImageView.hidden = YES;
//    }
    self.microphoneImageView.hidden = YES;
}

-(void)configureWithSubscriber:(OTSubscriber*)subscriber
{
    [self configureWithStreamedView:subscriber.view hasVideo:subscriber.stream.hasVideo hasAudio:subscriber.stream.hasAudio];
}

-(void)configureWithPublisher:(OTPublisher*)publisher
{
    [self configureWithStreamedView:publisher.view hasVideo:publisher.stream.hasVideo hasAudio:publisher.stream.hasAudio];
}
@end
