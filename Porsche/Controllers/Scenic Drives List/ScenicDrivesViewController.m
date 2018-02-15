//
//  ScenicDrivesViewController.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/9/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "ScenicDrivesViewController.h"
#import "ScenicDrives.h"
#import "ScenicDrivesTableViewCell.h"
#import "MainMapViewController.h"


@interface ScenicDrivesViewController ()

@property (strong, nonatomic) NSMutableArray *scenicDrivesList;

@end


@implementation ScenicDrivesViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Delegate Setup
    self.tableView.delegate = self;

    //Data Fetch
    [self loadScenicDrives];


    //Configure Navigation Bar and Navigation View
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PorscheName"]];

    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                   NSFontAttributeName : [UIFont fontWithName:CUSTOM_FONT_REGULAR size:NAV_BAR_FONT_SIZE]}];

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Parse API
- (void)loadScenicDrives
{
    PFQuery *query = [PFQuery queryWithClassName:@"ScenicRoute"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.scenicDrivesList = [[NSMutableArray alloc] init];

            for (PFObject *object in objects) {
                ScenicDrives *scenicDriveObject = [[ScenicDrives alloc] init];
                [scenicDriveObject configureFromParseObject:object sourceTableView:self.tableView];
                [self.scenicDrivesList addObject:scenicDriveObject];
            }

            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Table View Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scenicDrivesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *scenicDriveIdentifier = @"ScenicDrivesCell";

    ScenicDrivesTableViewCell *cell = (ScenicDrivesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scenicDriveIdentifier];
    if (cell == nil) {
        cell = [[ScenicDrivesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:scenicDriveIdentifier];
    }

    ScenicDrives *currentDriveIndex = [self.scenicDrivesList objectAtIndex:indexPath.row];
    [cell configureFromScenicDrives:currentDriveIndex];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return STANDARD_SCENIC_DRIVE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"openMapViewSegue" sender:self];
}

#pragma mark - Navigation Bar Settings
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation Settings
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openMapViewSegue"]) {
        MainMapViewController *vc = [segue destinationViewController];

        ScenicDrives *selectedDrive = [self.scenicDrivesList objectAtIndex:self.tableView.indexPathForSelectedRow.row];

        MBWaypoint *destinationWaypoint = [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake([selectedDrive.latitude doubleValue], [selectedDrive.longitude doubleValue]) coordinateAccuracy:-1 name:selectedDrive.driveName];
        [vc setDestinationWaypoint:destinationWaypoint];
    }
}
@end
