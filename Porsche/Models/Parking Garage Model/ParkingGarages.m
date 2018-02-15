//
//  ParkingGarages.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "ParkingGarages.h"


@implementation ParkingGarages

- (void)configureFromParseObject:(PFObject *)object
{
    self.address = [object objectForKey:@"Address"];
    self.type = [object objectForKey:@"Type"];
    self.latitude = [object objectForKey:@"Latitude"];
    self.longitude = [object objectForKey:@"Longitude"];
}

@end
