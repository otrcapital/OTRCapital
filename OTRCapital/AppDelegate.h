//
//  AppDelegate.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "OTRManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, OTRManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController *navController;

- (void) switchToDashboardController;
- (void) switchToLoginController;

@end

