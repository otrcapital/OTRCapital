//
//  LoginViewController.m
//  ORTCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "OTRApi.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) CGPoint originalCenter;
- (IBAction)onFbButtonPressed:(id)sender;
- (IBAction)onGPlusButtonPressed:(id)sender;
- (IBAction)onInstraButtonPressed:(id)sender;
- (IBAction)onLinkedInButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;
- (IBAction)inContactUsButtonPressed:(id)sender;
- (IBAction)onSignUpButtonPressed:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.originalCenter = self.view.center;
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void) viewDidAppear:(BOOL)animated{
    [[OTRManager sharedManager] setDelegate:self];
}

- (void) viewDidDisappear:(BOOL)animated{
    [[OTRManager sharedManager] setDelegate:nil];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.loginButton sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y * 0.75);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.center = self.originalCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(BOOL) IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)loginButtonPressed:(id)sender{
    self.email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    if ([self.email isEqual:@""] || [password isEqual:@""]) {
        [self showAlertViewWithTitle:@"Error" andWithMessage:@"Missing e-mail or password."];
    }
    else if (![self IsValidEmail:self.email]) {
        [self showAlertViewWithTitle:@"Error" andWithMessage:@"Incorrect e-mail. Please provide valid email to continue."];
    }
    else {
        CGPoint viewCenter = self.view.center;
        UIView *spinner = [[OTRManager sharedManager] getSpinnerViewBlockerWithPosition:viewCenter];
        [self.view addSubview:spinner];
        [[CrashlyticsManager sharedManager]setUserEmail:self.email];
        __block LoginViewController *blockedSelf = self;
        [[OTRApi instance] loginWithUsername:self.email andPassword:password completionBlock:^(NSDictionary *responseData, NSError *error) {
            if(responseData && !error) {
                [[CrashlyticsManager sharedManager]trackUserLoginWithEmail:self.email andSuccess:YES];
                [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
                
                NSString *isValid = [responseData objectForKey:@"IsValidUser"];
                
                if ([isValid boolValue]) {
                    [[CrashlyticsManager sharedManager] setUserWithId:[responseData objectForKey:@"ClientId"] andName:[responseData objectForKey:@"Login"]];
                    [OTRDefaults saveString:[responseData objectForKey:@"Login"] forKey:KEY_LOGIN_USER_NAME];
                    [OTRDefaults saveString:[responseData objectForKey:@"Password"] forKey:KEY_LOGIN_PASSWORD];
                    
                    [blockedSelf dismissViewControllerAnimated:YES completion:nil];
                }
                else{
                    [blockedSelf showAlertViewWithTitle:@"Error" andWithMessage:@"Failed to verify e-mail or password."];
                }
            }else {
                [[CrashlyticsManager sharedManager]trackUserLoginWithEmail:self.email andSuccess:NO];
                [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
                
                [self showAlertViewWithTitle:@"Error" andWithMessage:@"Failed to verify e-mail or password."];
            }
        }];
    }
}

- (IBAction)onFbButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/OTR-Capital/473947932696034"]];
}

- (IBAction)onGPlusButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://plus.google.com/112871732199319272036/about?hl=en"]];
}

- (IBAction)onInstraButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://instagram.com/otrcapital/"]];
}

- (IBAction)onLinkedInButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.linkedin.com/company/otr-capital"]];
}

- (IBAction)onTwitterButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/otrcapitalllc"]];
}

- (IBAction)inContactUsButtonPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ContactUsViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSignUpButtonPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
