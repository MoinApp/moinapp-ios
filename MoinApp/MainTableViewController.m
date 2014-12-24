//
//  MainTableViewController.m
//  MoinApp
//
//  Created by Sören Gade on 14/12/14.
//  Copyright (c) 2014 Sören Gade. All rights reserved.
//

#import "MainTableViewController.h"

static NSString *const ERROR = @"ERROR";

static NSString *const kLoginSegue = @"showLogin";
static NSString *const kMainTableViewCellReuseIdentifier = @"cellUser";
static int const kMainTableViewSectionRecentsId = 0;
static NSString *const kMainTableViewSectionRecentsTitle = @"Your recent contacts";
static int const kMainTableViewSectionServerResultsId = 1;
static NSString *const kMainTableViewSectionServerResultsTitle = @"Server search results";
#define START_SECTION ( ( [self hasSearchResults] ) ? kMainTableViewSectionRecentsId : kMainTableViewSectionRecentsId-1 )

static NSString *const kMainTableViewCodingKeyRecents = @"recents";

@interface MainTableViewController ()
{
    NSArray *recents;
    
    NSArray *filteredResults;
    AFHTTPRequestOperation *searchOperation;
    NSArray *serverSearchResults;
    
    NSTimer *searchDelay;
    
    UIAlertView *alertViewLogout;
}
@end

@implementation MainTableViewController

#pragma mark - Load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self createRefreshControl];
}
- (void)createRefreshControl
{
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlPulled)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self presentLoginViewController];
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

#pragma mark - UIViewController Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:recents forKey:kMainTableViewCodingKeyRecents];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSArray *savedRecents = [coder decodeObjectForKey:kMainTableViewCodingKeyRecents];
    
    [self updateRecentsWithArray:savedRecents];
}

#pragma mark - Memory

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
}

#pragma mark - Table view
#pragma mark Data source

- (BOOL)hasRecents
{
    return ( recents && recents.count > 0 );
}
- (BOOL)hasSearchResults
{
    return ( filteredResults && filteredResults.count > 0 );
}
- (BOOL)hasServerResults
{
    return ( serverSearchResults && serverSearchResults.count > 0 );
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    int counter = 0;
    
    if ( tableView == self.tableView ) {
        
        if ( [self hasRecents] ) {
            if ( [self hasSearchResults] ) {
                counter = 1;
            }
        }
        
        if ( counter == 0 ) {
            // If we have no data to display
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            label.textColor = [UIColor grayColor];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            
            if ( ![self hasSearchResults] ) {
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
        
    } else {
        
        if ( [self hasSearchResults] ) {
            counter++;
        }
        if ( [self hasServerResults] ) {
            counter++;
        }
        
    }
    
    return counter;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ( tableView == self.tableView ) {
        return [filteredResults count];
    } else {
        
        int idRecents = START_SECTION + kMainTableViewSectionRecentsId;
        int idServer = START_SECTION + kMainTableViewSectionServerResultsId;
        
        if ( section == idRecents ) {
            return [filteredResults count];
        } else if ( section == idServer ) {
            return [serverSearchResults count];
        }
        
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( tableView == self.tableView ) {
        return kMainTableViewSectionRecentsTitle;
    } else {
        
        int idRecents = START_SECTION + kMainTableViewSectionRecentsId;
        int idServer = START_SECTION + kMainTableViewSectionServerResultsId;
        
        if ( section == idRecents ) {
            return kMainTableViewSectionRecentsTitle;
        } else if ( section == idServer ) {
            return kMainTableViewSectionServerResultsTitle;
        }
        
    }
    
    return @"ERROR";
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
    int idRecents = START_SECTION + kMainTableViewSectionRecentsId;
    int idServer = START_SECTION + kMainTableViewSectionServerResultsId;
    if ( indexPath.section == idRecents ) {
        user = [filteredResults objectAtIndex:indexPath.item];
    } else if ( indexPath.section == idServer ) {
        user = [serverSearchResults objectAtIndex:indexPath.item];
    }
    
    // fill in the data
    cell.textLabel.text = user.username;
    
    UIImage *profileImage = [user profileImage];
    if ( !profileImage ) {
        
        __block UITableViewCell *_cell = cell;
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
    cell.imageView.clipsToBounds = YES;
    cell.imageView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark Table view events

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *selectedUser = nil;
    
    int idRecents = START_SECTION + kMainTableViewSectionRecentsId;
    int idServer = START_SECTION + kMainTableViewSectionServerResultsId;
    
    if ( indexPath.section == idRecents ) {
        selectedUser = [filteredResults objectAtIndex:indexPath.item];
    } else if ( indexPath.section == idServer ) {
        selectedUser = [serverSearchResults objectAtIndex:indexPath.item];
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

- (void)filterRecentsByUsernameWithText:(NSString *)searchText
{
    // cancel pending operations
    if ( searchOperation.isExecuting ) {
        [searchOperation cancel];
    }
    if ( searchDelay.isValid ) {
        [searchDelay invalidate];
    }
    
    if ( [searchText isEqualToString:@""] ) {
        [self updateRecentsWithArray:recents];
        return;
    }
    
    // search in recents
    NSString *usernameFilter = [NSString stringWithFormat:@"*%@*", searchText];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username LIKE[cd] %@)", usernameFilter];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:recents];
    filteredResults = [array filteredArrayUsingPredicate:predicate];
    
    // search on the server (after delay)
    serverSearchResults = nil;
    
    searchDelay = [NSTimer scheduledTimerWithTimeInterval:[Constants searchDelay]
                                                   target:self
                                                 selector:@selector(performServerSearch:)
                                                 userInfo:searchText
                                                  repeats:NO];
    
    [self reloadSearchTableView];
}
- (void)performServerSearch:(NSTimer *)timer
{
    NSString *searchText = timer.userInfo;
    searchDelay = nil;
    
    APIClient *client = [APIClient client];
    searchOperation = [client getUsersWithUsername:searchText completion:^(APIError *error, id data) {
        
        if ( ( !error && !data ) || ( error.error.code == -999 ) ) {
            // we were cancelled
            return;
        }
        
        if ( ![APIErrorHandler handleError:error] ) {
            
            NSMutableArray *users = [NSMutableArray arrayWithArray:(NSArray *)data];
            
            if ( users ) {
                // remove recents from server results
                for ( User* recentUser in recents) {
                    NSString *usernameFilter = [NSString stringWithFormat:@"%@", recentUser.username];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(NOT username LIKE[cd] %@)", usernameFilter];
                    
                    [users filterUsingPredicate:predicate];
                }
                
                serverSearchResults = [users copy];
                
                [self reloadSearchTableView];
                
            }
            
        }
        
    }];
}
- (void)reloadSearchTableView
{
    // TODO: fix this without deprecation!
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.searchDisplayController.searchResultsTableView reloadData];
#pragma clang diagnostic pop
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

- (BOOL)isReloadingRecents
{
    return ( [self.refreshControl isRefreshing] );
}
- (void)reloadRecentUsers
{
    if ( [self isReloadingRecents] ) {
        return;
    }
    
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
        }
        
        [self.refreshControl endRefreshing];
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
