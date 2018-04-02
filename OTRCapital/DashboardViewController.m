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
#import "OTRUser+DB.h"
#import "MAImagePickerController.h"
#import "AssetsLibrary/AssetsLibrary.h"

@interface DashboardViewController () <UIActionSheetDelegate, MAImagePickerControllerDelegate>
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

    if(![OTRUser isAuthorized]) {
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
             [OTRDefaults saveRecordFetchDate];
            [self parseCustomerDetailsData:data completion:nil];
        }
    }];
}

- (void)parseCustomerDetailsData:(NSDictionary *)data completion:(MRSaveCompletionHandler)block {
    NSArray *customerDetail = [data objectForKey:@"data"];

    [[OTRHud hud] show];
    
    NSMutableArray *mNotes = [NSMutableArray new];
    NSMutableArray *namesList = [NSMutableArray array];
    
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
        NSNumber *factorable = [obj objectForKey:@"Factorable"];
        if (pkey == nil || [pkey isEqual:[NSNull null]]) {
            continue;
        }
        
        if([name isEqualToString:@"Flat"]) {
            NSLog(@"%@", name);
        }
        
        OTRCustomerNote *note = [OTRCustomerNote new];
        note.name = name;
        note.mc_number = mcn;
        note.pkey = pkey;
        note.factorable = factorable;
        [mNotes addObject:note];
        
        [namesList addObject: name];
    }
    
    [[NSManagedObjectContext MR_defaultContext] setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
    
        [OTRCustomer MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"(name IN %@)", namesList] inContext:localContext];
        
        for (OTRCustomerNote *obj in mNotes) {
            OTRCustomer * item = [OTRCustomer MR_createEntityInContext:localContext];
            item.name = obj.name;
            item.mc_number = obj.mc_number;
            item.pkey = obj.pkey;
            item.factorable = obj.factorable;
        }
    } completion:^(BOOL success, NSError *error) {
        [[OTRHud hud] hide];
        if(block) {
            block(success, error);
        }
    }];
}

- (IBAction)onSignOutButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

- (IBAction)scanDocumentsButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Scan documents:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera", @"From Photo Gallery", nil];
    [actionSheet setTag:10];
    [actionSheet showInView:self.view];
}

- (void)scanViaCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypeCamera];
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted) {
                [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypeCamera];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:@"Camera permission not granted"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
}

- (void)scanViaGallery {
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if(authStatus == ALAuthorizationStatusAuthorized) {
        [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypePhotoLibrary];
    } else {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypePhotoLibrary];
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Photo library permission not granted"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) {
            [self scanViaCamera];
        }else if (buttonIndex == 1) {
            [self scanViaGallery];
        }
        return;
    }
    
    if(buttonIndex == 0) {
        [OTRUser logOut];
        
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
        [[OTRManager sharedManager] setOTRInfoValueOfTypeString:DATA_TYPE_ADVANCE_LOAN forKey:KEY_FACTOR_TYPE];
    }else if ([[segue identifier] isEqualToString:@"LoadFactorViewController"]) {
        [[OTRManager sharedManager] initOTRInfo];
        [[OTRManager sharedManager] setOTRInfoValueOfTypeString:DATA_TYPE_LOAD_FACTOR forKey:KEY_FACTOR_TYPE];
    }
}


#pragma mark - ImagePicker and camera access methods

- (void)checkForCameraPermission {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypeCamera];
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted) {
                [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypeCamera];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:@"Camera Permission not granted."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
}

- (void)checkForPhotoLibraryPermission {
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if(authStatus == ALAuthorizationStatusAuthorized) {
        [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypePhotoLibrary];
    } else {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [self openScanPickerWithSourceType:MAImagePickerControllerSourceTypePhotoLibrary];
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:@"Photo Library Permission not granted."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
        }];
    }
}

- (void)openScanPickerWithSourceType:(MAImagePickerControllerSourceType)sourceType {
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
    [imagePicker setDelegate: self];
    [imagePicker setSourceType:sourceType];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)imagePickerDidCancelWithViewController: (UIViewController*) controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerDidChooseImage: (UIImage *)image andWithViewController: (UIViewController*) controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        __block DashboardViewController *blockedSelf = self;
        [blockedSelf showShareImageDialog: image];
    }];
}

- (void)showShareImageDialog:(UIImage *)image {
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [[documentsPaths objectAtIndex:0] stringByAppendingString:@"/document.pdf"];
    CGSize pdfPageSize = CGSizeMake(612.0, 792.0);
    UIGraphicsBeginPDFContextToFile(documentPath, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pdfPageSize.width, pdfPageSize.height), nil); // default pdf page size is 612 x 792.
    [image drawInRect:CGRectMake(0.0, 0.0, pdfPageSize.width, pdfPageSize.height)];
    UIGraphicsEndPDFContext();
    
    NSData *document = [NSData dataWithContentsOfFile:documentPath];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[document] applicationActivities:nil];
    controller.popoverPresentationController.sourceView = self.view;
    controller.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypePostToFacebook];
    [controller setValue:@"DOCUMENT SENT USING OTR APP" forKey:@"subject"];
    [self presentViewController:controller animated:YES completion:nil];
}


@end
