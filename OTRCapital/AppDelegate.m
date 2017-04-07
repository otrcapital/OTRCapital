//
//  AppDelegate.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "OTRManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "OTRApi.h"

@implementation AppDelegate


- (void) switchToDashboardController {
    //UINavigationController *rootViewController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"DashboardViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    //UIViewController *topViewController = rootViewController ? rootViewController.viewControllers.firstObject : nil;
    
//    if(!topViewController || [topViewController isKindOfClass:NSClassFromString(@"SplashScreenViewController")]) {
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        self.window.rootViewController = navController;
//        [self.window makeKeyAndVisible];
//    }else if([topViewController isKindOfClass:NSClassFromString(@"LoginViewController")]){
//        [topViewController dismissViewControllerAnimated:YES completion:nil];
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
}

- (void) switchToLoginController {
    //UINavigationController *rootViewController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    //UIViewController *topViewController = rootViewController ? rootViewController.viewControllers.firstObject : nil;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
//    if(!rootViewController || [topViewController isKindOfClass:NSClassFromString(@"SplashScreenViewController")]) {
//        [rootViewController presentViewController:navController animated:NO completion:nil];
//    }else if(![rootViewController presentingViewController]){
//        [rootViewController presentViewController:navController animated:YES completion:nil];
//    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self testInternetConnection];
    
#ifdef DEBUG
    [[Fabric sharedSDK] setDebug: YES];
#endif
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}

- (void) disableAutoBackup{
    NSArray *urlArray = [[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask];
    NSURL *documentsUrl = [urlArray firstObject];
    
    NSError *error = nil;
    BOOL success = [documentsUrl setResourceValue: [NSNumber numberWithBool: YES]
                                           forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error in disabling %@ from backup %@", [documentsUrl lastPathComponent], error);
    }
}

- (void)testInternetConnection {
    
    if (![OTRApi hasConnection]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertViewWithTitle:@"Oops" andWithMessage:@"No internet connection found. Kindly check your connectivity to proceed"];
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


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Retry"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self testInternetConnection];
}


@end
