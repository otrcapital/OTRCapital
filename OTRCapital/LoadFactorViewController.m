//
//  LoadFactorViewController.m
//  ORTCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "LoadFactorViewController.h"
#import "ImageAdjustmentViewController.h"
#import "OTRManager.h"
#import "DocumentOptionalPropertiesViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"

#define SLIDER_VIEW_SHIFT_BY_Y 10

#define TOTAL_PAY_TEXTFIELD_TAG 10
#define TOTAL_DEDUCTION_TEXTFIELD_TAG 11

const static NSInteger lbDescriptionHeight = 30;

@interface LoadFactorViewController ()
{
    NSMutableArray *muary_Interest_Main;
    NSMutableArray *muary_Interest_Sub;
    UITapGestureRecognizer *tapper;
}
@property (weak, nonatomic) IBOutlet UISwitch *comdataFuelCardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *EFSSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *wireSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ACHswitch;
@property (weak, nonatomic) IBOutlet UILabel *lblBrokerName;
@property (weak, nonatomic) IBOutlet UITextField *txtFdBrokerName;
@property (weak, nonatomic) IBOutlet UITextField *txtFdLoadNo;
@property (weak, nonatomic) IBOutlet UITextField *txtFdTotalPay;
@property (weak, nonatomic) IBOutlet UITextField *txtFdTotalDeduction;
@property (weak, nonatomic) IBOutlet UIView *viewTotalPay;
@property (weak, nonatomic) IBOutlet UIView *viewTotalDeduction;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescription1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescription2Height;
@property (weak, nonatomic) IBOutlet UITableView *tbl_Search;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) NSArray *brokerList;
@end

@implementation LoadFactorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Factor a Load";
    self.txtFdBrokerName.delegate = self;
    self.txtFdLoadNo.delegate = self;
    self.txtFdTotalPay.delegate = self;
    self.txtFdTotalPay.tag = TOTAL_PAY_TEXTFIELD_TAG;
    self.txtFdTotalDeduction.delegate = self;
    self.txtFdTotalDeduction.tag = TOTAL_DEDUCTION_TEXTFIELD_TAG;
    self.originalCenter = self.view.center;
    self.brokerList = [[OTRManager sharedManager] getBrokersList];
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    muary_Interest_Main = [NSMutableArray arrayWithArray:self.brokerList];
    muary_Interest_Sub = [[NSMutableArray alloc]init];
    

    [self.tbl_Search registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.tbl_Search setHidden:TRUE];

    if (self.data && [self.data objectForKey:@"Name"]) {
        self.txtFdBrokerName.text = [self.data objectForKey:@"Name"];
    }
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.lblDescription1Height.constant = 0;
    self.lblDescription2Height.constant = 0;
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
    
    self.lblDescription1Height.constant = 0;
    self.lblDescription2Height.constant = 0;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
    self.lblDescription1Height.constant = 0;
    self.lblDescription2Height.constant = 0;
    
    if (textField == self.txtFdBrokerName) {
        [self.txtFdLoadNo becomeFirstResponder];
    }
    else if (textField == self.txtFdLoadNo) {
        [self.txtFdTotalPay becomeFirstResponder];
    }
    else if (textField == self.txtFdTotalPay) {
        [self.txtFdTotalDeduction becomeFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    float newlblDescription1Height = 0;
    float newlblDescription2Height = 0;
    
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:@"Begin"];
    }
    if (textField == self.txtFdTotalDeduction || textField == self.txtFdTotalPay) {
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y * 0.5);
    }
    else{
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y * 0.75);
    }
    if (textField == self.txtFdBrokerName) {
        //self.lblDescription.text = @"";
    }
    else if (textField == self.txtFdLoadNo) {
        //self.lblDescription.text = @"";
    }
    else if (textField == self.txtFdTotalPay) {
        newlblDescription1Height = lbDescriptionHeight;
        newlblDescription2Height = 0;
    }
    else if (textField == self.txtFdTotalDeduction) {
        newlblDescription1Height = 0;
        newlblDescription2Height = lbDescriptionHeight;
    }
    
    if(self.lblDescription1Height.constant != newlblDescription1Height) {
        self.lblDescription1Height.constant = newlblDescription1Height;
    }
    if(self.lblDescription2Height.constant != newlblDescription2Height) {
        self.lblDescription2Height.constant = newlblDescription2Height;
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.center = self.originalCenter;
    self.tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:string];
    }
    return YES;
}

