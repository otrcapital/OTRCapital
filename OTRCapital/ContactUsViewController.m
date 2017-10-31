//
//  ContactUsViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 17/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "ContactUsViewController.h"
#import "OTRManager.h"

@interface ContactUsViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *logo;
@property (nonatomic, weak) IBOutlet UILabel *cellLabel;
@property (nonatomic, weak) IBOutlet UILabel *faxLabel;

- (IBAction)onFbButtonPressed:(id)sender;
- (IBAction)onGPlusButtonPressed:(id)sender;
- (IBAction)onInstraButtonPressed:(id)sender;
- (IBAction)onLinkedInButtonPressed:(id)sender;
- (IBAction)onTwitterButtonPressed:(id)sender;
- (IBAction)onCallButtonPressed:(id)sender;

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logo.hidden = IS_IPHONE_4;
    
    [self.cellLabel setText:[[OTRManager sharedManager] telNumber]];
    [self.faxLabel setText:[[OTRManager sharedManager] faxNumber]];
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
    NSString *phoneNumber = [[OTRManager sharedManager] telNumberFormatted];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)onEmailButtonTap:(id)sender {
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@otrcapital.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (mc) {
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        [mc setSubject:@"Feedback"];
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
