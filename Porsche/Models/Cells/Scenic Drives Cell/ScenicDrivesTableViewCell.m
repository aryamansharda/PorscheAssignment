//
//  ScenicDrivesTableViewCell.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/9/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "ScenicDrivesTableViewCell.h"


@implementation ScenicDrivesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureFromScenicDrives:(ScenicDrives *)scenicDrive
{
    self.driveName.text = scenicDrive.driveName;
    self.driveLengthHours.text = [scenicDrive.driveLengthHours uppercaseString];
    self.driveLengthMiles.text = [NSString stringWithFormat:@"%@ miles", scenicDrive.driveLengthMiles];
    self.coverPhoto.image = scenicDrive.coverPhotoImage;
}

@end
