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

    //Configures styling for the road trip icon image
    self.roadTripIconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.roadTripIconImageView.layer.borderWidth = STANDARD_BORDER_WIDTH;
    self.roadTripIconImageView.layer.cornerRadius = self.roadTripIconImageView.frame.size.width / 2;
    self.roadTripIconImageView.clipsToBounds = YES;

    //Initializes road trip name and length labels
    self.roadTripNameLabel.text = self.directionsRoute.description;

    //Stylizes start navigation button
    [self.startNavigationButton setBackgroundColor:DEFAULT_GRAY_ROUNDED_BUTTON_COLOR];
    [self.startNavigationButton setTitle:@"START NAVIGATION" forState:UIControlStateNormal];
    [self.startNavigationButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT_BOLD size:CUSTOM_FONT_BOLD_DEFAULT_SIZE]];
    self.startNavigationButton.layer.cornerRadius = DEFAULT_GRAY_ROUNDED_BUTTON_RADIUS;

    //Configures data source and delegate for custom segmented control object
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
    //Start recording video, if not already recording
    if ([PBJVision sharedInstance].isRecording) {
        [[PBJVision sharedInstance] endVideoCapture];
    } else {
        //Used to initialize camera and toggle front/back camera
        [self configureVideoRecording];
        [[PBJVision sharedInstance] startVideoCapture];
    }
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    //Basic error checks and camera input validation
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }

    //Creates a reference to the recorded video so it's accessible in the completion handler
    self.currentVideo = videoDict;
    
    //Async save video to user Photos library
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
    //Initializes turn by turn navigation view controller and assigns delegate
    self.navigationViewController = [[MBNavigationViewController alloc] initWithRoute:self.directionsRoute directions:[MBDirections sharedDirections] style:nil locationManager:nil];
    self.navigationViewController.navigationDelegate = self;

    //Initializes the montage timer if setting was turned on
    if (self.montageSegmentedControl.currentState == ON_SEGMENT_CONTROL_STATE) {
        self.cameraControlTimer = [NSTimer scheduledTimerWithTimeInterval:TIMELAPSE_FREQUENCY target:self selector:@selector(cameraTimeLapseControl) userInfo:nil repeats:YES];
    }

    //Simulates user location movement
    if (self.simulatedSegmentedControl.currentState == ON_SEGMENT_CONTROL_STATE) {
        self.navigationViewController.routeController.locationManager = [[MBSimulatedLocationManager alloc] initWithRoute:self.directionsRoute];
    }

    //Present turn by turn navigation controller
    [self presentViewController:self.navigationViewController animated:YES completion:nil];
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    //Convert total trip time in seconds to human readable string
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    return [NSString stringWithFormat:@"%d:%d HOURS", hours, minutes];
}

#pragma mark PBJVision Delegate
- (void)configureVideoRecording
{
    //Configures video recording in hte background
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationLandscapeLeft;
    
    //Alternates between front and back camera every time method is called
    vision.cameraDevice = !vision.cameraDevice;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatStandard;
    
    //Choosing low bit rate to minimize file size
    vision.videoBitRate = PBJVideoBitRate480x360;
    
    //Set maximum video length
    [vision setMaximumCaptureDuration:CMTimeMakeWithSeconds(DEFAULT_VIDEO_LENGTH, DEFAULT_VIDEO_TIME_SCALE)];
    [vision startPreview];
}

#pragma mark Navigation Delegate
- (void)navigationViewControllerDidCancelNavigation:(MBNavigationViewController *)navigationViewController
{
    //Cancel video when turn by turn navigation dismissed
    [[PBJVision sharedInstance] endVideoCapture];

    //Invalidate the montage timer
    [self.cameraControlTimer invalidate];
    
    //Dismiss turn by turn navigation controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LUNSegmentedControl Delegate
- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl
{
    return 2;
}

- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index
{
    //Assigns titles to segment control segments based on selection
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
    //Assigns colors to segment control segments based on selection
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
