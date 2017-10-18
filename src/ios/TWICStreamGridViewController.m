//
//  StreamGridViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICStreamGridViewController.h"
#import "TWICStreamCollectionViewCell.h"
#import "TWICTokClient.h"

@interface TWICStreamGridViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) NSInteger streamCount;
@end

@implementation TWICStreamGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSkin];
    [self refresh];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

-(void)configureSkin{
    self.collectionView.backgroundColor = TWIC_COLOR_GREY;
}

#pragma mark - Keyboard Management
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.collectionView.contentInset = contentInsets;
    self.collectionView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.collectionView.contentInset = contentInsets;
    self.collectionView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Collection view management

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.streamCount ;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TWICStreamCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[TWICStreamCollectionViewCell description]
                                                                                        forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([TWICTokClient sharedInstance].publisher)//publishing
    {
        if(indexPath.row == 0){
            [(TWICStreamCollectionViewCell*)cell configureWithPublisher:[TWICTokClient sharedInstance].publisher];
        }
        else
        {
            NSString *subscriberStreamID = [TWICTokClient sharedInstance].orderedStreamIDs[indexPath.row-1];
            [(TWICStreamCollectionViewCell*)cell configureWithSubscriber:[[TWICTokClient sharedInstance]subscriberForStreamID:subscriberStreamID]];
        }
    }
    else{
        NSString *subscriberStreamID = [TWICTokClient sharedInstance].orderedStreamIDs[indexPath.row];
        [(TWICStreamCollectionViewCell*)cell configureWithSubscriber:[[TWICTokClient sharedInstance]subscriberForStreamID:subscriberStreamID]];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([TWICTokClient sharedInstance].publisher){//publishing
        if(indexPath.row == 0)
        {
            [self.delegate TWICStreamGridViewControllerDidSelectPublisher:self];
        }
        else
        {
            [self.delegate TWICStreamGridViewController:self didSelectSubscriberWithStreamID:[TWICTokClient sharedInstance].orderedStreamIDs[indexPath.row-1]];
        }
    }else{
        [self.delegate TWICStreamGridViewController:self didSelectSubscriberWithStreamID:[TWICTokClient sharedInstance].orderedStreamIDs[indexPath.row]];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(self.streamCount==1){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(50, 10, 50, 10);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //change display following numbers
    if(self.streamCount == 1)
    {
        return CGSizeMake(MAIN_SCREEN.bounds.size.width, MAIN_SCREEN.bounds.size.height);
    }
    else if(self.streamCount == 2)
    {
        return CGSizeMake(MAIN_SCREEN.bounds.size.width-20, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    else if(self.streamCount == 3)
    {
        if(indexPath.row == 2)
        {
            return CGSizeMake(MAIN_SCREEN.bounds.size.width-20, (MAIN_SCREEN.bounds.size.height-100)/2);
        }
        return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    else if(self.streamCount == 4)
    {
        return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/4);
}

-(void)refresh{
    if([TWICTokClient sharedInstance].publisher!=nil){
        self.streamCount = [TWICTokClient sharedInstance].orderedStreamIDs.count + 1;
    }else{
        self.streamCount = [TWICTokClient sharedInstance].orderedStreamIDs.count;
    }
    [self.collectionView reloadData];
}
@end
