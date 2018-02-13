//
//  WaypointsTableViewCell.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaypointsTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *fromOrToLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressDetailLabel;
@property (nonatomic, retain) IBOutlet UIImageView *icon;

@end
