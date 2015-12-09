//
//  AppDelegate.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "OTRManager.h"
#import "Reachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void) switchToDashboardController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [sb instantiateViewControllerWithIdentifier:@"DashboardViewController"];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
}

- (void) switchToLoginController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:
                   [[UIScreen mainScreen] bounds]];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [sb instantiateViewControllerWithIdentifier:@"SplashScreen"];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    [self testInternetConnection];
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

- (void)testInternetConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertViewWithTitle:@"Oops" andWithMessage:@"No internet connection found. Kindly check your connectivity to proceed"];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[OTRManager sharedManager] getStringForKey:KEY_LOGIN_USER_NAME]){
                NSString *email = [[OTRManager sharedManager] getStringForKey:KEY_LOGIN_USER_NAME];
                NSString *password = [[OTRManager sharedManager] getStringForKey:KEY_LOGIN_PASSWORD];
                [[OTRManager sharedManager] setDelegate:self];
                [[OTRManager sharedManager] loginWithUserName:email andEncodedPassword:password];
            }
            else{
                [self switchToLoginController];
            }
        });
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

- (void) onOTRRequestSuccessWithData:(NSDictionary *)data{
    [[OTRManager sharedManager] setDelegate:nil];
    NSString *isValid = [data objectForKey:@"IsValidUser"];
    
    if ([isValid boolValue]) {
        [self switchToDashboardController];
    }
    else{
        [self switchToLoginController];
    }
}
- (void) onOTRRequestFailWithError:(NSString *)error{
    [[OTRManager sharedManager] setDelegate:nil];
    [self switchToLoginController];
}

@end
