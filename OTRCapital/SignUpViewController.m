//
//  SignUpViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 17/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcLogoHeight;

- (IBAction)onFbButtonPressed:(id)sender;
- (IBAction)onGPlusButtonPressed:(id)sender;
- (IBAction)onInstraButtonPressed:(id)sender;
- (IBAction)onLinkedInButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;
- (IBAction)onCallButtonPressed:(id)sender;
- (IBAction)onEmailButtonPressed:(id)sender;
- (IBAction)onSignUpButtonPressed:(id)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = @"\u2022 How we can help be the bridge to your success!\n\u2022 We offer same-day funding on approval invoices/PODS\n\u2022 24/7 online credit checking on new and existing customers\n\u2022 Presonalized, responsive service with a primary account manager\n\u2022 Invoicing services, reducing your paperwork requirement\n\u2022 Collection management services\n\u2022 Flexible factoring - we do NOT require all of your accounts to be factored with us\n\u2022 Funding completed by direct deposit or wire transfer (same day or next day paymnet option)\n\u2022 No monthly minimum\n\u2022 Advances up to 50% 7 days a week 8 AM to 8 PM est.";
    
    self.tvDescription.text = text;
    self.lcLogoHeight.active = IS_IPHONE_4;
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

- (IBAction)onCallButtonPressed:(id)sender {
    NSString *phoneNumber = @"tel:07708820124";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)onEmailButtonPressed:(id)sender {
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@otrcapital.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setToRecipients:toRecipents];
    if (mc) {
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (IBAction)onSignUpButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://otrcapital.com/apply-now"]];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
