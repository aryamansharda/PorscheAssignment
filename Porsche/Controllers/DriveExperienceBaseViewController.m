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
@end

@implementation DriveExperienceBaseViewController {
    __block NSDictionary *currentVideo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roadTripIconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.roadTripIconImageView.layer.borderWidth = 2.0f;
    self.roadTripIconImageView.layer.cornerRadius = self.roadTripIconImageView.frame.size.width / 2;
    self.roadTripIconImageView.clipsToBounds = YES;
    
    self.roadTripNameLabel.text = self.directionsRoute.description;
    self.roadTripLengthLabel.text = [NSString stringWithFormat:@"%.0f MILES",(self.directionsRoute.distance/1609.344)];
    
    self.roadTripExpectedTimeLabel.text = [self timeFormatted:self.directionsRoute.expectedTravelTime];
    
    [self.startNavigationButton setBackgroundColor:[UIColor colorWithRed:42.0f/255.0f green:43.f/255.0f blue:53.0f/255.0f alpha:1]];
    [self.startNavigationButton setTitle:@"START NAVIGATION" forState:UIControlStateNormal];
    [self.startNavigationButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:15.0]];
    self.startNavigationButton.layer.cornerRadius = 10.0f;
    
    self.montageSegmentedControl.delegate = self;
    self.montageSegmentedControl.dataSource = self;
    self.montageSegmentedControl.transitionStyle = LUNSegmentedControlTransitionStyleFade;
    
    self.simulatedSegmentedControl.delegate = self;
    self.simulatedSegmentedControl.dataSource = self ;
    self.simulatedSegmentedControl.transitionStyle = LUNSegmentedControlTransitionStyleFade;        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)cameraTimeLapseControl {
    if ([PBJVision sharedInstance].isRecording) {
        NSLog(@"Trying to end video capture");
        //End video capture, if exists
        [[PBJVision sharedInstance] endVideoCapture];
    } else {
        NSLog(@"Trying to start video capture");
        //Update configuration
        [self configureVideoRecording];
        
        //Start new capture with new camera direction
        [[PBJVision sharedInstance] startVideoCapture];
    }
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    currentVideo = videoDict;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSString *videoPath = [currentVideo  objectForKey:PBJVisionVideoPathKey];
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:videoPath]];
    } completionHandler:^(BOOL success, NSError * _Nullable error1) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Video Saved.");
            });
        } else if (error1) {
            NSLog(@"error: %@", error1);
        }
    }];
}

- (IBAction)launchMapController {
    self.navigationViewController = [[MBNavigationViewController alloc] initWithRoute:self.directionsRoute directions:[MBDirections sharedDirections] style:nil locationManager:nil];
    self.navigationViewController.navigationDelegate = self;
    
    if (self.montageSegmentedControl.currentState == 0) {
        self.cameraControlTimer = [NSTimer scheduledTimerWithTimeInterval:120.0f target:self selector:@selector(cameraTimeLapseControl) userInfo:nil repeats:YES];
        NSLog(@"Enabling montage functionality.");
    }
    
    if (self.simulatedSegmentedControl.currentState == 0) {
        self.navigationViewController.routeController.locationManager = [[MBSimulatedLocationManager alloc] initWithRoute:self.directionsRoute];
        NSLog(@"Enabling simulation functionality functionality.");
    }
    
    [self presentViewController:self.navigationViewController animated:YES completion:nil];
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%d:%d HOURS",hours, minutes];
}
#pragma mark PBJVision Delegate
- (void)configureVideoRecording {
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationLandscapeLeft;
    vision.cameraDevice = !vision.cameraDevice;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatStandard;
    vision.videoBitRate = PBJVideoBitRate480x360;
    [vision setMaximumCaptureDuration:CMTimeMakeWithSeconds(10, 600)];
    [vision startPreview];
}

#pragma mark Navigation Delegate
- (void)navigationViewControllerDidCancelNavigation:(MBNavigationViewController *)navigationViewController {
    NSLog(@"Navigation Delegate: Navigation Cancelled");
    [[PBJVision sharedInstance] endVideoCapture];

    [self.cameraControlTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LUNSegmentedControl Delegate
- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl {
    return 2;
}

- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index {
    
    if (index == 0) {
        return @"ON";
    } else if (index == 1) {
        return @"OFF";
    } else {
        return @"N/A";
    }
}

- (NSArray<UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @[[UIColor colorWithRed:160 / 255.0 green:223 / 255.0 blue:56 / 255.0 alpha:1.0], [UIColor colorWithRed:177 / 255.0 green:255 / 255.0 blue:0 / 255.0 alpha:1.0]];
            break;
            
        case 1:
            return @[[UIColor colorWithRed:78 / 255.0 green:252 / 255.0 blue:208 / 255.0 alpha:1.0], [UIColor colorWithRed:51 / 255.0 green:199 / 255.0 blue:244 / 255.0 alpha:1.0]];
            break;
            
        default:
            break;
    }
    return nil;
}

@end
