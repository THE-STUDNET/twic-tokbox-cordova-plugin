//
//  StreamGridViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICStreamGridViewController.h"
#import "TWICStreamCollectionViewCell.h"
#import "TWICConstants.h"

@interface TWICStreamGridViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation TWICStreamGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TWICStreamCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[TWICStreamCollectionViewCell description] forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [(TWICStreamCollectionViewCell*)cell configureWithData:self.data[indexPath.row]];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate TWICStreamGridViewController:self didSelectData:self.data[indexPath.row]];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(124*MAIN_SCREEN.bounds.size.width/320, 156*MAIN_SCREEN.bounds.size.width/320);
}

@end
