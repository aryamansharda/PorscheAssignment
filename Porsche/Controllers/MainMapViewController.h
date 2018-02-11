//
//  MainMapViewController.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Porsche-Bridging-Header.h"

@import Mapbox;
@import MapboxNavigation;
@import MapboxDirections;
@import MapboxCoreNavigation;

@interface MainMapViewController : UIViewController <MGLMapViewDelegate>

@property (nonatomic) IBOutlet UIView *mapViewContainer;
@property (nonatomic) MBNavigationMapView *mapView;

//TODO: Make this use a route option
@property (nonatomic) MBWaypoint *destinationWaypoint;
@property (nonatomic) MBRoute *directionsRoute;
@property (nonatomic) MBRouteOptions *directionsRouteOptions;

@end
