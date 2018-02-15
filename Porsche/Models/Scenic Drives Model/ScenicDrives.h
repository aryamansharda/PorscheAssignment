//
//  ScenicDrives.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/9/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface ScenicDrives : NSObject

@property (nonatomic, retain) NSString *driveName;
@property (nonatomic, retain) NSString *driveLengthHours;
@property (nonatomic, retain) NSString *driveLengthMiles;

@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;

@property (nonatomic, retain) PFFile *coverPhotoReference;
@property (nonatomic, retain) UIImage *coverPhotoImage;

- (void)configureFromParseObject:(PFObject *)object sourceTableView:(UITableView *)tableView;

@end
