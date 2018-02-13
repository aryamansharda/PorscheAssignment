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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.waypointsList = [[NSMutableArray alloc] init];
    
    Waypoint *waypoint = [[Waypoint alloc] init];
    waypoint.addressTitle = @"Home";
    waypoint.addressDetail = @"Your Current Location";
    [self.waypointsList addObject:waypoint];
    
    self.tableView.delegate = self;
    [self.tableView setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Action Methods
- (IBAction)startNavigationTapped:(id)sender {
    [self performSegueWithIdentifier:@"loadCustomRouteDirections" sender:self];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Length: %ld", [self.localSearchResults.mapItems count]);
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.localSearchResults.mapItems count];
    } else {
        return [self.waypointsList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        static NSString *IDENTIFIER = @"SearchResultsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }
        
        MKMapItem *item = self.localSearchResults.mapItems[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[item placemark] name]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[item placemark] title]];
        
        return cell;
    } else {
        static NSString *IDENTIFIER = @"WaypointsCell";
        WaypointsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[WaypointsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }
        
        Waypoint *waypoint = [self.waypointsList objectAtIndex:indexPath.row];
        cell.addressLabel.text = waypoint.addressTitle;
        cell.addressLabel.layer.cornerRadius = 5.0;
        cell.addressLabel.clipsToBounds = YES;
        cell.icon.image = [UIImage imageNamed:@"MapIcon"];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        MKMapItem *item = self.localSearchResults.mapItems[indexPath.row];
        NSLog(@"MAP ITEM: %@", item.description);
        
        Waypoint *waypoint = [[Waypoint alloc] init];
        waypoint.addressTitle = [[item placemark] name];
        waypoint.addressDetail = [[item placemark] title];
        waypoint.coordinate =  [[item placemark] coordinate];
        [self.waypointsList addObject:waypoint];
        [self.tableView reloadData];
        
        [self.searchDisplayController setActive:NO animated:YES];
        [self.numberOfDestinationsLabel setText:[NSString stringWithFormat:@"%ld STOPS", [self.waypointsList count]]];
    }
}

#pragma mark - Search delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchText;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil || [response.mapItems count] == 0) {
            return;
        }
    
        self.localSearchResults = response;
        [self.tableView reloadData];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.waypointsList exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

#pragma mark - View Controller Delegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loadCustomRouteDirections"]) {
        
        //TODO: Combine this with the table view's data source
        NSMutableArray<MBWaypoint *> *allRouteWaypoints = [[NSMutableArray alloc] init];
        for (int x = 1; x < [self.waypointsList count]; x++) {
            Waypoint *waypoint = [self.waypointsList objectAtIndex:x];
            [allRouteWaypoints addObject:[[MBWaypoint alloc] initWithCoordinate:waypoint.coordinate coordinateAccuracy:-1 name:waypoint.addressTitle]];
        }
        
        MainMapViewController *vc = [segue destinationViewController];
        [vc setAllRouteWaypoints:allRouteWaypoints];
    }
}
@end
