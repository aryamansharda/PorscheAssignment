//
//  Waypoint.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "Waypoint.h"


@implementation Waypoint

- (void)configureFromMKMapItem:(MKMapItem *)item
{
    self.addressTitle = [[item placemark] name];
    self.addressDetail = [[item placemark] title];
    self.coordinate = [[item placemark] coordinate];
}

@end
