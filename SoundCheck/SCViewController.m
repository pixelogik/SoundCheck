//
//  SCViewController.m
//  SoundCheck
//
//  Created by Ole Krause-Sparmann on 17.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import "SCViewController.h"

#import <SCSoundCloud.h>
#import <SCUI.h>
#import <SpriteKit/SpriteKit.h>

#import "SCTrackTableViewCell.h"
#import "SCTrackResponse.h"
#import "SCContentSearchController.h"
#import "SCBubbleScene.h"
#import "SCSearchTextField.h"
#import "SCModifiedLoginViewController.h"

@interface SCViewController ()

// Outlets from the storyboard
@property (weak, nonatomic) IBOutlet SKView *spriteView;
@property (weak, nonatomic) IBOutlet UIButton *accountActionButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet SCSearchTextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchIndicatorView;

// The sprite kit scene running in the background
@property (strong, nonatomic) SCBubbleScene *bubbleScene;

// This serial dispatch queue is used to load images for all the tracks
// to avoid too much parallel connections going on. Just one track is
// handled at a time
@property (strong, nonatomic) dispatch_queue_t imageLoadingDispatchQueue;

// The currently logged in account's id
@property (copy, nonatomic) NSString *currentAccountIdentifier;

// The search term used for the current content
@property (copy, nonatomic) NSString *currentSearchTerm;

// We use this dictionary to keep track of which tracks are currently visible
// so that when the track's images do arrive we can update the specific cell only
@property (strong, nonatomic) NSMutableDictionary *trackIdToTableViewCell;

// The cached response for the track search, visualized in the table view
@property (strong, nonatomic) SCTrackResponse *trackResponse;

// These methods style the login/logout button and the table view cells
- (void)styleCell:(SCTrackTableViewCell*)cell;
- (void)styleButton:(UIButton*)button;

// Button actions
- (IBAction)accountAction:(id)sender;
- (IBAction)searchAction:(id)sender;

// The actual login/logout actions
- (void)login;
- (void)logout;

// Requests tracks from API for specified search term
- (void)requestTracksForSearchTerm:(NSString*)searchTerm;

