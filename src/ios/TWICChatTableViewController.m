//
//  TWICChatTableViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 08/06/2017.
//
//

#import "TWICChatTableViewController.h"
#import "TWICChatTableViewCell.h"
#import "Masonry.h"
#import "TWICConstants.h"
#import "TWICMessageManager.h"

@interface TWICChatTableViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat buffer;
@property (nonatomic, assign) BOOL    loadingHistory;
@end

@implementation TWICChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.top = 0;
    self.bottom = self.tableView.contentSize.height - self.tableView.frame.size.height;
    self.buffer = 160;
    
    [self configureSkin];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(newMessage:) name:TWIC_NOTIFICATION_NEW_MESSAGE object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(messagesLoaded:) name:TWIC_NOTIFICATION_MESSAGES_LOADED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(historicalMessagesLoaded:) name:TWIC_NOTIFICATION_HISTORICAL_MESSAGES_LOADED object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(latestMessagesLoaded:) name:TWIC_NOTIFICATION_LATEST_MESSAGES_LOADED object:nil];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

-(void)configureSkin{
    self.tableView.backgroundColor = [UIColor clearColor];
}

-(void)refreshUI{
    if([[TWICMessageManager sharedInstance]allMessages].count > 0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[TWICMessageManager sharedInstance]allMessages].count - 1
                                                                  inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[TWICMessageManager sharedInstance]allMessages].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TWICChatTableViewCell description] forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((TWICChatTableViewCell*)cell) configureWithMessage:[[TWICMessageManager sharedInstance]allMessages][indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static TWICChatTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:[TWICChatTableViewCell description]];
    });
    [cell configureWithMessage:[[TWICMessageManager sharedInstance]allMessages][indexPath.row]];
    return cell.height;
}

#pragma management - Chat Notifications
-(void)newMessage:(NSNotification*)notification{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[TWICMessageManager sharedInstance]allMessages].count - 1
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[TWICMessageManager sharedInstance]allMessages].count - 1
                                                              inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)messagesLoaded:(NSNotification*)notification{
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[TWICMessageManager sharedInstance]allMessages].count - 1
                                                              inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)historicalMessagesLoaded:(NSNotification *)notification{
    if([notification.object boolValue]){//reload ?
        [self.tableView reloadData];
    }
    self.loadingHistory = NO;
}

-(void)latestMessagesLoaded:(NSNotification *)notification{
    if([notification.object boolValue]){//reload ?
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[TWICMessageManager sharedInstance]allMessages].count - 1
                                                                  inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}


#pragma mark - Scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat scrollPosition = scrollView.contentOffset.y;
    if(scrollPosition < self.top+self.buffer && self.loadingHistory == NO)
    {
        self.loadingHistory = YES;
        //load previous messages
        [[TWICMessageManager sharedInstance]loadHistoricalMessages];
    }
}
@end
