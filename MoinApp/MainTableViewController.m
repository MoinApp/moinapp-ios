//
//  MainTableViewController.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "MainTableViewController.h"

static int const kSearchBarHeight = 44;

static NSString *const ERROR = @"ERROR";

static NSString *const kLoginSegue = @"showLogin";
static NSString *const kMainTableViewCellReuseIdentifier = @"cellUser";
static int const kMainTableViewSectionRecentsId = 0;
static NSString *const kMainTableViewSectionRecentsTitle = @"Your recent contacts";
static int const kMainTableViewSectionServerResultsId = 1;
static NSString *const kMainTableViewSectionServerResultsTitle = @"Server search results";

@interface MainTableViewController ()
{
    NSArray *recents;
    
    NSArray *filteredResults;
    AFHTTPRequestOperation *searchOperation;
    NSArray *serverSearchResults;
    
    UIAlertView *alertViewLogout;
}
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self createRefreshControl];
    [self hideSearchBar];
    
    [self presentLoginViewController];
}
- (void)createRefreshControl
{
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlPulled)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)hideSearchBar
{
    // hide the searchbar at first
    [self.tableView setContentOffset:CGPointMake(0, kSearchBarHeight) animated:YES];
}

- (void)presentLoginViewController
{
    NSString *session = [[APIClient client] session];
    if ( session == nil ) {
        [[self navigationController] performSegueWithIdentifier:kLoginSegue sender:self];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self reloadRecentUsers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadRecentUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // --- Remove References ---
    // we can do this because before we do the next reload
    //   we will get or filter data first
    // Attention: DO NOT remove recents, as this will be
    //   filtered on and the recents are only refreshed on "moin"
    [self clearUnimportantMemory];
}
- (void)clearUnimportantMemory
{
    filteredResults = nil;
    serverSearchResults = nil;
    searchOperation = nil;
    
    // TODO: check if this really doesn't break anything!
    // first check seems ok
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    int counter = 0;
    
    // only show sections that acutally have relevant content for the user
    if ( filteredResults ) {
        if ( filteredResults.count > 0 || serverSearchResults.count > 0  ) {
            counter++;
        }
    }
    if ( serverSearchResults ) {
        if ( serverSearchResults.count > 0 ) {
            counter++;
        }
    }
    
    
    if ( counter == 0 ) {
        // If we have no data to display
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        
        if ( !recents ) {
            label.text = @"Loading data. Please wait...";
        } else {
            label.text = @"You have no recents contacts. Search for a user in the search box!";
        }
        
        [label sizeToFit];
        
        self.tableView.backgroundView = label;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if ( self.tableView.backgroundView != nil ) {
            self.tableView.backgroundView = nil;
        }
    }
    return counter;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case kMainTableViewSectionRecentsId:
            return [filteredResults count];
            break;
        case kMainTableViewSectionServerResultsId:
            return [serverSearchResults count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kMainTableViewSectionRecentsId:
            return kMainTableViewSectionRecentsTitle;
            break;
            
        case kMainTableViewSectionServerResultsId:
            return kMainTableViewSectionServerResultsTitle;
            break;
            
        default:
            return ERROR;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    /* if ( tableView == self.tableView ) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kMainTableViewCellReuseIdentifier forIndexPath:indexPath];
    }  */
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMainTableViewCellReuseIdentifier];
        cell.textLabel.text = @"Username";
    }
    
    // Configure the cell...
    cell.backgroundColor = [UIColor clearColor];
    
    User *user = nil;
    // get the user object
    switch (indexPath.section) {
        case kMainTableViewSectionRecentsId:
            user = [filteredResults objectAtIndex:indexPath.item];
            break;
            
        case kMainTableViewSectionServerResultsId:
            user = [serverSearchResults objectAtIndex:indexPath.item];
            break;
    }
    
    // fill in the data
    cell.textLabel.text = user.username;
    
    UIImage *profileImage = [user profileImage];
    if ( !profileImage ) {
        
        __block UITableViewCell *_cell = cell;
        NSLog(@"Getting image from %@", user.gravatarImageURL);
        NSURLRequest* request = [NSURLRequest requestWithURL:[user gravatarImageURL]];
        [cell.imageView setImageWithURLRequest:request
                              placeholderImage:[User placeholderImage]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           // save the image
                                           [user setProfileImage:image];
                                           // show the image
                                           _cell.imageView.image = image;
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"Error loading image for %@.", user.username);
                                       }];
        
    } else {
        cell.imageView.image = profileImage;
    }
    
    return cell;
}

#pragma mark - Table view events

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *selectedUser = nil;
    
    switch (indexPath.section) {
        case kMainTableViewSectionRecentsId:
            selectedUser = [filteredResults objectAtIndex:indexPath.item];
            break;
            
        case kMainTableViewSectionServerResultsId:
            selectedUser = [serverSearchResults objectAtIndex:indexPath.item];
            break;
    }
    
    [self sendMoinToUser:selectedUser];
}

#pragma mark - UINavigationBar

