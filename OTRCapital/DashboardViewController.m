//
//  DashboardViewController.m
//  ORTCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "DashboardViewController.h"
#import "OTRManager.h"
#import "AppDelegate.h"

@interface DashboardViewController ()
- (IBAction)onContactUsButtonPressed:(id)sender;
- (IBAction)onSignOutButtonPressed:(id)sender;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void) viewDidAppear:(BOOL)animated{
    static BOOL isListFetched = NO;
    if (!isListFetched) {
        isListFetched = YES;
        CGPoint viewCenter = self.view.center;
        UIView *spinner = [[OTRManager sharedManager] getSpinnerViewBlockerWithPosition:viewCenter];
        [self.view addSubview:spinner];
        [[OTRManager sharedManager] setDelegate:self];
        [[OTRManager sharedManager] loadCustomerDataDictionary];
        [[OTRManager sharedManager] fetchCustomerDetail];
    }
}

- (void) viewDidDisappear:(BOOL)animated{
    [[OTRManager sharedManager] setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)factorLoadButtonPressed:(id)sender {
    
    [[OTRManager sharedManager] initOTRInfo];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:DATA_TYPE_LOAD_FACTOR forKey:KEY_FACTOR_TYPE];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoadFactorViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)advanceButtonPressed:(id)sender {
    
    [[OTRManager sharedManager] initOTRInfo];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:DATA_TYPE_ADVANCE_LOAN forKey:KEY_FACTOR_TYPE];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"AdvanceLoanViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)brokerCheckButtonPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"BrokerCheckViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)historyButtonPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)onContactUsButtonPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ContactUsViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSignOutButtonPressed:(id)sender {
    [[OTRManager sharedManager] removeObjectForKey:KEY_LOGIN_USER_NAME];
    [[OTRManager sharedManager] removeObjectForKey:KEY_LOGIN_PASSWORD];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToLoginController];
}

- (void) onOTRRequestSuccessWithData:(NSDictionary *)data{
    NSMutableDictionary *customerData = [NSMutableDictionary new];
    NSArray *customerDetail = [data objectForKey:@"data"];
    for (NSDictionary *obj in customerDetail) {
        NSString *name = [obj objectForKey:KEY_OTR_RESPONSE_BROKER_NAME];
        if (name == nil || [name isEqual:[NSNull null]] || [name isEqualToString:@""]) {
            continue;
        }
        NSString *mcn = [obj objectForKey:KEY_OTR_RESPONSE_MC_NUMBER];
        if (mcn == nil || [mcn isEqual:[NSNull null]]) {
            mcn = @"";
        }
        NSNumber *pkey = [obj objectForKey:KEY_OTR_RESPONSE_PKEY];
        if (pkey == nil || [pkey isEqual:[NSNull null]]) {
            continue;
        }
        NSDictionary *otrInfoObj = @{KEY_OTR_RESPONSE_MC_NUMBER:mcn, KEY_OTR_RESPONSE_PKEY:pkey};
        [customerData setObject:otrInfoObj forKey:name];
    }
    [[OTRManager sharedManager] saveCustomerDataDictionary:customerData];
    [[OTRManager sharedManager] saveRecordFetchDate];
    [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
}
- (void) onOTRRequestFailWithError:(NSString *)error{
    [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
}
@end
