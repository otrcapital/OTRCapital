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
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

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
    [self.emailLabel setText:[[OTRManager sharedManager] contactEmail]];
    
    NSString *address = [[OTRManager sharedManager] contactAddress];
    address = [address stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    [self.addressLabel setText:address];
}

- (IBAction)onFbButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[OTRManager sharedManager] urlFacebook]]];
}

- (IBAction)onGPlusButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[OTRManager sharedManager] urlGooglePlus]]];
}

- (IBAction)onInstraButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[OTRManager sharedManager] urlInstagram]]];
}

- (IBAction)onLinkedInButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[OTRManager sharedManager] urlLinkedin]]];
}

- (IBAction)onTwitterButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[OTRManager sharedManager] urlTwitter]]];
}

- (IBAction)onCallButtonPressed:(id)sender {
    NSString *phoneNumber = [[OTRManager sharedManager] telNumberFormatted];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)onEmailButtonTap:(id)sender {
    NSArray *toRecipents = [NSArray arrayWithObject:[[OTRManager sharedManager] contactEmail]];
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
