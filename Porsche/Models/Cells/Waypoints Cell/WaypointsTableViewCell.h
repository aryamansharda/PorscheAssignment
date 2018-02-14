//
//  WaypointsTableViewCell.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Waypoint.h"

@interface WaypointsTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressDetailLabel;

-(void)configureFromWaypoint:(Waypoint *)waypoint;


@end
