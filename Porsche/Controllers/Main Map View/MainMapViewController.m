//
//  MainMapViewController.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "MainMapViewController.h"
#import "ParkingGarages.h"
#import "LSFloatingActionMenu.h"
#import "DriveExperienceBaseViewController.h"
#import <Photos/Photos.h>


@interface MainMapViewController ()

@property (strong, nonatomic) LSFloatingActionMenu *actionMenu;
@property (strong, nonatomic) NSTimer *videoTimer;
@property (strong, nonatomic) NSMutableArray *parkingGaragesList;
@property (strong, nonatomic) __block NSDictionary *currentVideo;

@end


@implementation MainMapViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Configures map view data and display
    [self loadMapView];
    
    //Pull parking garage information from Parse
    [self loadParkingGarages];
}

- (void)viewDidAppear:(BOOL)animated
{
    //Compute route from passed in start and end destinations
    [self populateMapFromData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions and User Interaction Methods
- (IBAction)onTopLeftButtonClicked:(UIButton *)sender
{
    //Floating button was pressed
    [self showMenuFromButton:sender withDirection:LSFloatingActionMenuDirectionUp];
}

- (void)showMenuFromButton:(UIButton *)button withDirection:(LSFloatingActionMenuDirection)direction
{
    button.hidden = YES;
    
    NSArray *menuIcons = @[ @"PlusIcon", @"ParkingIcon" ];
    NSMutableArray *menus = [NSMutableArray array];
    
    //Creating a series of floating buttons
    CGSize itemSize = button.frame.size;
    for (NSString *icon in menuIcons) {
        LSFloatingActionMenuItem *item = [[LSFloatingActionMenuItem alloc] initWithImage:[UIImage imageNamed:icon] highlightedImage:[UIImage imageNamed:icon]];
        item.itemSize = itemSize;
        [menus addObject:item];
    }
    
    self.actionMenu = [[LSFloatingActionMenu alloc] initWithFrame:self.view.bounds direction:direction menuItems:menus menuHandler:^(LSFloatingActionMenuItem *item, NSUInteger index) {
        
        switch (index) {
            case 0:
                //Don't do anything if the plus button was pressed
                break;
            case 1:
                //Display parking garage annotations
                [self showParkingGarages];
                break;
                
            default:
                break;
        }
    } closeHandler:^{
        [self.actionMenu removeFromSuperview];
        self.actionMenu = nil;
        button.hidden = NO;
    }];
    
    //Configure styling of floating buttons
    self.actionMenu.itemSpacing = STANDARD_BUTTON_SPACING;
    self.actionMenu.startPoint = button.center;
    
    //Present them on screen
    [self.view addSubview:self.actionMenu];
    [self.actionMenu open];
}

- (void)showParkingGarages
{
    //Create an annotation object for every parking garage entry retrieved from Parse
    for (int x = 0; x < [self.parkingGaragesList count]; x++) {
        ParkingGarages *parkingGarage = [self.parkingGaragesList objectAtIndex:x];
        MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
        annotation.coordinate = CLLocationCoordinate2DMake([parkingGarage.latitude doubleValue], [parkingGarage.longitude doubleValue]);
        annotation.title = @"Parking Garage";
        [self.mapView addAnnotation:annotation];
    }
}

- (void)didLongPress:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    // Converts point where user did a long press to map coordinates
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    // Create a basic point annotation and add it to the map
    MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
    annotation.coordinate = coordinate;
    annotation.title = @"Start Navigation";
    [self.mapView addAnnotation:annotation];
    
    // Calculate the route from the user's location to the set destination
    [self calculateRoutefromOrigin:self.mapView.userLocation.coordinate
                     toDestination:annotation.coordinate
                        completion:^(MBRoute *_Nullable route, NSError *_Nullable error) {
                            if (error != nil) {
                                NSLog(@"Error calculating route: %@", error);
                            }
                        }];
}

#pragma mark Map View and Data Configuration
- (void)loadParkingGarages
{
    //Fetch all parking garage locations from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"ParkingGarages"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.parkingGaragesList = [[NSMutableArray alloc] init];
            
            //Convert PFObject to ParkingGarage objects and add to array
            for (PFObject *object in objects) {
                ParkingGarages *parkingGarage = [[ParkingGarages alloc] init];
                [parkingGarage configureFromParseObject:object];
                [self.parkingGaragesList addObject:parkingGarage];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (void)loadMapView
{
    // Allow the map view to display the user's location
    NSURL *styleURL = [MGLStyle darkStyleURL];
    
    self.mapView = [[MBNavigationMapView alloc] initWithFrame:self.mapViewContainer.frame styleURL:styleURL];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.tintColor = [UIColor darkGrayColor];
    
    //Turns on user location and heading tracker
    self.mapView.userTrackingMode = MGLUserTrackingModeFollowWithHeading;
    self.mapView.showsUserHeadingIndicator = YES;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:YES];
    
    //Add mapView to the container view
    [self.mapViewContainer addSubview:self.mapView];
    
    // Add a gesture recognizer to the map view
    UILongPressGestureRecognizer *setDestination = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.mapView addGestureRecognizer:setDestination];
}

- (void)populateMapFromData
{
    //User coming from ScenicDrivesViewController
    if (self.destinationWaypoint != nil) {
        [self calculateRoutefromOrigin:self.mapView.userLocation.coordinate
                         toDestination:self.destinationWaypoint.coordinate
                            completion:^(MBRoute *_Nullable route, NSError *_Nullable error) {
                                if (error != nil) {
                                    NSLog(@"Error calculating route: %@", error);
                                }
                            }];
    } else if (self.allRouteWaypoints != nil) {
        //User has created a custom route with multiple waypoints
        //Adding proper user location
        [self.allRouteWaypoints insertObject:[[MBWaypoint alloc] initWithCoordinate:self.mapView.userLocation.coordinate coordinateAccuracy:-1 name:@"Current Location"] atIndex:0];
        
        MBRouteOptions *directionsRouteOptions = [[MBRouteOptions alloc] initWithWaypoints:self.allRouteWaypoints profileIdentifier:MBDirectionsProfileIdentifierAutomobile];
        directionsRouteOptions.includesSteps = YES;
        
        //Compute route from user's current location through all waypoints
        (void)[[MBDirections sharedDirections] calculateDirectionsWithOptions:directionsRouteOptions completionHandler:^(
                                                                                                                         NSArray<MBWaypoint *> *waypoints,
                                                                                                                         NSArray<MBRoute *> *routes,
                                                                                                                         NSError *error) {
            
            if (!routes.firstObject) {
                return;
            }
            
            MBRoute *route = routes.firstObject;
            self.directionsRoute = route;
            CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
            [route getCoordinates:routeCoordinates];
            
            // Draw the route on the map after creating it
            [self drawRoute:routeCoordinates];
            
            //Add the navigation annotation once view is drawn
            MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
            annotation.coordinate = [waypoints lastObject].coordinate;
            annotation.title = @"Start Navigation";
            [self.mapView addAnnotation:annotation];
        }];
    }
}

- (void)calculateRoutefromOrigin:(CLLocationCoordinate2D)origin
                   toDestination:(CLLocationCoordinate2D)destination
                      completion:(void (^)(MBRoute *_Nullable route, NSError *_Nullable error))completion
{
    // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
    MBWaypoint *originWaypoint = [[MBWaypoint alloc] initWithCoordinate:origin coordinateAccuracy:-1 name:@"Start"];
    
    MBWaypoint *destinationWaypoint = [[MBWaypoint alloc] initWithCoordinate:destination coordinateAccuracy:-1 name:@"Finish"];
    
    // Specify that the route is intended for automobiles avoiding traffic
    MBNavigationRouteOptions *options = [[MBNavigationRouteOptions alloc] initWithWaypoints:@[ originWaypoint, destinationWaypoint ] profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    
    // Generate the route object and draw it on the map
    (void)[[MBDirections sharedDirections] calculateDirectionsWithOptions:options completionHandler:^(
                                                                                                      NSArray<MBWaypoint *> *waypoints,
                                                                                                      NSArray<MBRoute *> *routes,
                                                                                                      NSError *error) {
        
        if (!routes.firstObject) {
            return;
        }
        
        MBRoute *route = routes.firstObject;
        self.directionsRoute = route;
        CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
        [route getCoordinates:routeCoordinates];
        
        // Draw the route on the map after creating it
        [self drawRoute:routeCoordinates];
        
        //Add the navigation annotation once view is drawn
        MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
        annotation.coordinate = self.destinationWaypoint.coordinate;
        annotation.title = @"Start Navigation";
        [self.mapView addAnnotation:annotation];
    }];
}

- (void)drawRoute:(CLLocationCoordinate2D *)route
{
    //Ensures that coordinates exist in the directionsRoute
    if (self.directionsRoute.coordinateCount == 0) {
        return;
    }
    
    // Convert the route’s coordinates into a polyline.
    MGLPolylineFeature *polyline = [MGLPolylineFeature polylineWithCoordinates:route count:self.directionsRoute.coordinateCount];
    
    if ([self.mapView.style sourceWithIdentifier:@"route-source"]) {
        // If there's already a route line on the map, reset its shape to the new route
        MGLShapeSource *source = [self.mapView.style sourceWithIdentifier:@"route-source"];
        source.shape = polyline;
    } else {
        MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"route-source" shape:polyline options:nil];
        MGLLineStyleLayer *lineStyle = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-style" source:source];
        
        // Customize the route line color and width
        lineStyle.lineColor = [MGLStyleValue valueWithRawValue:[UIColor blueColor]];
        lineStyle.lineWidth = [MGLStyleValue valueWithRawValue:@"3"];
        
        // Add the source and style layer of the route line to the map
        [self.mapView.style addSource:source];
        [self.mapView.style addLayer:lineStyle];
    }
}

// Implement the delegate method that allows annotations to show callouts when tapped
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation
{
    return true;
}

- (void)mapView:(MGLMapView *)mapView didSelectAnnotation:(id<MGLAnnotation>)annotation
{
    // Calculate the route from the user's location to the set destination
    [self calculateRoutefromOrigin:self.mapView.userLocation.coordinate
                     toDestination:annotation.coordinate
                        completion:^(MBRoute *_Nullable route, NSError *_Nullable error) {
                            if (error != nil) {
                                NSLog(@"Error calculating route: %@", error);
                            }
                        }];
}

// Present the navigation view controller when the callout is selected
- (void)mapView:(MGLMapView *)mapView tapOnCalloutForAnnotation:(id<MGLAnnotation>)annotation
{
    //Begin navigation if callout is pressed
    [self performSegueWithIdentifier:@"showDriveBaseViewController" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDriveBaseViewController"]) {
        //Configure DriveExperienceBaseViewController with route
        DriveExperienceBaseViewController *vc = [segue destinationViewController];
        [vc setDirectionsRoute:self.directionsRoute];
    }
}
@end