// Search field show/hide
- (void)layoutForHiddenSearch;
- (void)layoutForVisibleSearch;

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Style buttons
    [self styleButton:self.accountActionButton];
    [self styleButton:self.searchButton];
    
    // Create serial dispatch queue for loading images
    self.imageLoadingDispatchQueue = dispatch_queue_create("com.pixelogik.ImageLoading", NULL);
    
    // Create dictionary used to keep track of which tracks are currently visible in the table view
    self.trackIdToTableViewCell = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    // Hide these elements initially
    self.tableView.hidden = YES;
    self.searchButton.hidden = YES;
    self.searchTextField.hidden = YES;
    self.searchIndicatorView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.bubbleScene) {
        // Create background sprite kit scene and add it to the sprite kit view
        self.bubbleScene = [[SCBubbleScene alloc] initWithSize:self.view.bounds.size];
        // Present scene in sprite kit view
        [self.spriteView presentScene:self.bubbleScene];
        // Emit three bubbles ten times a second
        self.bubbleScene.bubbleEmissionFrequency = 20.0;
        
        // Center login button (it has no constraints, we want to animate it around)
        self.accountActionButton.center = CGPointMake(floorf(self.view.bounds.size.width/2.0f), floorf(self.view.bounds.size.height/2.0f));
                
        // Emit some initial bubbles to fill the space quickly
        for (int k=0; k<80; k++) {
            [self.bubbleScene emitBackgroundBubble];
        }
        
        // Layout subviews for hidden search
        [self layoutForHiddenSearch];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button actions

- (IBAction)accountAction:(id)sender {
    
    // If there is a current account, logout
    if (self.currentAccountIdentifier) {
        
        // If the search field is visible, hide it
        if (!self.searchTextField.hidden) {
            [self searchAction:nil];
            // Clear text field for next user
            self.searchTextField.text = @"";
        }
        
        [self logout];
    }
    else {
        // Otherwise login
        [self login];
    }
}

- (IBAction)searchAction:(id)sender
{
    // If the search field is not visible, show it
    if (self.searchTextField.hidden) {
        
        // Show search field and alpha fade
        self.searchTextField.hidden = NO,
        self.searchTextField.alpha = 0.0;
        
        [UIView animateWithDuration:0.4 animations:^{
            // Relayout table view
            [self layoutForVisibleSearch];
            // Fade in search field
            self.searchTextField.alpha = 1.0;
        } completion:^(BOOL done) {
            // Allow the user to start typing right away
            [self.searchTextField becomeFirstResponder];
        }];
    }
    else {
        // Resign first responser / hide keyboard
        [self.searchTextField resignFirstResponder];

        [UIView animateWithDuration:0.4 animations:^{
            // Relayout table view
            [self layoutForHiddenSearch];
            // Fade out search field
            self.searchTextField.alpha = 0.0;
        } completion:^(BOOL done) {
            // Re-enable search button
            self.searchTextField.hidden = YES;
        }];
    }
}

#pragma mark - Styling

- (void)styleButton:(UIButton*)button
{
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.titleLabel.font = [UIFont fontWithName:@"Sintony-Bold" size:16.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.borderWidth = 2;
}

- (void)styleCell:(SCTrackTableViewCell*)cell
{
    cell.backgroundColor = [UIColor clearColor];
    cell.titleLabel.font = [UIFont fontWithName:@"Sintony" size:12.0];
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.usernameLabel.font = [UIFont fontWithName:@"Sintony-Bold" size:16.0];
    cell.usernameLabel.textColor = [UIColor whiteColor];
    cell.artworkImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.artworkImageView.layer.borderWidth = 2;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TrackCell";
    SCTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self styleCell:cell];
    
    if (self.trackResponse && (indexPath.row <= [self.trackResponse.tracks count])) {
        
        // Get track
        SCTrack *track = (SCTrack*)self.trackResponse.tracks[indexPath.row];

        // We do a synchronized write here because the image loading code updates the
        // cell's image view content based on the associated track
        @synchronized(cell) {
            // If this cell was currently visualizing another track, remove it from the mapping dict
            if (cell.trackId) {
                [self.trackIdToTableViewCell removeObjectForKey:cell.trackId];
            }
            
            // Write new track id to cell. This will cause "image update"-blocks to NOT change this cell
            cell.trackId = [track.id stringValue];
        }
        
        // Register cell in dict (again, we use this to update the image views when the track's images do arrive)
        [self.trackIdToTableViewCell setObject:cell forKey:cell.trackId];

        // Set cell content
        cell.titleLabel.text = track.title;
        cell.usernameLabel.text = track.user.username;
        cell.artworkImageView.image = track.artworkImage ? track.artworkImage : [UIImage imageNamed:@"cloud.png"];

        // We do not want to see the selection because the app is left immediately
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.trackResponse) return 0;
    return [self.trackResponse.tracks count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.trackResponse && (indexPath.row <= [self.trackResponse.tracks count])) {
        // Get track from response
        SCTrack *track = (SCTrack*)self.trackResponse.tracks[indexPath.row];
        
        // If the url could not be opened by another application, open it in Safari
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:tracks:%@", track.id]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:track.permalink_url]];
        }
    }
}

#pragma mark - Login / Logout 

