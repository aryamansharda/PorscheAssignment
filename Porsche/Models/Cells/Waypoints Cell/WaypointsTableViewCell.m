//
//  WaypointsTableViewCell.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "WaypointsTableViewCell.h"


@implementation WaypointsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureFromWaypoint:(Waypoint *)waypoint
{
    self.addressDetailLabel.text = waypoint.addressDetail;
    self.addressLabel.text = waypoint.addressTitle;
}
@end
