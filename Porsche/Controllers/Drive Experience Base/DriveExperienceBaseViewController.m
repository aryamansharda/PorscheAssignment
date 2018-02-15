//
//  DriveExperienceBaseViewController.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/11/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "DriveExperienceBaseViewController.h"
#import "PBJVision.h"
#import <Photos/Photos.h>
#import "HyLoginButton.h"


@interface DriveExperienceBaseViewController ()

@property (nonatomic) NSTimer *cameraControlTimer;
@property (nonatomic) __block NSDictionary *currentVideo;

@end


@implementation DriveExperienceBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.roadTripIconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.roadTripIconImageView.layer.borderWidth = STANDARD_BORDER_WIDTH;
    self.roadTripIconImageView.layer.cornerRadius = self.roadTripIconImageView.frame.size.width / 2;
    self.roadTripIconImageView.clipsToBounds = YES;

    self.roadTripNameLabel.text = self.directionsRoute.description;
    self.roadTripLengthLabel.text = [NSString stringWithFormat:@"%.0f MILES", (self.directionsRoute.distance / 1609.344)];

    self.roadTripExpectedTimeLabel.text = [self timeFormatted:self.directionsRoute.expectedTravelTime];

    [self.startNavigationButton setBackgroundColor:DEFAULT_GRAY_ROUNDED_BUTTON_COLOR];
    [self.startNavigationButton setTitle:@"START NAVIGATION" forState:UIControlStateNormal];
    [self.startNavigationButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT_BOLD size:CUSTOM_FONT_BOLD_DEFAULT_SIZE]];
    self.startNavigationButton.layer.cornerRadius = DEFAULT_GRAY_ROUNDED_BUTTON_RADIUS;

    self.montageSegmentedControl.delegate = self;
    self.montageSegmentedControl.dataSource = self;
    self.montageSegmentedControl.transitionStyle = LUNSegmentedControlTransitionStyleFade;

    self.simulatedSegmentedControl.delegate = self;
    self.simulatedSegmentedControl.dataSource = self;
    self.simulatedSegmentedControl.transitionStyle = LUNSegmentedControlTransitionStyleFade;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)cameraTimeLapseControl
{
    if ([PBJVision sharedInstance].isRecording) {
        [[PBJVision sharedInstance] endVideoCapture];
    } else {
        [self configureVideoRecording];
        [[PBJVision sharedInstance] startVideoCapture];
    }
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }

    self.currentVideo = videoDict;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSString *videoPath = [self.currentVideo objectForKey:PBJVisionVideoPathKey];
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:videoPath]];
    } completionHandler:^(BOOL success, NSError *_Nullable videoError) {
        if (videoError) {
            NSLog(@"error: %@", videoError);
        }
    }];
}

- (IBAction)launchMapController
{
    self.navigationViewController = [[MBNavigationViewController alloc] initWithRoute:self.directionsRoute directions:[MBDirections sharedDirections] style:nil locationManager:nil];
    self.navigationViewController.navigationDelegate = self;

    if (self.montageSegmentedControl.currentState == ON_SEGMENT_CONTROL_STATE) {
        self.cameraControlTimer = [NSTimer scheduledTimerWithTimeInterval:TIMELAPSE_FREQUENCY target:self selector:@selector(cameraTimeLapseControl) userInfo:nil repeats:YES];
    }

    if (self.simulatedSegmentedControl.currentState == ON_SEGMENT_CONTROL_STATE) {
        self.navigationViewController.routeController.locationManager = [[MBSimulatedLocationManager alloc] initWithRoute:self.directionsRoute];
    }

    [self presentViewController:self.navigationViewController animated:YES completion:nil];
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    return [NSString stringWithFormat:@"%d:%d HOURS", hours, minutes];
}

#pragma mark PBJVision Delegate
- (void)configureVideoRecording
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationLandscapeLeft;
    vision.cameraDevice = !vision.cameraDevice;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatStandard;
    vision.videoBitRate = PBJVideoBitRate480x360;
    [vision setMaximumCaptureDuration:CMTimeMakeWithSeconds(DEFAULT_VIDEO_LENGTH, DEFAULT_VIDEO_TIME_SCALE)];
    [vision startPreview];
}

#pragma mark Navigation Delegate
- (void)navigationViewControllerDidCancelNavigation:(MBNavigationViewController *)navigationViewController
{
    [[PBJVision sharedInstance] endVideoCapture];

    [self.cameraControlTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LUNSegmentedControl Delegate
- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl
{
    return 2;
}

- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index
{
    if (index == 0) {
        return ON_SEGMENT_CONTROL_TITLE;
    } else if (index == 1) {
        return OFF_SEGMENT_CONTROL_TITLE;
    } else {
        return NA_SEGMENT_CONTROL_TITLE;
    }
}

- (NSArray<UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return ON_COLOR_SET;
            break;

        case 1:
            return OFF_COLOR_SET;
            break;

        default:
            break;
    }
    return nil;
}

@end
