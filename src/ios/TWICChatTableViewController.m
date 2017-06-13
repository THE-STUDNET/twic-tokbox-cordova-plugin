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

@interface TWICChatTableViewController ()


@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation TWICChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self configureSkin];
    
    self.messages = [NSMutableArray array];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(newMessage:) name:TWIC_NOTIFICATION_NEW_MESSAGE object:nil];
}

-(void)dealloc{
    NOTIFICATION_CENTER_REMOVE;
}

-(void)configureSkin{
    self.tableView.backgroundColor = [UIColor clearColor];
}

-(void)configureWithMessages:(NSArray *)messages{
    self.messages = [messages mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TWICChatTableViewCell description] forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((TWICChatTableViewCell*)cell) configureWithMessage:self.messages[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static TWICChatTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:[TWICChatTableViewCell description]];
    });
    [cell configureWithMessage:self.messages[indexPath.row]];
    return cell.height;
}

-(void)twicSocketIOClient:(id)sender didReceiveMessage:(NSDictionary *)messageObject
{
    [self.messages addObject:messageObject];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

-(void)newMessage:(NSNotification*)notification{
    [self.messages addObject:notification.object];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
@end
