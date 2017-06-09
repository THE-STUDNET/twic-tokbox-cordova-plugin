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
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}
@end
