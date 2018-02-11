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
#import <Parse/Parse.h>

@interface ScenicDrivesViewController ()

@end

@implementation ScenicDrivesViewController {
    NSMutableArray *scenicDrivesList;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureThirdPartyFramework];
    
    //Configure Navigation View
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationItem.title = @"PORSCHE2";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Lato-Regular" size:21]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Delegate Setup
    self.tableView.delegate = self;
    
    //[self saveImage];
    [self loadScenicDrives];
}

- (void)configureThirdPartyFramework {
    //Configuring 3rd Party Frameworks
    [Parse initializeWithConfiguration: [ParseClientConfiguration configurationWithBlock: ^ (id < ParseMutableClientConfiguration > _Nonnull configuration) {
        configuration.applicationId = @"PorscheScenicDriveParseAppID";
        configuration.clientKey = @"PorscheScenicDriveParseMasterKey";
        configuration.server = @"https://porsche-scenic-drive.herokuapp.com/parse";
        configuration.localDatastoreEnabled = NO;
    }]];
}

- (void)loadScenicDrives {
    PFQuery *query = [PFQuery queryWithClassName:@"ScenicRoute"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            scenicDrivesList = [[NSMutableArray alloc] init];
            
            for (PFObject *object in objects) {
                
                //TODO: Create custom initializer that takes in PFObject
                ScenicDrives *scenicDriveObject = [[ScenicDrives alloc] init];
                scenicDriveObject.driveName = [object objectForKey:@"driveName"];
                scenicDriveObject.driveRating = [object objectForKey:@"driveRating"];
                scenicDriveObject.driveGasCost = [object objectForKey:@"driveGasCost"];
                scenicDriveObject.driveLengthHours = [object objectForKey:@"driveLengthHours"];
                scenicDriveObject.coverPhotoReference = [object objectForKey:@"coverPhoto"];
                
                //TODO: This is going to be loading images for all of the scenic drives, should only load when cell is visible
                PFFile *coverPhoto = scenicDriveObject.coverPhotoReference;
                if (coverPhoto != NULL) {
                    [coverPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        UIImage *thumbnailImage = [UIImage imageWithData:imageData];
                        scenicDriveObject.coverPhotoImage = thumbnailImage;
                        [self.tableView reloadData];
                    }];
                    
                }
                
                [scenicDrivesList addObject:scenicDriveObject];
            }
            
            NSLog(@"Data loaded: %ld", [scenicDrivesList count]);
            
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)saveImage {
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: @"https://kckratt.com/cache/images/8f6aebecfb22da9a8ec746d48417f9a4.jpg"]];
    PFFile *imageFile = [PFFile fileWithName:@"SewardHighway" data:imageData];
    
    PFObject *userPhoto = [PFObject objectWithClassName:@"ScenicRoute"];
    userPhoto[@"coverPhoto"] = imageFile;
    [userPhoto saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [scenicDrivesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *scenicDriveIdentifier = @"ScenicDrivesCell";
    
    ScenicDrivesTableViewCell *cell = (ScenicDrivesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scenicDriveIdentifier];
    if (cell == nil) {
        cell = [[ScenicDrivesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:scenicDriveIdentifier];
    }
    
    ScenicDrives *currentDriveIndex = [scenicDrivesList objectAtIndex:indexPath.row];
    cell.driveName.text = currentDriveIndex.driveName;
    cell.coverPhoto.image = currentDriveIndex.coverPhotoImage;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 188;
}

#pragma mark - Navigation Bar Settings
- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
