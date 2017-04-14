//
//  StreamCollectionViewCell.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>
#import "TWICConstants.h"

@interface TWICStreamCollectionViewCell : UICollectionViewCell
-(void)configureWithSubscriber:(OTSubscriber*)subscriber;
-(void)configureWithPublisher:(OTPublisher*)publisher;
@end
