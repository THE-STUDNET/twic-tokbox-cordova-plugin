//
//  StreamCollectionViewCell.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICStreamCollectionViewCell.h"
#import "TWICConstants.h"

@interface TWICStreamCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *streamSupportView;
@property (weak, nonatomic) IBOutlet UILabel *streamTitleLabel;

@end

@implementation TWICStreamCollectionViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    [self configureSkin];
}

-(void)configureSkin{
}

-(void)configureWithData:(id)data
{
    
}

@end
