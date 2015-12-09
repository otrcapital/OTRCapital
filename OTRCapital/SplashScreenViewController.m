//
//  SplashScreenViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 01/08/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "OTRManager.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGPoint viewCenter = self.view.center;
    UIView *spinner = [[OTRManager sharedManager] getSpinnerViewWithPosition:viewCenter];
    [self.view addSubview:spinner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

@end
