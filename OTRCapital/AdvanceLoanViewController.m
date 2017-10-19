//
//  AdvanceLoanViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "AdvanceLoanViewController.h"
#import "OTRManager.h"
#import "ImageAdjustmentViewController.h"
#import "DocumentOptionalPropertiesViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "OTRCustomer+DB.h"

#define SLIDER_VIEW_SHIFT_BY_Y 10

#define TOTAL_PAY_TEXTFIELD_TAG 10
#define TOTAL_DEDUCTION_TEXTFIELD_TAG 11

#define TEXT_COMCHECK_PHONE_NUMBER_ALERT_VIEW_TAG 101
#define PHONE_NUMBER_PATTERN  @"(###) ### - ####"

@interface AdvanceLoanViewController () {
    NSMutableArray *muary_Interest_Main;
    NSMutableArray *muary_Interest_Sub;
    UITapGestureRecognizer *tapper;
}
@property (weak, nonatomic) IBOutlet UISwitch *comdataFuelCardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *emailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *textComcheckSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *EFSswitch;
@property (weak, nonatomic) IBOutlet UILabel *lblBrokerName;
@property (weak, nonatomic) IBOutlet UITextField *txtFdBrokerName;
@property (weak, nonatomic) IBOutlet UITextField *txtFdLoadNo;
@property (weak, nonatomic) IBOutlet UITextField *txtFdTotalPay;
@property (weak, nonatomic) IBOutlet UITextField *txtFdTotalDeduction;
@property (weak, nonatomic) IBOutlet UIView *viewTotalPay;
@property (weak, nonatomic) IBOutlet UIView *viewTotalDeduction;
@property (weak, nonatomic) IBOutlet UITableView *brokerTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblDescription1Height;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblDescription2Height;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) NSArray *brokerList;
@property (strong, nonatomic) NSString *textComcheckPhoneNumber;
@property (strong, nonatomic) UIAlertView *textComcheckAlert;
@property int tblSearchX;
@property int tblSearchY;
@end

