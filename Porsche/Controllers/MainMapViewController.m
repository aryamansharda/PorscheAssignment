//
//  MainMapViewController.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "MainMapViewController.h"
#import "CustomUserLocationAnnotationView.h"
#import "ParkingGarages.h"
#import "LSFloatingActionMenu.h"
#import <Parse/Parse.h>

@interface MainMapViewController ()

@property (strong, nonatomic) LSFloatingActionMenu *actionMenu;

@end

@implementation MainMapViewController {
    NSMutableArray *parkingGaragesList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadMapView];
    [self loadParkingGarages];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions
- (IBAction)onTopLeftButtonClicked:(UIButton *)sender {
    [self showMenuFromButton:sender withDirection:LSFloatingActionMenuDirectionUp];
    
//    if (self.destinationWaypoint != nil) {
//        NSLog(@"Trying to load route.: %f to %f", self.mapView.userLocation.coordinate.latitude, self.destinationWaypoint.coordinate.latitude);
//        [self calculateRoutefromOrigin:self.mapView.userLocation.coordinate
//                         toDestination:self.destinationWaypoint.coordinate
//                            completion:^(MBRoute * _Nullable route, NSError * _Nullable error) {
//                                if (error != nil) {
//                                    NSLog(@"Error calculating route: %@", error);
//                                }
//
//                                NSLog(@"Completed this call.");
//                            }];
//    }
    
    if (self.directionsRouteOptions != nil) {
        (void)[[MBDirections sharedDirections] calculateDirectionsWithOptions:self.directionsRouteOptions completionHandler:^(
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
        }];
    }
}

