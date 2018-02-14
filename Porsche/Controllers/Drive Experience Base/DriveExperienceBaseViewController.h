//
//  DriveExperienceBaseViewController.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "PBJVision.h"
#import "LUNSegmentedControl.h"

@interface DriveExperienceBaseViewController : UIViewController <MBNavigationViewControllerDelegate, PBJVisionDelegate, LUNSegmentedControlDelegate, LUNSegmentedControlDataSource>

@property (nonatomic, weak) IBOutlet UIImageView *roadTripIconImageView;
@property (nonatomic, weak) IBOutlet UIButton *startNavigationButton;
@property (nonatomic, weak) IBOutlet UILabel *roadTripNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *roadTripExpectedTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *roadTripLengthLabel;

@property (nonatomic, weak) IBOutlet LUNSegmentedControl *montageSegmentedControl;
@property (nonatomic, weak) IBOutlet LUNSegmentedControl *simulatedSegmentedControl;

@property (nonatomic, strong) MBRoute *directionsRoute;
@property (strong, nonatomic) MBNavigationViewController *navigationViewController;

@end
