//
//  TWICUserActionsViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 07/04/2017.
//
//

#import "TWICUserActionsViewController.h"

@interface TWICUserActionsViewController ()
@property (weak, nonatomic) IBOutlet UIView *microphoneView;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneImageView;
@property (weak, nonatomic) IBOutlet UILabel *microphoneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *microphoneSubtitleLabel;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet UILabel *cameraTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cameraSubtitleLabel;

@property (weak, nonatomic) IBOutlet UIView *rotateView;
@property (weak, nonatomic) IBOutlet UILabel *rotateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rotateSubtitleLabel;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *actionViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *actionSubtitleLabels;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *actionImageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *actionTitleLabels;


@end

@implementation TWICUserActionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
