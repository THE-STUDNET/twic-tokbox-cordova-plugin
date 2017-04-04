//
//  TWICMenuViewController.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 04/04/2017.
//
//

#import "TWICMenuViewController.h"
#import "FZAccordionTableView.h"
#import "TWICConstants.h"
#import "TWICMenuActionTableViewCell.h"
#import "TWICMenuAccordionHeaderView.h"

@interface TWICMenuViewController ()<UITableViewDelegate,UITableViewDataSource,FZAccordionTableViewDelegate>
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

//data
@property (strong, nonatomic) NSMutableArray <NSDictionary *> *users;
@end

@implementation TWICMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //accordion view
    [self.tableView registerNib:[UINib nibWithNibName:@"TWICMenuAccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:[TWICMenuAccordionHeaderView description]];
    
    [self configureSkin];
    
    [self refreshData];
    
    [self refreshUI];
}

-(void)refreshData{
    self.users = [NSMutableArray array];
    [self.users addObject:@{TWIC_USER_AVATAR_URL_KEY:@"http://allmygym.wywiwyg.net:5002/1.0/avatar/100/100/1",
                            TWIC_USER_FIRSTNAME_KEY:@"Jeremy",
                            TWIC_USER_LASTNAME_KEY:@"Hones",
                            TWIC_USER_ACTIONS_KEY:@[@{TWIC_USER_ACTION_TITLE_KEY:@"Send a direct message to Marc",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"chat"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Send a request for the camera",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"camera"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Send a request for the microphone",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"microphone"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Send a request for screen sharing",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"screen"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Kick Marc from the live",
                                                      TWIC_USER_ACTION_IS_ADMIN_KEY:@(1)}]}];
    [self.users addObject:@{TWIC_USER_AVATAR_URL_KEY:@"http://allmygym.wywiwyg.net:5002/1.0/avatar/100/100/1",
                            TWIC_USER_FIRSTNAME_KEY:@"Jeremy",
                            TWIC_USER_LASTNAME_KEY:@"Hones",
                            TWIC_USER_ACTIONS_KEY:@[@{TWIC_USER_ACTION_TITLE_KEY:@"Send a direct message to Marc",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"chat"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Send a request for the camera",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"camera"}]}];
    [self.users addObject:@{TWIC_USER_AVATAR_URL_KEY:@"http://allmygym.wywiwyg.net:5002/1.0/avatar/100/100/1",
                            TWIC_USER_FIRSTNAME_KEY:@"Jeremy",
                            TWIC_USER_LASTNAME_KEY:@"Hones",
                            TWIC_USER_ACTIONS_KEY:@[@{TWIC_USER_ACTION_TITLE_KEY:@"Send a direct message to Marc",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"chat"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Send a request for the camera",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"camera"},
                                                    @{TWIC_USER_ACTION_TITLE_KEY:@"Send a request for the microphone",
                                                      TWIC_USER_ACTION_IMAGE_KEY:@"microphone"}]}];
}

-(void)refreshUI{
    self.titleLabel.text = [NSString stringWithFormat:@"%d Members",self.users.count];
}

-(void)configureSkin{
    self.view.backgroundColor = CLEAR_COLOR;
    self.headerView.backgroundColor = CLEAR_COLOR;
    self.closeButton.backgroundColor = CLEAR_COLOR;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = TWIC_ALPHA;
    self.closeButton.backgroundColor = CLEAR_COLOR;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma TableView Management
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *user = self.users[section];
    NSArray *actions = user[TWIC_USER_ACTIONS_KEY];
    return [actions count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kDefaultMenuActionTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDefaultAccordionHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *user = self.users[indexPath.section];
    NSDictionary *action = [user[TWIC_USER_ACTIONS_KEY] objectAtIndex:indexPath.row];
    TWICMenuActionTableViewCell *cell = nil;
    if(action[TWIC_USER_ACTION_IS_ADMIN_KEY]){
        cell = (TWICMenuActionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Admin%@",[TWICMenuActionTableViewCell description]] forIndexPath:indexPath];
    }else{
        cell = (TWICMenuActionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[TWICMenuActionTableViewCell description] forIndexPath:indexPath];
    }
    
    [cell configureWithAction:action user:user];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TWICMenuAccordionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[TWICMenuAccordionHeaderView description]];
    NSDictionary *user = self.users[section];
    [headerView configureWithUser:user];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate){
        NSDictionary *user = self.users[indexPath.section];
        NSDictionary *action = [user[TWIC_USER_ACTIONS_KEY] objectAtIndex:indexPath.row];
        [self.delegate TWICMenuViewController:self didSelectAction:action forUser:user];
    }
}
#pragma mark - <FZAccordionTableViewDelegate> -

- (BOOL)tableView:(FZAccordionTableView *)tableView canInteractWithHeaderAtSection:(NSInteger)section {
    //has actions ?
    NSDictionary *user = self.users[section];
    if([user[TWIC_USER_ACTIONS_KEY]count] > 0){
        return YES;
    }
    return NO;
}

@end
