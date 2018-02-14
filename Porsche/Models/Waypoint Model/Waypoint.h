//
//  Waypoint.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Waypoint : NSObject

@property (nonatomic, retain) NSString *addressTitle;
@property (nonatomic, retain) NSString *addressDetail;
@property (nonatomic) CLLocationCoordinate2D coordinate;

-(void)configureFromMKMapItem:(MKMapItem *)item;

@end
