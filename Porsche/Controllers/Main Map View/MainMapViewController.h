//
//  MainMapViewController.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVision.h"


@interface MainMapViewController : UIViewController <MGLMapViewDelegate>

@property (nonatomic) IBOutlet UIView *mapViewContainer;
@property (nonatomic) MBNavigationMapView *mapView;

@property (nonatomic) MBWaypoint *destinationWaypoint;
@property (nonatomic) MBRoute *directionsRoute;
@property (nonatomic) NSMutableArray *allRouteWaypoints;
@end
