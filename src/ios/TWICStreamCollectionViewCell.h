//
//  StreamCollectionViewCell.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>
#import "TWICConstants.h"
#import "TWICStreamViewController.h"

@interface TWICStreamCollectionViewCell : UICollectionViewCell

-(void)configureWithStreamViewController:(TWICStreamViewController*)streamViewController;

@end
