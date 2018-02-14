//
//  ScenicDrivesTableViewCell.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/9/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScenicDrives.h"

@interface ScenicDrivesTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *driveName;
@property (nonatomic, retain) IBOutlet UILabel *driveLengthHours;
@property (nonatomic, retain) IBOutlet UILabel *driveLengthMiles;
@property (nonatomic, retain) IBOutlet UIImageView *coverPhoto;

-(void)configureFromScenicDrives:(ScenicDrives *)scenicDrive;

@end