- (void)showMenuFromButton:(UIButton *)button withDirection:(LSFloatingActionMenuDirection)direction {
    button.hidden = YES;
    
    NSArray *menuIcons = @[@"PlusIcon", @"POIIcon", @"ParkingIcon"];
    NSMutableArray *menus = [NSMutableArray array];
    
    CGSize itemSize = button.frame.size;
    for (NSString *icon in menuIcons) {
        LSFloatingActionMenuItem *item = [[LSFloatingActionMenuItem alloc] initWithImage:[UIImage imageNamed:icon] highlightedImage:[UIImage imageNamed:icon]];
        item.itemSize = itemSize;
        [menus addObject:item];
    }
    
    self.actionMenu = [[LSFloatingActionMenu alloc] initWithFrame:self.view.bounds direction:direction menuItems:menus menuHandler:^(LSFloatingActionMenuItem *item, NSUInteger index) {
        
        switch (index) {
            case 0:
                break;
            case 1:
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
    
    self.actionMenu.itemSpacing = 12;
    self.actionMenu.startPoint = button.center;
    
    [self.view addSubview:self.actionMenu];
    [self.actionMenu open];
}

-(void)loadMapView {
    // Allow the map view to display the user's location
    NSURL *styleURL = [MGLStyle darkStyleURL];
    
    self.mapView = [[MBNavigationMapView alloc] initWithFrame:self.mapViewContainer.frame styleURL:styleURL];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.tintColor = [UIColor darkGrayColor];
    self.mapView.userTrackingMode = MGLUserTrackingModeFollowWithHeading;
    self.mapView.showsUserHeadingIndicator = YES;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:YES];
    
//    if (self.mapView.userLocation != nil) {
//        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:7 animated:true];
//    }
    
    [self.mapViewContainer addSubview:self.mapView];
    
    // Add a gesture recognizer to the map view
    UILongPressGestureRecognizer *setDestination = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.mapView addGestureRecognizer:setDestination];
}

-(void)loadParkingGarages {
    PFQuery *query = [PFQuery queryWithClassName:@"ParkingGarages"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            parkingGaragesList = [[NSMutableArray alloc] init];
            
            for (PFObject *object in objects) {
                
                ParkingGarages *parkingGarage = [[ParkingGarages alloc] init];
                parkingGarage.address = [object objectForKey:@"Address"];
                parkingGarage.type = [object objectForKey:@"Type"];
                parkingGarage.latitude = [object objectForKey:@"Latitude"];
                parkingGarage.longitude = [object objectForKey:@"Longitude"];
                [parkingGaragesList addObject:parkingGarage];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)showParkingGarages {
    for (int x = 0; x < [parkingGaragesList count]; x++) {
        ParkingGarages *parkingGarage = [parkingGaragesList objectAtIndex:x];
        MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
        annotation.coordinate = CLLocationCoordinate2DMake([parkingGarage.latitude doubleValue], [parkingGarage.longitude doubleValue]);
        annotation.title = @"Parking Garage";
        [self.mapView addAnnotation:annotation];
    }
}

-(void)didLongPress:(UITapGestureRecognizer *)sender {
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
                        completion:^(MBRoute * _Nullable route, NSError * _Nullable error) {
                            if (error != nil) {
                                NSLog(@"Error calculating route: %@", error);
                            }
                        }];
}

-(void)calculateRoutefromOrigin:(CLLocationCoordinate2D)origin
                  toDestination:(CLLocationCoordinate2D)destination
                     completion:(void(^)(MBRoute *_Nullable route, NSError *_Nullable error))completion {
    
    // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
    MBWaypoint *originWaypoint = [[MBWaypoint alloc] initWithCoordinate:origin coordinateAccuracy:-1 name:@"Start"];
    
    MBWaypoint *destinationWaypoint = [[MBWaypoint alloc] initWithCoordinate:destination coordinateAccuracy:-1 name:@"Finish"];
    
    // Specify that the route is intended for automobiles avoiding traffic
    MBNavigationRouteOptions *options = [[MBNavigationRouteOptions alloc] initWithWaypoints:@[originWaypoint, destinationWaypoint] profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    
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
    }];
}

-(void)drawRoute:(CLLocationCoordinate2D *)route {
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
-(BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    return true;
}

// Present the navigation view controller when the callout is selected
-(void)mapView:(MGLMapView *)mapView tapOnCalloutForAnnotation:(id<MGLAnnotation>)annotation {
    MBNavigationViewController *navigationViewController = [[MBNavigationViewController alloc] initWithRoute:_directionsRoute directions:[MBDirections sharedDirections] style:nil locationManager:nil];
    [self presentViewController:navigationViewController animated:YES completion:nil];
}

//- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation {
//    // Try to reuse the existing ‘pisa’ annotation image, if it exists.
//    MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"PorscheName"];
//
//    // If the ‘pisa’ annotation image hasn‘t been set yet, initialize it here.
//    if (!annotationImage) {
//        // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
//        UIImage *image = [UIImage imageNamed:@"PorscheName"];
//        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
//
//        // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
//        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"PorscheName"];
//    }
//
//    return annotationImage;
//}

//- (MGLAnnotationView *)mapView:(MGLMapView *)mapView viewForAnnotation:(id<MGLAnnotation>)annotation {
//    // Substitute our custom view for the user location annotation. This custom view is defined above.
//    if ([annotation isKindOfClass:[MGLUserLocation class]]) {
//        return [[CustomUserLocationAnnotationView alloc] init];
//    }
//
//    return nil;
//}

// Optional: tap the user location annotation to toggle heading tracking mode.
//- (void)mapView:(MGLMapView *)mapView didSelectAnnotation:(id<MGLAnnotation>)annotation {
//    if (mapView.userTrackingMode != MGLUserTrackingModeFollowWithHeading) {
//        mapView.userTrackingMode = MGLUserTrackingModeFollowWithHeading;
//    } else {
//        [mapView resetNorth];
//    }
//    
//    // We're borrowing this method as a gesture recognizer, so reset selection state.
//    [mapView deselectAnnotation:annotation animated:NO];
//}
@end
