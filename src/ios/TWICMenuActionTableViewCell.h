//
//  TWICMenuActionTableViewCell.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import <UIKit/UIKit.h>

static const CGFloat kDefaultMenuActionTableViewCellHeight = 50.0;

@interface TWICMenuActionTableViewCell : UITableViewCell

-(void)configureWithAction:(NSDictionary *)action user:(NSDictionary *)user;

@end
