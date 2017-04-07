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
#import "OTRApi.h"

@interface DashboardViewController () <UIActionSheetDelegate>
- (IBAction)onContactUsButtonPressed:(id)sender;
- (IBAction)onSignOutButtonPressed:(id)sender;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(![OTRDefaults getStringForKey:KEY_LOGIN_USER_NAME]) {
        return;
    }
    static BOOL isListFetched = NO;
    if (!isListFetched) {
        isListFetched = YES;
        CGPoint viewCenter = self.view.center;
        UIView *spinner = [[OTRManager sharedManager] getSpinnerViewBlockerWithPosition:viewCenter];
        [self.view addSubview:spinner];
        [[OTRManager sharedManager] loadCustomerDataDictionary];
        
        NSString *lastFetchDate = [OTRDefaults getStringForKey:KEY_OTR_RECORD_FETCH_DATE];
        
        if (!lastFetchDate) {
            NSString* path = [[NSBundle mainBundle] pathForResource:@"OTR_Broker_Info_Default"
                                                             ofType:@"txt"];
            NSString* content = [NSString stringWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
            NSError *jsonError;
            NSData *objectData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            if(!jsonError) {
                [self parseCustomerDetailsData:json];
            }
        }
        
        [[OTRApi instance] fetchCustomerDetails:lastFetchDate withCompletion:^(NSDictionary *data, NSError *error) {
            [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
            if(data && !error) {
                [self parseCustomerDetailsData:data];
            }
        }];
    }
}

- (void)parseCustomerDetailsData:(NSDictionary *)data {
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
    [OTRDefaults saveRecordFetchDate];
    [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[OTRManager sharedManager] setDelegate:nil];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        [[OTRManager sharedManager] removeObjectForKey:KEY_LOGIN_USER_NAME];
        [[OTRManager sharedManager] removeObjectForKey:KEY_LOGIN_PASSWORD];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *controller = [sb instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

@end
