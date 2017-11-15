//
//  AccordionHeaderView.h
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import "FZAccordionTableView.h"

static const CGFloat kDefaultAccordionHeaderViewHeight = 70.0;

@interface TWICMenuAccordionHeaderView : FZAccordionTableViewHeaderView


-(void)configureWithUser:(NSDictionary *)user;

-(void)willOpen;
-(void)willClose;
@end