- (void)login
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        DLog(@"COMPLETE!!!!");
        if (SC_CANCELED(error)) {
            DLog(@"Canceled!");
        } else if (error) {
            DLog(@"Error: %@", [error localizedDescription]);
        } else {
            // Set current account id so that we know that the user is logged in
            self.currentAccountIdentifier = [SCSoundCloud account].identifier;
            
            // Disable login/logout button for now, until the loading is done / has failed
            self.accountActionButton.enabled = NO;
            
            // Show user that we are loading
            [self.accountActionButton setTitle:@"Loading" forState:UIControlStateNormal];
            
            // Initially show tracks of/with Delphic
            [self requestTracksForSearchTerm:@"Delphic"];
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCModifiedLoginViewController *loginViewController;
        
        loginViewController = (SCModifiedLoginViewController*)[SCModifiedLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (void)logout
{
    // Tell souncloud SDK to remove the acces
    [SCSoundCloud removeAccess];
    // Set this to nil so that we know the user is not logged in
    self.currentAccountIdentifier = nil;
    
    // Animate button relocation and table hiding
    [UIView animateWithDuration:1.0 animations:^{
        CGFloat h = self.accountActionButton.frame.size.height;
        self.accountActionButton.frame = CGRectMake(floorf(self.view.bounds.size.width/2.0f)-100, floorf(self.view.bounds.size.height/2.0f-0.5*h), 200, h);
        
        self.accountActionButton.center = CGPointMake(floorf(self.view.bounds.size.width/2.0f), floorf(self.view.bounds.size.height/2.0f));
        self.accountActionButton.alpha = 1.0;
        self.tableView.alpha = 0.0;
        self.searchButton.alpha = 0.0;
    } completion:^(BOOL done) {
        [self.accountActionButton setTitle:@"Login" forState:UIControlStateNormal];
        self.tableView.hidden = YES;
        self.searchButton.hidden = YES;
    }];
}

#pragma mark - Requesting content

- (void)requestTracksForSearchTerm:(NSString*)searchTerm
{
    // Set this so that we do no longer load images for the old content
    self.currentSearchTerm = searchTerm;
    
    // Show search indicator
    self.searchIndicatorView.hidden = NO;
    self.searchIndicatorView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.searchIndicatorView.alpha = 1.0;
    }];
    
    [SCContentSearchController requestTracksForSearchTerm:searchTerm responseHandler:^(SCTrackResponse *response, NSError *error) {
        
        // In case of failure tell the user about it
        if (!response) {
            // TODO: Tell user
            return;
        }
        
        // Set track response
        self.trackResponse = response;
        
        // Tell table view to reload (with animation if there was content before, looks better)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        // Hide search indicator
        [UIView animateWithDuration:0.3 animations:^{
            self.searchIndicatorView.alpha = 0.0;
        } completion:^(BOOL done) {
            self.searchIndicatorView.hidden = YES;
        }];
        
        // If the table view is hidden, the content ui elements are not visible yet. Show them.
        if (self.tableView.hidden) {
            // Show table view (but fade in)
            self.tableView.hidden = NO;
            self.tableView.alpha = 0.0;
            
            // Show search button (but fade in)
            self.searchButton.hidden = NO;
            self.searchButton.alpha = 0.0;
            
            [UIView animateWithDuration:1.0 animations:^{
                self.accountActionButton.frame = CGRectMake(5, 5, 152, self.accountActionButton.frame.size.height);
                self.tableView.alpha = 1.0;
                self.searchButton.alpha = 1.0;
            } completion:^(BOOL done) {
                [self.accountActionButton setTitle:@"Logout" forState:UIControlStateNormal];
                // Re-enable login/logout button (was disabled during loading of initial content)
                self.accountActionButton.enabled = YES;
            }];
        }
        
        // Enqueue image downloads for all tracks on serial dispatch queue.
        for (SCTrack *track in response.tracks) {
            track.accountId = self.currentAccountIdentifier;

            // Set query string so that IF the user enters another search term very quickly
            // no images are loaded for the previous query
            track.queryString = searchTerm;
            
            dispatch_async(self.imageLoadingDispatchQueue, ^{
                // If the current account is still the one used to request the track,
                // load the images synchronously on the background thread.
                // In case of logout this loading is not performed. Also, if the current search term
                // has changed, do not load images for this track anymore.
                if ([self.currentAccountIdentifier isEqualToString:track.accountId] && [self.currentSearchTerm isEqualToString:track.queryString]) {
                    // First get both images
                    [track loadImagesSynchronously];
                    
                    // If there is an artwork image, scale it down on the background thread. This takes away cpu cycles from
                    // the main thread everytime the table view cell must render it's image view with a new image
                    track.artworkImage = track.artworkImage ? [SCUtils scaleImage:track.artworkImage toSize:CGSizeMake(60, 60)] : nil;
                    
                    // Check if there is currently a cell that visualizes this track.
                    SCTrackTableViewCell *cell = self.trackIdToTableViewCell[[track.id stringValue]];
                    // If so, change image view content of cell
                    if (cell && track.artworkImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Check again that the track id is the same because there is a delay between the
                            // check and the execution of this block. To be super safe, perform synchronized read on cell
                            @synchronized(cell) {
                                if ([cell.trackId isEqualToString:[track.id stringValue]]) {
                                    cell.artworkImageView.image = track.artworkImage;
                                }
                            }
                        });
                    }
                }
            });
        }
    }];
}

#pragma mark - Search field 

- (void)layoutForHiddenSearch
{
    CGSize s = self.view.bounds.size;
    self.tableView.frame = CGRectMake(0, 40, s.width, s.height-40);
    self.searchTextField.frame = CGRectMake(5, 40, s.width-10, 40);
}

- (void)layoutForVisibleSearch
{
    CGSize s = self.view.bounds.size;
    self.tableView.frame = CGRectMake(0, 85, s.width, s.height-85);
    self.searchTextField.frame = CGRectMake(5, 40, s.width-10, 40);
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Request new content
    [self requestTracksForSearchTerm:textField.text];
    
    // Resign first responser / hide keyboard
    [textField resignFirstResponder];

    // Animate search field hide
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutForHiddenSearch];
        self.searchTextField.alpha = 0.0;
    } completion:^(BOOL done) {
        // Hide text field
        self.searchTextField.hidden = YES;
        // Clear text so that the user does not have to do it next time he wants to search
        self.searchTextField.text = @"";
    }];

    return YES;
}

@end
