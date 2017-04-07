//
//  SplashScreenViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 01/08/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "OTRManager.h"
#import "OTRApi.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGPoint viewCenter = self.view.center;
    UIView *spinner = [[OTRManager sharedManager] getSpinnerViewWithPosition:viewCenter];
    [self.view addSubview:spinner];
    
    [self tryLoginWithCurrentCredentials];
}

- (void)tryLoginWithCurrentCredentials {
    if (![OTRApi hasConnection]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"No internet connection found. Kindly check your connectivity to proceed"
                                                           delegate:self
                                                  cancelButtonTitle:@"Retry"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
    else {
        if([OTRDefaults getStringForKey:KEY_LOGIN_USER_NAME]){
            NSString *email = [OTRDefaults getStringForKey:KEY_LOGIN_USER_NAME];
            NSString *password = [OTRDefaults getStringForKey:KEY_LOGIN_PASSWORD];
            [[OTRApi instance] loginWithUsername:email encodedPassword:password completionBlock:^(NSDictionary *responseData, NSError *error) {
                if(responseData && !error) {
                    NSString *isValid = [responseData objectForKey:@"IsValidUser"];
                    if ([isValid boolValue]) {
                        [self switchToDashboardController];
                    }else{
                        [self switchToLoginController];
                    }
                }else {
                    [self switchToLoginController];
                }
            }];
        }
        else{
            [self switchToLoginController];
        }
    }
}

- (void) switchToDashboardController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"DashboardViewController"];
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    [stackViewControllers addObject:controller];
    [self.navigationController setViewControllers:stackViewControllers animated:YES];
}

- (void) switchToLoginController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self switchToDashboardController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self tryLoginWithCurrentCredentials];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

@end
