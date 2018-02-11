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
#import <Parse/Parse.h>

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Creating and displaying video background
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Driving" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    [self.videoBackgroundView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.videoBackgroundView setUserInteractionEnabled:NO];
    [self.videoBackgroundView setScalesPageToFit:YES];
    [self.videoBackgroundView setContentMode:UIViewContentModeScaleAspectFill];
    
    UIView *filter = [[UIView alloc] initWithFrame:self.videoBackgroundView.frame];
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = 0.2;
    [self.videoBackgroundView addSubview:filter];
    
    //Configure Login Button
    HyLoginButton *loginButton = [[HyLoginButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    [loginButton setBackgroundColor:[UIColor colorWithRed:1 green:0.f/255.0f blue:128.0f/255.0f alpha:1]];
    [loginButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:15.0]];
    [loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)loginButtonTapped:(id)sender {
    typeof(self) __weak weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [(HyLoginButton *)sender succeedAnimationWithCompletion:^{
            [weak didPresentControllerButtonTouch];
        }];
    });
}

- (void)didPresentControllerButtonTouch {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"ScenicDrivesViewController"];
    controller.transitioningDelegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.transitioningDelegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.5f isPush:true];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.8f isPush:false];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