- (IBAction)buttonLogout:(UIBarButtonItem *)sender {
    alertViewLogout = [[UIAlertView alloc] initWithTitle:@"Logout"
                               message:@"Are you sure you want to logout?"
                               delegate:self
                     cancelButtonTitle:@"No"
                     otherButtonTitles:@"Yes", nil];
    
    [alertViewLogout show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( alertView == alertViewLogout ) {
        // remove reference
        alertViewLogout = nil;
        
        if ( buttonIndex == 0 ) {
            // cancel
        } else if ( buttonIndex == 1 ) { // Yes
            [self logout];
        }
    }
}

#pragma mark - UIRefreshControl

- (void)refreshControlPulled
{
    [self reloadRecentUsers];
}

#pragma mark - Search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterRecentsByUsernameWithText:searchText];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self filterRecentsByUsernameWithText:nil];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self filterRecentsByUsernameWithText:nil];
}

- (void)filterRecentsByUsernameWithText:(NSString *)searchText
{
    if ( searchOperation.isExecuting ) {
        [searchOperation cancel];
    }
    
    if ( !searchText || [searchText isEqualToString:@""] ) {
        [self updateRecentsWithArray:recents];
        searchOperation = nil;
        serverSearchResults = nil;
    } else {
        // search in recents
        NSString *usernameFilter = [NSString stringWithFormat:@"*%@*", searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username like %@)", usernameFilter];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:recents];
        filteredResults = [array filteredArrayUsingPredicate:predicate];
        
        // search on the server...
        serverSearchResults = nil;
        APIClient *client = [APIClient client];
        searchOperation = [client getUsersWithUsername:searchText completion:^(APIError *error, id data) {
            
            if ( !error && !data ) {
                // we were cancelled
                return;
            }
            
            if ( ![APIErrorHandler handleError:error] ) {
                
                NSMutableArray *users = [NSMutableArray arrayWithArray:(NSArray *)data];
                
                if ( users ) {
                    // remove recents from server results
                    for ( User* recentUser in recents) {
                        NSString *usernameFilter = [NSString stringWithFormat:@"*%@*", recentUser.username];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username like %@)", usernameFilter];
                        
                        [users filterUsingPredicate:predicate];
                    }
                    
                    serverSearchResults = [users copy];
                    
                    // TODO: fix this without deprecation!
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [self.searchDisplayController.searchResultsTableView reloadData];
#pragma clang diagnostic pop
                    
                }
                
            }
            
        }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Server Interaction

- (void)logout
{
    [[APIClient client] logoutWithCompletion:^(APIError *error, id data) {
        if ( error ) {
            [[[UIAlertView alloc] initWithTitle:@"We're sorry"
                                        message:error.error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];
        } else {
            
            recents = nil;
            [self clearUnimportantMemory];
            [self presentLoginViewController];
            
        }
    }];
}

- (void)sendMoinToUser:(User *)user
{
    __block HTProgressHUD *progressHUD = [[HTProgressHUD alloc] init];
    progressHUD.animation = [HTProgressHUDFadeZoomAnimation animation];
    [progressHUD.textLabel setText:@"Sending moin..."];
    
    [progressHUD showInView:self.view animated:YES];
    
    // resign first responder so the view does not seem to break
    if ( self.searchBar.isFirstResponder ) {
        [self.searchBar resignFirstResponder];
    }
    
    [[APIClient client] moinUser:user completion:^(APIError *error, id data) {
        
        if ( ![APIErrorHandler handleError:error] ) {
            
            BOOL success = [(NSNumber*)data boolValue];
            NSString *message = nil;
            
            if ( success ) {
                message = @"Success";
            } else {
                NSLog(@"%@", error);
                message = [NSString stringWithFormat:@"%@", [error.response objectForKey:@"message"]];
            }
            [progressHUD setText:message];
            [progressHUD hideAfterDelay:1.2 animated:YES];
            
            [self reloadRecentUsers];
            
        }
    }];
}

- (void)reloadRecentUsers
{
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [[APIClient client] getRecentsWithCompletion:^(APIError *error, id data) {
        
        if ( error.error.code == [APIErrorHandler errorNotAuthorized].error.code ) {
            return;
        }
        
        if ( ![APIErrorHandler handleError:error] ) {
            
            NSArray *recentUsers = (NSArray *)data;
            
            [self updateRecentsWithArray:recentUsers];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterMediumStyle];
            NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
            
            NSString *text = [NSString stringWithFormat:@"Last refresh: %@", dateString];
            
            [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:text]];
            [self.refreshControl endRefreshing];
            
        }
    }];
}
- (void)updateRecentsWithArray:(NSArray *)recentUsers
{
    if ( !recentUsers ) {
        return;
    }
    
    if ( recentUsers != recents ) {
        // sort by username
        NSArray *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES], nil];
        recents = [recentUsers sortedArrayUsingDescriptors:sortDescriptors];
        
        if ( recents.count > 0 ) {
            [self hideSearchBar];
        }
    }
    
    filteredResults = [NSArray arrayWithArray:recents];
    
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