@implementation AdvanceLoanViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.txtFdBrokerName.delegate = self;
    self.txtFdLoadNo.delegate = self;
    self.txtFdTotalPay.delegate = self;
    self.txtFdTotalPay.tag = TOTAL_PAY_TEXTFIELD_TAG;
    self.txtFdTotalDeduction.delegate = self;
    self.txtFdTotalDeduction.tag = TOTAL_DEDUCTION_TEXTFIELD_TAG;
    self.originalCenter = self.view.center;
    self.brokerList = [OTRCustomer getNamesList];
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    muary_Interest_Main = [NSMutableArray arrayWithArray:self.brokerList];
    muary_Interest_Sub = [[NSMutableArray alloc]init];
    
    self.tblSearchX = [self.lblBrokerName convertPoint:self.lblBrokerName.frame.origin toView:nil].x + 10;
    self.tblSearchY = [self.txtFdBrokerName convertPoint:self.txtFdBrokerName.frame.origin toView:self.view].y + self.txtFdBrokerName.frame.size.height;

    [self.brokerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
    if (self.data && [self.data objectForKey:@"Name"]) {
        self.txtFdBrokerName.text = [self.data objectForKey:@"Name"];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
    
    self.lblDescription1Height.active = YES;
    self.lblDescription2Height.active = YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.brokerTableView.hidden = TRUE;
    tapper.enabled = YES;
    
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
    self.lblDescription1Height.active = YES;
    self.lblDescription2Height.active = YES;
    
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:@"Begin"];
    }
    if (textField == self.txtFdTotalDeduction || textField == self.txtFdTotalPay) {
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y * 0.5);
    }
    else{
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y * 0.75);
    }
    if (textField == self.txtFdTotalPay) {
        self.lblDescription1Height.active = NO;
    }else if (textField == self.txtFdTotalDeduction) {
        self.lblDescription2Height.active = NO;
    }

    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if (textField == self.txtFdTotalPay || textField == self.txtFdTotalDeduction) {
        if ([textField.text length] == 0) {
            textField.text = @".00";
            UITextPosition *beginning = [textField beginningOfDocument];
            [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                                  toPosition:beginning]];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.center = self.originalCenter;
    self.brokerTableView.hidden = TRUE;
    tapper.enabled = YES;
    
    self.lblDescription1Height.active = YES;
    self.lblDescription2Height.active = YES;
    
    if (textField == self.txtFdTotalPay || textField == self.txtFdTotalDeduction) {
        [self updateCurrencyTextFieldIfNeeded:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:string];
    }
    else if (textField == [self.textComcheckAlert textFieldAtIndex:0]) {
        NSString *filter = PHONE_NUMBER_PATTERN;
        NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if(range.length == 1 && string.length < range.length &&
           [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
            NSInteger location = changedString.length - 1;
            if(location > 0) {
                for(; location > 0; location--) {
                    if(isdigit([changedString characterAtIndex:location])) {
                        break;
                    }
                }
                changedString = [changedString substringToIndex:location];
            }
        }
        textField.text = [self filteredPhoneStringFromString:changedString andWithFilter:filter];
        [textField sendActionsForControlEvents:UIControlEventEditingChanged];
        return NO;
    }
    if (textField == self.txtFdTotalPay || textField == self.txtFdTotalDeduction) {
        return [self shouldChangeCharactersForCurrencyField:textField withString:string inRange:range];
    }
    return YES;
}

- (NSMutableString*)filteredPhoneStringFromString:(NSString*)string andWithFilter:(NSString*)filter
{
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[([filter length])];
    BOOL done = NO;
    
    while(onFilter < [filter length] && !done){
        char filterChar = [filter characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#':
                if(originalChar=='\0'){
                    done = YES;
                    break;
                }
                if(isdigit(originalChar)){
                    outputString[onOutput] = originalChar;
                    onOriginal++;
                    onFilter++;
                    onOutput++;
                } else {
                    onOriginal++;
                }
                break;
            default:
                outputString[onOutput] = filterChar;
                onOutput++;
                onFilter++;
                if(originalChar == filterChar)
                    onOriginal++;
                break;
        }
    }
    outputString[onOutput] = '\0';
    return [NSMutableString stringWithUTF8String:outputString];
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
            self.brokerTableView.hidden = FALSE;
            tapper.enabled = NO;
            [self.brokerTableView reloadData];
        }
        else
        {
            self.brokerTableView.hidden = TRUE;
            tapper.enabled = YES;
        }
    }
    else
    {
        [self.brokerTableView setHidden:TRUE];
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
    [vc initAdvanceLoan];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSwitchPressed:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    [self.EFSswitch setOn:NO animated:self.EFSswitch.isOn];
    [self.textComcheckSwitch setOn:NO animated:self.textComcheckSwitch.isOn];
    [self.emailSwitch setOn:NO animated:self.emailSwitch.isOn];
    [self.comdataFuelCardSwitch setOn:NO animated:self.comdataFuelCardSwitch.isOn];
    [switcher setOn:!switcher.isOn animated:YES];
    if (switcher != self.textComcheckSwitch) {
        self.textComcheckPhoneNumber = nil;
    }
}

