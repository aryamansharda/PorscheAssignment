//
//  SplashScreenViewController.m
//  Porsche
//
//  Created by Aryaman Sharda on 2/9/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "ScenicDrivesViewController.h"
#import "HyTransitions.h"


@interface SplashScreenViewController ()

@end


@implementation SplashScreenViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Load gif background from NSBundle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Driving" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];

    //Configure styling and appearance of background video view
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.videoBackgroundView loadData:gif MIMEType:@"image/gif" textEncodingName:@"UTF-8" baseURL:[[NSURL alloc] init]];
    [self.videoBackgroundView setUserInteractionEnabled:NO];
    [self.videoBackgroundView setContentMode:UIViewContentModeScaleAspectFit];
    [self.videoBackgroundView setFrame:[UIScreen mainScreen].bounds];

    //Add slightly dark overlay to the video background
    UIView *filter = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.2;
    [self.videoBackgroundView addSubview:filter];

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.videoBackgroundView setBackgroundColor:[UIColor blackColor]];

    //Configure transition buttons location, target, and appearance
    HyLoginButton *loginButton = [[HyLoginButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 50)];
    [loginButton setBackgroundColor:DEFAULT_GRAY_ROUNDED_BUTTON_COLOR];
    [loginButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont fontWithName:CUSTOM_FONT_BOLD size:CUSTOM_FONT_BOLD_DEFAULT_SIZE]];
    [loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation Bar Apperance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - HyLoginButton Delegate
- (void)loginButtonTapped:(id)sender
{
    //Perform animation and transition after DEFAULT_GRAY_ROUNDED_BUTTON_ANIMATION_TIME
    typeof(self) __weak weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DEFAULT_GRAY_ROUNDED_BUTTON_ANIMATION_TIME)), dispatch_get_main_queue(), ^{
        [(HyLoginButton *)sender succeedAnimationWithCompletion:^{
            //Perform view transition after successful animation completion
            [weak didPresentControllerButtonTouch];
        }];
    });
}

- (void)didPresentControllerButtonTouch
{
    //Load new view controller from Storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ScenicDrivesViewController"];
    controller.transitioningDelegate = self;

    //Add view controller to navigation controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.transitioningDelegate = self;


    //Present the navigation controller with the embedded ScenicDrivesViewController
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    //Configures HyTransition animation settings
    return [[HyTransitions alloc] initWithTransitionDuration:0.4f StartingAlpha:0.5f isPush:true];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    //Configures HyTransition animation settings
    return [[HyTransitions alloc] initWithTransitionDuration:0.4f StartingAlpha:0.8f isPush:false];
}

@end
