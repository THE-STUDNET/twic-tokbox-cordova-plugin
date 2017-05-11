//
//  TWICAlertsViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 11/05/2017.
//
//

#import "TWICAlertsViewController.h"
#import "TWICTokClient.h"
#import "TWICUserManager.h"
#import "TWICAPIClient.h"
#import "TWICAlertViewController.h"
#import "Masonry.h"

@interface TWICAlertsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TWICAlertViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *authorizations;
@property (nonatomic, strong) NSMutableArray *alertViewControllers;
@end

@implementation TWICAlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self configureSkin];
    
    [self refreshData];
}
-(void)configureSkin{
    self.pageControl.currentPageIndicatorTintColor = TWIC_COLOR_GREY;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
}

-(void)refreshData{
    //build data
    self.authorizations = [NSMutableArray array];
    for(NSDictionary *user in [[TWICUserManager sharedInstance]waitingAuthorizationsUsers])
    {
        if([[TWICUserManager sharedInstance]isUserAskingCameraPermission:user]){
            [self.authorizations addObject:@{UserAskCamera:user}];
        }
        if([[TWICUserManager sharedInstance]isUserAskingMicrophonePermission:user]){
            [self.authorizations addObject:@{UserAskMicrophone:user}];
        }
        if([[TWICUserManager sharedInstance]isUserAskingScreenPermission:user]){
            [self.authorizations addObject:@{UserAskScreen:user}];
        }
    }
    self.pageControl.numberOfPages = self.authorizations.count;
    self.pageControl.currentPage = 0;
    self.alertViewControllers = [NSMutableArray arrayWithCapacity:self.authorizations.count];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.authorizations count];
}

static NSString *cellIdentifier =  @"AlertViewCell";
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if([cell.contentView viewWithTag:100] != nil)
    {
        [[cell.contentView viewWithTag:100]removeFromSuperview];
    }
    TWICAlertViewController *vc = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICAlertViewController description]];
    vc.delegate = self;
    vc.view.tag = 100;
    [cell.contentView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(cell.contentView.mas_top);
         make.bottom.equalTo(cell.contentView.mas_bottom);
         make.left.equalTo(cell.contentView.mas_left);
         make.right.equalTo(cell.contentView.mas_right);
     }];
    [self.alertViewControllers insertObject:vc atIndex:indexPath.row];
    [vc configureWithAuthorization:self.authorizations[indexPath.row]];
    return cell;
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.collectionView.bounds.size;
}

#pragma mark TWICAlertViewControllerDelegate
-(void)twicAlertViewControllerDidAccept:(id)sender{
    NSDictionary *user =((TWICAlertViewController*)sender).user;
    if([user[UserIdKey] isEqualToNumber:[TWICUserManager sharedInstance].currentUser[UserIdKey]])//current user
    {
        if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleCamera)
        {
            [[TWICTokClient sharedInstance] publishVideo:YES audio:YES];
        }
        else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleMicrophone)
        {
            [[TWICTokClient sharedInstance] publishVideo:NO audio:YES];
        }
        else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleScreen)
        {
            //nothing to do on mobile
        }
    }
    else
    {
        if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleCamera)
        {
            //allow user to share his camera
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeCameraRequested toUser:user];
            //update the user
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:user[UserIdKey] toValue:NO];
        }
        else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleMicrophone)
        {
            //allow user to share his microphone
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeMicrophoneRequested toUser:user];
            //update the user
            [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:user[UserIdKey] toValue:NO];
        }
        else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleScreen)
        {
            //decline user to share his microphone
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeScreenRequested toUser:user];
            //update the user
            [[TWICUserManager sharedInstance]setAskPermission:UserAskScreen forUserID:user[UserIdKey] toValue:NO];
        }
    }
    //reload data
    [self refreshData];
    if(self.authorizations.count==0){
        [self.delegate twicAlertViewControllerDidFinish:self];
    }else{
        [self.collectionView reloadData];
    }
}

-(void)twicAlertViewControllerDidCancel:(id)sender{
    NSDictionary *user =((TWICAlertViewController*)sender).user;
    if([user[UserIdKey] isEqualToNumber:[TWICUserManager sharedInstance].currentUser[UserIdKey]] == NO){//not the current user
        if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleCamera)
        {
            //decline user to share his camera
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeCancelCameraAuthorization toUser:user];
            //update the user
            [[TWICUserManager sharedInstance]setAskPermission:UserAskCamera forUserID:user[UserIdKey] toValue:NO];
        }
        else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleMicrophone)
        {
            //decline user to share his microphone
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeCancelMicrophoneAuthorization toUser:user];
            //update the user
            [[TWICUserManager sharedInstance]setAskPermission:UserAskMicrophone forUserID:user[UserIdKey] toValue:NO];
        }
        else if(((TWICAlertViewController*)sender).style == TWICAlertViewStyleScreen)
        {
            //decline user to share his microphone
            [[TWICTokClient sharedInstance]sendSignal:SignalTypeCancelScreenAuthorization toUser:user];
            //update the user
            [[TWICUserManager sharedInstance]setAskPermission:UserAskScreen forUserID:user[UserIdKey] toValue:NO];
        }
    }
    [self refreshData];
    if(self.authorizations.count==0){
       [self.delegate twicAlertViewControllerDidFinish:self];
    }else{
        [self.collectionView reloadData];
    }
}
@end