- (IBAction)onTextComcheckPressed:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    [self onSwitchPressed:sender];
    if (switcher.isOn) {
        self.textComcheckAlert = [[UIAlertView alloc]initWithTitle:@"Phone" message:@"Please enter phone number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        self.textComcheckAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [self.textComcheckAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypePhonePad;
        [self.textComcheckAlert textFieldAtIndex:0].text = self.textComcheckPhoneNumber;
        [self.textComcheckAlert textFieldAtIndex:0].delegate = self;
        [self.textComcheckAlert textFieldAtIndex:0].placeholder = @"xxx-xxx-xxxx";
        [self.textComcheckAlert setTag:TEXT_COMCHECK_PHONE_NUMBER_ALERT_VIEW_TAG];
        [self.textComcheckAlert show];
    
    }
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

- (void)openScanPickerWithSourceType:(MAImagePickerControllerSourceType)sourceType {
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:navigationController animated:YES completion:nil];
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
    else if (!self.EFSswitch.isOn && !self.textComcheckSwitch.isOn && !self.emailSwitch.isOn && !self.comdataFuelCardSwitch.isOn) {
        [self showAlertViewWithTitle:@"Invalid Value" andWithMessage:@"Please, turn on one of the sliders."];
        return false;
    }
    else {
        [self saveInfo];
        return true;
    }
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
    if (self.EFSswitch.isOn) {
        switchValue = @"EFS";
    } else if (self.textComcheckSwitch.isOn) {
        switchValue = @"Text Comcheck";
    }  else if (self.emailSwitch.isOn) {
        switchValue = @"Email Comcheck";
    } else if (self.comdataFuelCardSwitch.isOn) {
        switchValue = @"Comdata Fuel Card";
    }
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:switchValue forKey:KEY_ADVANCED_REQUEST_TYPE];
    if (self.textComcheckPhoneNumber != nil) {
        [[OTRManager sharedManager] setOTRInfoValueOfTypeString:self.textComcheckPhoneNumber forKey:KEY_TEXT_COMCHECK_PHONE_NUMBER];
    }
    
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:brokerName forKey:KEY_BROKER_NAME];
    OTRCustomer *broker = [OTRCustomer getByName:brokerName];
    if(broker) {
        NSString *mcn = broker.mc_number;
        NSString *pKey = [broker.pkey stringValue];
        [[OTRManager sharedManager] setOTRInfoValueOfTypeString:mcn forKey:KEY_MC_NUMBER];
        [[OTRManager sharedManager] setOTRInfoValueOfTypeString:pKey forKey:KEY_PKEY];
    }
    
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
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:totalPay forKey:KEY_INVOICE_AMOUNT];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:totalDeduction forKey:KEY_ADV_REQ_AMOUT];
}

- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == TEXT_COMCHECK_PHONE_NUMBER_ALERT_VIEW_TAG){
        if(buttonIndex == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.textComcheckPhoneNumber == nil) {
                    [self.textComcheckSwitch setOn:NO animated:YES];
                }
                self.textComcheckPhoneNumber = [alertView textFieldAtIndex:0].text;
            });
        }
        else if(buttonIndex == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textComcheckPhoneNumber = [alertView textFieldAtIndex:0].text;
            });
        }
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if(alertView.tag == TEXT_COMCHECK_PHONE_NUMBER_ALERT_VIEW_TAG){
        return ([[[alertView textFieldAtIndex:0] text] length]  < PHONE_NUMBER_PATTERN.length) ? NO : YES;
    }
    else return YES;
    
}


#pragma mark - Currency functions

- (BOOL)shouldChangeCharactersForCurrencyField:(UITextField *)textField withString:(NSString *)string inRange:(NSRange)range {
    if ([string isEqualToString:@","] || [string isEqualToString:@"."]) {
        //for repeated commas
        if([textField.text rangeOfString:@"."].location != NSNotFound) {
            return NO;
        }
        
        //for forst comma
        if(textField.text.length == 0) {
            textField.text = @"0.";
            return NO;
        }
        
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@"."];
        return NO;
    }
    
    //for post decimal characters limitation
    NSArray *arrayOfSubStrings = [textField.text componentsSeparatedByString:@"."];
    NSRange rangeOfDot = [textField.text rangeOfString:@"."];
    
    if (arrayOfSubStrings.count > 1 && string.length > 0) {
        NSString *stringPostDecimal = arrayOfSubStrings.lastObject;
        if (stringPostDecimal.length > 1 && rangeOfDot.location < range.location) {
            return NO;
        }
    }
    
    return YES;
}

- (void) updateCurrencyTextFieldIfNeeded:(UITextField *)textField {
    if (textField.text.length == 0 || [textField.text isEqualToString:@"0"]) return;
    
    if ([textField.text rangeOfString:@"."].location != NSNotFound) {
        NSArray *arrayOfSubStrings = [textField.text componentsSeparatedByString:@"."];
        
        if (arrayOfSubStrings.count > 1) {
            NSString *stringBeforeDecimal = arrayOfSubStrings[0];
            NSString *stringPostDecimal = arrayOfSubStrings[1];
            
            if ([stringBeforeDecimal isEqualToString:@""]) {
                textField.text = @"";
            }else {
                if (stringPostDecimal.length == 0) {
                    textField.text = [NSString stringWithFormat:@"%@00", textField.text];
                }else if (stringPostDecimal.length == 1){
                    textField.text = [NSString stringWithFormat:@"%@0", textField.text];
                }
            }
        }
    }else {
        textField.text = [NSString stringWithFormat:@"%@.00", textField.text];
    }
}

@end
