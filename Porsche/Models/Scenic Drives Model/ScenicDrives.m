//
//  ScenicDrives.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/9/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "ScenicDrives.h"


@implementation ScenicDrives

- (void)configureFromParseObject:(PFObject *)object sourceTableView:(UITableView *)tableView
{
    //Assigns instance variables from Parse object
    self.driveName = [object objectForKey:@"driveName"];
    self.driveLengthHours = [object objectForKey:@"driveLengthHours"];
    self.driveLengthMiles = [object objectForKey:@"driveLengthMiles"];
    self.coverPhotoReference = [object objectForKey:@"coverPhoto"];
    self.latitude = [object objectForKey:@"latitude"];
    self.longitude = [object objectForKey:@"longitude"];

    //Retrieves image associated with Parse file reference
    PFFile *coverPhoto = self.coverPhotoReference;
    if (coverPhoto != NULL) {
        [coverPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            //Assigns image to internal image instance variable once complete
            UIImage *thumbnailImage = [UIImage imageWithData:imageData];
            self.coverPhotoImage = thumbnailImage;
            [tableView reloadData];
        }];
    }
}


@end
