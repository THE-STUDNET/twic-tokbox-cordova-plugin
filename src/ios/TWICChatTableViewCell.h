//
//  TWICChatTableViewCell.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 08/06/2017.
//
//

#import <UIKit/UIKit.h>

@interface TWICChatTableViewCell : UITableViewCell

-(void)configureWithMessage:(NSDictionary *)message;
-(CGFloat)height;
@end
