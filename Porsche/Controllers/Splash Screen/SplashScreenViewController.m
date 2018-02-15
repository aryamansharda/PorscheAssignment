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

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Driving" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.videoBackgroundView loadData:gif MIMEType:@"image/gif" textEncodingName:@"UTF-8" baseURL:[[NSURL alloc] init]];
    [self.videoBackgroundView setUserInteractionEnabled:NO];
    [self.videoBackgroundView setContentMode:UIViewContentModeScaleAspectFit];
    [self.videoBackgroundView setFrame:[UIScreen mainScreen].bounds];

    UIView *filter = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.2;
    [self.videoBackgroundView addSubview:filter];

    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.videoBackgroundView setBackgroundColor:[UIColor blackColor]];

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
    typeof(self) __weak weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DEFAULT_GRAY_ROUNDED_BUTTON_ANIMATION_TIME)), dispatch_get_main_queue(), ^{
        [(HyLoginButton *)sender succeedAnimationWithCompletion:^{
            [weak didPresentControllerButtonTouch];
        }];
    });
}

- (void)didPresentControllerButtonTouch
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ScenicDrivesViewController"];
    controller.transitioningDelegate = self;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.transitioningDelegate = self;


    [self presentViewController:navigationController animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [[HyTransitions alloc] initWithTransitionDuration:0.4f StartingAlpha:0.5f isPush:true];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[HyTransitions alloc] initWithTransitionDuration:0.4f StartingAlpha:0.8f isPush:false];
}

@end
