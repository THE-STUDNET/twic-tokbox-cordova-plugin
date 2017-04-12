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
#import "TWICStreamViewController.h"

@interface TWICStreamGridViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *streamViewControllers;
@end

@implementation TWICStreamGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.streamViewControllers = [NSMutableArray array];
    
    //add the publisher
    TWICStreamViewController *twicStreamViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
    [self.streamViewControllers addObject:twicStreamViewController];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
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
    return self.streamViewControllers.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TWICStreamCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[TWICStreamCollectionViewCell description]
                                                                                        forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    TWICStreamViewController *streamViewController = self.streamViewControllers[indexPath.row];
    [(TWICStreamCollectionViewCell*)cell configureWithStreamViewController:self.streamViewControllers[indexPath.row]];
    if(indexPath.row == 0){
        [streamViewController startPublishing];
    }else{
        [streamViewController connectStream];
    }    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self.delegate TWICStreamGridViewControllerDidSelectPublisherStream:self];
    }
    else
    {
        TWICStreamViewController *vc = self.streamViewControllers[indexPath.row];
        [self.delegate TWICStreamGridViewController:self didSelectStream:vc.stream];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(self.streamViewControllers.count==1){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(50, 10, 50, 10);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //change display following numbers
    if(self.streamViewControllers.count == 1)
    {
        return CGSizeMake(MAIN_SCREEN.bounds.size.width, MAIN_SCREEN.bounds.size.height);
    }
    else if(self.streamViewControllers.count == 2)
    {
        return CGSizeMake(MAIN_SCREEN.bounds.size.width-20, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    else if(self.streamViewControllers.count == 3)
    {
        if(indexPath.row == 2)
        {
            return CGSizeMake(MAIN_SCREEN.bounds.size.width-20, (MAIN_SCREEN.bounds.size.height-100)/2);
        }
        return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    else if(self.streamViewControllers.count == 4)
    {
        return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/2);
    }
    return CGSizeMake((MAIN_SCREEN.bounds.size.width-30)/2, (MAIN_SCREEN.bounds.size.height-100)/4);
}

#pragma mark - Stream Management
-(void)addStreams:(NSMutableArray*)streams
{
    for(OTStream *stream in streams)
    {
        TWICStreamViewController *twicStreamViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
        [twicStreamViewController configureWithStream:stream];
        [self.streamViewControllers addObject:twicStreamViewController];
    }
    [self.collectionView reloadData];
}

-(void)addStream:(OTStream*)stream
{
    TWICStreamViewController *twicStreamViewController = [TWIC_STORYBOARD instantiateViewControllerWithIdentifier:[TWICStreamViewController description]];
    [twicStreamViewController configureWithStream:stream];
    [self.streamViewControllers addObject:twicStreamViewController];
    [self.collectionView reloadData];
}

-(void)removeStream:(OTStream*)stream
{
    [self.streamViewControllers enumerateObjectsUsingBlock:^(TWICStreamViewController*  _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        if([vc.stream.streamId isEqualToString:stream.streamId])
        {
            [vc disconnect];
            [self.streamViewControllers removeObjectAtIndex:idx];
        }
    }];
    [self.collectionView reloadData];
}

-(void)removeAllStreams
{
    [self.streamViewControllers enumerateObjectsUsingBlock:^(TWICStreamViewController*  _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [vc disconnect];
    }];
    [self.streamViewControllers removeAllObjects];
    [self.collectionView reloadData];
}
@end