-(void) searchText:(UITextField *)textField replacementString:(NSString *)string
{
    NSString *str_Search_String=[NSString stringWithFormat:@"%@",textField.text];
    if([string isEqualToString:@"Begin"])
        str_Search_String = [NSString stringWithFormat:@"%@",textField.text];
    else if([string isEqualToString:@""])
        str_Search_String = [str_Search_String substringToIndex:[str_Search_String length] - 1];
    else
        str_Search_String = [str_Search_String stringByAppendingString:string];
    
    muary_Interest_Sub=[[NSMutableArray alloc] init];
    if(str_Search_String.length > 0)
    {
        NSInteger counter = 0;
        for(NSString *name in muary_Interest_Main)
        {
            NSRange r = [name rangeOfString:str_Search_String options:NSCaseInsensitiveSearch];
            if(r.length > 0)
            {
                [muary_Interest_Sub addObject:name];
            }
            
            counter++;
            
        }
        
        if (muary_Interest_Sub.count > 0)
        {
            self.tbl_Search.hidden = FALSE;
            tapper.enabled = NO;
            [self.tbl_Search reloadData];
        }
        else
        {
            self.tbl_Search.hidden = TRUE;
            tapper.enabled = YES;
        }
    }
    else
    {
        [self.tbl_Search setHidden:TRUE];
        tapper.enabled = YES;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [muary_Interest_Sub count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    }
    cell.textLabel.text = [muary_Interest_Sub objectAtIndex:indexPath.row];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (!muary_Interest_Sub.count && muary_Interest_Sub.count < indexPath.row) {
        return;
    }
    self.txtFdBrokerName.text = [muary_Interest_Sub objectAtIndex:indexPath.row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerDidCancelWithViewController: (UIViewController*) controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerDidChooseImage: (UIImage *)image andWithViewController: (UIViewController*) controller
{
    [[OTRManager sharedManager] saveImage:image];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumentOptionalPropertiesViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DocumentOptionalPropertiesViewController"];
    [vc initLoadFactor];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSwitchPressed:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    [self.ACHswitch setOn:NO animated:self.ACHswitch.isOn];
    [self.wireSwitch setOn:NO animated:self.wireSwitch.isOn];
    [self.EFSSwitch setOn:NO animated:self.EFSSwitch.isOn];
    [self.comdataFuelCardSwitch setOn:NO animated:self.comdataFuelCardSwitch.isOn];
    [switcher setOn:!switcher.isOn animated:YES];
}

- (IBAction)onScanButtonPressed:(id)sender {
    if ([self validateAllFields]) {
        [self checkForCameraPermission];
    }
}

- (IBAction)onPhotoGalleryButtonPressed:(id)sender {
    if ([self validateAllFields]) {
        [self checkForPhotoLibraryPermission];
    }
}

- (BOOL)validateAllFields {
    if (![self isValidInfo]) {
        [self showAlertViewWithTitle:@"Information Missing" andWithMessage:@"Some of required fields are missing. Or Broker Name is incorect. Kindly correct it out to continue."];
        return false;
    }
    else if(![self isValidInvioceAmount]) {
        [self showAlertViewWithTitle:@"Invalid Invoice Value" andWithMessage:@"One of the Total Pay or Total Deduction amount is invalid, kindly recheck the amount."];
        return false;
    }
    else if (!self.ACHswitch.isOn && !self.wireSwitch.isOn && !self.EFSSwitch.isOn && !self.comdataFuelCardSwitch.isOn) {
        [self showAlertViewWithTitle:@"Invalid Value" andWithMessage:@"Please, turn on one of the sliders."];
        return false;
    }
    else {
        [self saveInfo];
        return true;
    }
}

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
                    [self showAlertViewWithTitle:@"Camera Permission not Granted." andWithMessage:@"Error"];
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
                [self showAlertViewWithTitle:@"Photo Library Permission not Granted." andWithMessage:@"Error"];
            });
        }];
    }
}

- (void)openScanPickerWithSourceType:(MAImagePickerControllerSourceType*)sourceType {
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (BOOL) isValidInfo{
    
    NSString *brokerName = self.txtFdBrokerName.text;
    NSString *loadNo = self.txtFdLoadNo.text;
    if ([brokerName  isEqual: @""] || [loadNo  isEqual: @""]) {
        return NO;
    }
    BOOL isValidBrokerName = NO;
    for(NSString *name in muary_Interest_Main){
        if([name isEqual:brokerName]){
            isValidBrokerName = YES;
            break;
        }
    }
    return isValidBrokerName;
}

- (BOOL) isValidInvioceAmount{
    NSString *totalPay = self.txtFdTotalPay.text;
    NSString *totalDeduction = self.txtFdTotalDeduction.text;
    if ([totalDeduction isEqual:@""]) {
        totalDeduction = @"0";
    }
    BOOL isValidInt = [self isValidAmoutLitral:totalPay] && [self isValidAmoutLitral:totalDeduction];
    if (!isValidInt) {
        return false;
    }
    float invoiceAmount = [totalPay floatValue] - [totalDeduction floatValue];
    return invoiceAmount >= 0;
}

- (BOOL) isValidAmoutLitral: (NSString*) toCheck{
    NSScanner* scan = [NSScanner scannerWithString:toCheck];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

- (void) saveInfo{
    NSString *brokerName = self.txtFdBrokerName.text;
    NSString *switchValue = @"";
    if (self.ACHswitch.isOn) {
        switchValue = @"ACH";
    } else if (self.wireSwitch.isOn) {
        switchValue = @"WIRE";
    }  else if (self.EFSSwitch.isOn) {
        switchValue = @"EFS";
    } else if (self.comdataFuelCardSwitch.isOn) {
        switchValue = @"Comdata Fuel Card";
    }
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:switchValue forKey:KEY_ADVANCED_REQUEST_TYPE];
    
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:brokerName forKey:KEY_BROKER_NAME];
    NSString *mcn = [[OTRManager sharedManager] getMCNumberByBrokerName:brokerName];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:mcn forKey:KEY_MC_NUMBER];
    NSString *pKey = [[OTRManager sharedManager] getPKeyByBrokerName:brokerName];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:pKey forKey:KEY_PKEY];
    NSString *loadNo = self.txtFdLoadNo.text;
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:loadNo forKey:KEY_LOAD_NO];
    NSString *totalPay = self.txtFdTotalPay.text;
    if ([totalPay isEqualToString:@""]) {
        totalPay = @"0";
    }
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:totalPay forKey:KEY_TOTAL_PAY];
    NSString *totalDeduction = self.txtFdTotalDeduction.text;
    if ([totalDeduction isEqualToString:@""]) {
        totalDeduction = @"0";
    }
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:totalDeduction forKey:KEY_TOTAL_DEDUCTION];
    float invoiceAmount = [totalPay floatValue] - [totalDeduction floatValue];
    NSString *invoiceString = [NSString stringWithFormat:@"%.2f", invoiceAmount];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:invoiceString forKey:KEY_INVOICE_AMOUNT];
}

- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
