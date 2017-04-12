//
//  BrokerDetailViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 18/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "BrokerDetailViewController.h"
#import "OTRManager.h"
#import "LoadFactorViewController.h"
#import "AdvanceLoanViewController.h"

@interface BrokerDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *txtBrokerName;
@property (strong, nonatomic) IBOutlet UILabel *txtMCNumber;
@property (strong, nonatomic) IBOutlet UILabel *txtDotNumber;
@property (strong, nonatomic) IBOutlet UILabel *txtLocation;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *txtPhoneNumber;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *txtcreditCheckResult;
@property (strong, nonatomic) IBOutlet UIButton *btnAdvanceLoan;
@property (strong, nonatomic) IBOutlet UIButton *btnFactorLoad;

@end

@implementation BrokerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Broker Detail";
    self.txtBrokerName.text = [self.data objectForKey:@"Name"];
    NSString *mcn = [self.data objectForKey:@"McNumber"];
    if (mcn == nil || [mcn isEqual:[NSNull null]] || [mcn isEqualToString:@""]) {
        mcn = @"Not Available";
    }
    self.txtMCNumber.text = mcn;
    NSString *creditCheckResult = [self.data objectForKey:@"CreditCheckResult"];
    if (creditCheckResult == nil || [creditCheckResult isEqual:[NSNull null]] || [creditCheckResult isEqualToString:@""]) {
        creditCheckResult = @"Call Office";
    }
    self.txtcreditCheckResult.text = creditCheckResult;
    if ([creditCheckResult isEqualToString:@"Call Office"]) {
        [self.btnAdvanceLoan setEnabled:false];
        [self.btnFactorLoad setEnabled:false];
        self.txtcreditCheckResult.textColor = [UIColor redColor];
        
        NSRange range = [self.txtcreditCheckResult.text rangeOfString:self.txtcreditCheckResult.text];
        [self.txtcreditCheckResult addLinkToPhoneNumber:OTR_CONTACT_NO withRange:range];
        [self.txtcreditCheckResult setDelegate:self];
    }
    else{
        self.txtcreditCheckResult.textColor = [UIColor greenColor];
    }
    
    NSString *dotNumber = [self.data objectForKey:@"DotNumber"];
    if (dotNumber == nil || [dotNumber isEqual:[NSNull null]] || [dotNumber isEqualToString:@""]) {
        dotNumber = @"Not Available";
    }
    
    self.txtDotNumber.text = dotNumber;

    NSString *state = [self.data objectForKey:@"State"];
    NSString *city = [self.data objectForKey:@"City"];
    self.txtLocation.text = [NSString stringWithFormat:@"%@, %@", city, state];
    self.txtPhoneNumber.text = [self.data objectForKey:@"Phone"];
    
    if (![self.txtPhoneNumber.text isEqualToString:@""]) {
        NSRange range = [self.txtPhoneNumber.text rangeOfString:self.txtPhoneNumber.text];
        [self.txtPhoneNumber addLinkToPhoneNumber:[NSString stringWithFormat:@"tel:%@",self.txtPhoneNumber.text] withRange:range];
        [self.txtPhoneNumber setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onLoadFactorButtonPressed:(id)sender {
    [[OTRManager sharedManager] initOTRInfo];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:DATA_TYPE_LOAD_FACTOR forKey:KEY_FACTOR_TYPE];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoadFactorViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoadFactorViewController"];
    vc.data = self.data;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onNeedAdvanceButtonPressed:(id)sender {
    [[OTRManager sharedManager] initOTRInfo];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:DATA_TYPE_ADVANCE_LOAN forKey:KEY_FACTOR_TYPE];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AdvanceLoanViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AdvanceLoanViewController"];
    vc.data = self.data;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


@end
