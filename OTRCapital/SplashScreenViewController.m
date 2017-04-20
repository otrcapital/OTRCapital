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
#import "OTRUser+DB.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tryLoginWithCurrentCredentials];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)tryLoginWithCurrentCredentials {
    
    if([OTRDefaults getStringForKey:KEY_LOGIN_USER_NAME]) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            OTRUser *user = [OTRUser MR_createEntityInContext:localContext];
            user.email = [OTRDefaults getStringForKey:KEY_LOGIN_USER_NAME];
            user.passwordData = [OTRDefaults getStringForKey:KEY_LOGIN_PASSWORD];
            
            [[OTRManager sharedManager] removeObjectForKey:KEY_LOGIN_USER_NAME];
            [[OTRManager sharedManager] removeObjectForKey:KEY_LOGIN_PASSWORD];
        }];
    }

    if (![OTRApi hasConnection]) {
        [[OTRHud hud] hide];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:@"No internet connection found. Kindly check your connectivity to proceed"
                                                           delegate:self
                                                  cancelButtonTitle:@"Retry"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }else {
        if([OTRUser isAuthorized]){
            NSString *email = [OTRUser getEmail];
            NSString *password = [OTRUser getEncodedPassword];
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
        }else {
            [self switchToLoginController];
        }
    }
}

- (void)switchToDashboardController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"DashboardViewController"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [stackViewControllers removeLastObject];
        [stackViewControllers addObject:controller];
        [self.navigationController setViewControllers:stackViewControllers animated:YES];
    });
}

- (void)switchToLoginController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *controller = [sb instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    
    [self switchToDashboardController];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *navController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [navController presentViewController:controller animated:YES completion:nil];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self tryLoginWithCurrentCredentials];
}

@end
