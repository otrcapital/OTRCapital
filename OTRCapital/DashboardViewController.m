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
#import "DBHelper.h"

@interface DashboardViewController () <UIActionSheetDelegate>
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
        
        NSArray *items = [OTRCustomer MR_findAll];
        NSString *lastFetchDate = [OTRDefaults getStringForKey:KEY_OTR_RECORD_FETCH_DATE];
        
        if (!lastFetchDate || items.count == 0) {
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
                [self parseCustomerDetailsData:json completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    [self fetchBrokerDetailsWithDate:lastFetchDate];
                }];
                return;
            }
        }
        [self fetchBrokerDetailsWithDate:lastFetchDate];
    }
}

- (void)fetchBrokerDetailsWithDate:(NSString *)dateString {
    [[OTRHud hud] show];
    [[OTRApi instance] fetchCustomerDetails:dateString ?: @"2015/10/18" withCompletion:^(NSDictionary *data, NSError *error) {
        [[OTRHud hud] hide];
        if(data && !error) {
            [self parseCustomerDetailsData:data completion:nil];
        }
    }];
}

- (void)parseCustomerDetailsData:(NSDictionary *)data completion:(MRSaveCompletionHandler)block {
    
    [[OTRHud hud] show];
    
    NSArray *customerDetail = [data objectForKey:@"data"];
    NSArray *namesList = [customerDetail valueForKey:@"Name"];
    
    [[NSManagedObjectContext MR_defaultContext] setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
    
        [OTRCustomer MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"(name IN %@)", namesList] inContext:localContext];
        
        for (NSDictionary *obj in customerDetail) {
            NSString *name = [obj objectForKey:@"Name"];
            if (name == nil || [name isEqual:[NSNull null]] || [name isEqualToString:@""]) {
                continue;
            }
            NSString *mcn = [obj objectForKey:@"McNumber"];
            if (mcn == nil || [mcn isEqual:[NSNull null]]) {
                mcn = @"";
            }
            NSNumber *pkey = [obj objectForKey:@"PKey"];
            if (pkey == nil || [pkey isEqual:[NSNull null]]) {
                continue;
            }
            
            OTRCustomer * item = [OTRCustomer MR_createEntityInContext:localContext];
            item.name = name;
            item.mc_number = mcn;
            item.pkey = pkey;
        }
    } completion:^(BOOL success, NSError *error) {
        [[OTRHud hud] hide];
        if(block) {
            block(success, error);
        }
    }];
    
    [OTRDefaults saveRecordFetchDate];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[OTRManager sharedManager] setDelegate:nil];
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


#pragma merk - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"AdvanceLoanViewController"]) {
        [[OTRManager sharedManager] initOTRInfo];
    }else if ([[segue identifier] isEqualToString:@"LoadFactorViewController"]) {
        [[OTRManager sharedManager] initOTRInfo];
    }
}



@end
