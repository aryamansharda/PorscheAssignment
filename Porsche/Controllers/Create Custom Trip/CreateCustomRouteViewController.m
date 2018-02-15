//
//  CreateCustomRouteViewController.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "CreateCustomRouteViewController.h"
#import "Waypoint.h"
#import "WaypointsTableViewCell.h"
#import "MainMapViewController.h"


@interface CreateCustomRouteViewController ()

@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) MKLocalSearchResponse *localSearchResults;
@property (strong, nonatomic) NSMutableArray *waypointsList;

@end


@implementation CreateCustomRouteViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Creates dummy waypoint object to initialize table view with
    Waypoint *waypoint = [[Waypoint alloc] init];
    waypoint.addressTitle = @"Home";
    waypoint.addressDetail = @"Your Current Location";

    //Creates list to contain all user defined destination waypoints
    self.waypointsList = [[NSMutableArray alloc] init];
    [self.waypointsList addObject:waypoint];

    //Allow reordering of table view and sets up delegates
    self.tableView.delegate = self;
    [self.tableView setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - User Action Methods
- (IBAction)startNavigationTapped:(id)sender
{
    //Transitions to the DriveExperienceBaseViewController
    [self performSegueWithIdentifier:@"loadCustomRouteDirections" sender:self];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Returns a different row count based off table view source
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //All results from search query
        return [self.localSearchResults.mapItems count];
    } else {
        return [self.waypointsList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If the user is currently executing a query in the search bar
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        //A standard table view cell suffices here
        static NSString *IDENTIFIER = @"SearchResultsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }

        //Populate table view cell from MKLocalSearch results
        MKMapItem *item = self.localSearchResults.mapItems[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[item placemark] name]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[item placemark] title]];

        return cell;
    } else {
        
        //Used when a user has added a new destination to their trip
        static NSString *IDENTIFIER = @"WaypointsCell";
        WaypointsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[WaypointsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }

        //Populate table view cell data and appearance with information in Waypoint object
        Waypoint *waypoint = [self.waypointsList objectAtIndex:indexPath.row];
        [cell configureFromWaypoint:waypoint];

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //User selected an entry in the search results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        MKMapItem *item = self.localSearchResults.mapItems[indexPath.row];

        //Create Waypoint object based off entry the user selected in the search results
        Waypoint *waypoint = [[Waypoint alloc] init];
        [waypoint configureFromMKMapItem:item];
        
        //Add to list of route waypoints/destinations and reload table view data
        [self.waypointsList addObject:waypoint];
        [self.tableView reloadData];

        //Dismiss search display controller with animation to reveal table view
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.searchDisplayController setActive:NO animated:YES];

        //Update number of stops along custom trp
        [self.numberOfDestinationsLabel setText:[NSString stringWithFormat:@"%ld STOPS", [self.waypointsList count]]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configures cell editing style
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Allows dragging and reordering of table view cells
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Prevents automatic indentation of table view cells when editing
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //If user reorders cell, swap respective indices in data source
    [self.waypointsList exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return STANDARD_WAYPOINTS_CELL_HEIGHT;
}

#pragma mark - Search delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //Searches for matching locations to query using Apple's MKLocalSearchRequest
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchText;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    //Display results in search display controller's table view once complete
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (error != nil || [response.mapItems count] == 0) {
            return;
        }

        //Maintain reference to most recent search results
        self.localSearchResults = response;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

#pragma mark - View Controller Delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Convery Waypoints to MBWaypoint type before transitioning to new view
    if ([[segue identifier] isEqualToString:@"loadCustomRouteDirections"]) {
        
        //MBWaypoint type used by MapBox to compute driving path
        NSMutableArray<MBWaypoint *> *allRouteWaypoints = [[NSMutableArray alloc] init];
        for (int x = 1; x < [self.waypointsList count]; x++) {
            Waypoint *waypoint = [self.waypointsList objectAtIndex:x];
            [allRouteWaypoints addObject:[[MBWaypoint alloc] initWithCoordinate:waypoint.coordinate coordinateAccuracy:-1 name:waypoint.addressTitle]];
        }

        //Display new view controller configured with MBWaypoints array of waypoints along trip
        MainMapViewController *vc = [segue destinationViewController];
        [vc setAllRouteWaypoints:allRouteWaypoints];
    }
}
@end
