//
//  DocumentOptionalPropertiesViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "DocumentOptionalPropertiesViewController.h"
#import "OTRManager.h"
#import "ImageAdjustmentViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"

#define TAG_ALERT_VIEW_INFO_SEND_SUCCESS        1
#define TAG_ALERT_VIEW_INFO_SEND_FAIL           2
#define TAG_ALERT_VIEW_INFO_MISSING             3

@interface DocumentOptionalPropertiesViewController ()
{
    NSMutableArray *muary_Interest_Main;
    NSMutableArray *muary_Interest_Sub;
    UITableView *tbl_Search;
    UITapGestureRecognizer *tapper;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *lblBrokerName;
@property (strong, nonatomic) IBOutlet UITextField *txtFdBrokerName;
@property (strong, nonatomic) IBOutlet UITextField *txtFdLoadNumber;
@property (strong, nonatomic) IBOutlet UISwitch *lf_switchProofOfDelivery;
@property (strong, nonatomic) IBOutlet UISwitch *lf_switchOthers;
@property (strong, nonatomic) IBOutlet UISwitch *lf_switchRateConformation;
@property (strong, nonatomic) IBOutlet UISwitch *ad_switchBillOfLanding;
@property (strong, nonatomic) IBOutlet UISwitch *ad_switchRateConformation;
@property (strong, nonatomic) IBOutlet UIView *viewLoadFactore;
@property (strong, nonatomic) IBOutlet UIView *viewAdvanceLoan;
@property (strong, nonatomic) IBOutlet UIButton *btnUploadDocument;

@property (weak) UITextField *activeField;

@property (nonatomic) CGPoint originalCenter;
@property BOOL isUploaded;
@property (nonatomic) NSArray *brokerList;
@property int tblSearchX;
@property int tblSearchY;

@property int type;

@end

@implementation DocumentOptionalPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Load Info";
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 300);
    self.txtFdBrokerName.enabled = false;
    self.txtFdLoadNumber.delegate = self;
    
    self.lf_switchOthers.on = false;
    self.ad_switchRateConformation.on = false;
    self.ad_switchBillOfLanding.on = false;
    self.lf_switchProofOfDelivery.on = false;
    self.lf_switchRateConformation.on = false;
    
    [self preLoadInfo];
    
    self.originalCenter = self.view.center;
    self.brokerList = [[OTRManager sharedManager] getBrokersList];
    
    tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    muary_Interest_Main = [NSMutableArray arrayWithArray:self.brokerList];
    muary_Interest_Sub = [[NSMutableArray alloc]init];
    
    self.tblSearchX = [self.lblBrokerName convertPoint:self.lblBrokerName.frame.origin toView:nil].x + 10;
    self.tblSearchY = [self.txtFdBrokerName convertPoint:self.txtFdBrokerName.frame.origin toView:self.view].y + self.txtFdBrokerName.frame.size.height;
    tbl_Search = [[UITableView alloc] initWithFrame:
                  CGRectMake(self.tblSearchX, self.tblSearchY, self.lblBrokerName.frame.size.width + self.txtFdBrokerName.frame.size.width * 1.15, 150) style:UITableViewStylePlain];
    tbl_Search.delegate = self;
    tbl_Search.dataSource = self;
    tbl_Search.scrollEnabled = YES;
    
    [tbl_Search registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:tbl_Search];
    [tbl_Search setHidden:TRUE];
    
    [self initSubView];
    
    [self registerForKeyboardNotifications];
}

- (void) viewDidAppear:(BOOL)animated{
    [[OTRManager sharedManager] setDelegate:self];
    [self.scrollView flashScrollIndicators];
}

- (void) viewWillDisappear:(BOOL)animated{
    [[OTRManager sharedManager] setDelegate:nil];
}

- (void) initSubView{
    if (self.type == 1) {
        [self.viewAdvanceLoan setHidden:true];
    }
    else{
        [self.viewLoadFactore setHidden:true];
        [self.btnUploadDocument setTitle:@"Request Fuel Advance" forState:UIControlStateNormal];
    }
}

- (void) dealloc{
    if (!self.isUploaded) {
        [[OTRManager sharedManager] deleteCurrentFoler];
    }
}

- (void) initLoadFactor{
    self.type = 1;
}
- (void) initAdvanceLoan{
    self.type = 2;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (!self.activeField) {
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 20, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y - kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
    [self.scrollView flashScrollIndicators];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:@"Begin"];
    }
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.center = self.originalCenter;
    tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
    self.activeField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
            tbl_Search.hidden = FALSE;
            tapper.enabled = NO;
            [tbl_Search reloadData];
        }
        else
        {
            tbl_Search.hidden = TRUE;
            tapper.enabled = YES;
        }
    }
    else
    {
        [tbl_Search setHidden:TRUE];
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

- (void)imagePickerDidChooseImage:(UIImage *)image andWithViewController: (UIViewController*) controller
{
    [[OTRManager sharedManager] incrementDocumentCount];
    [[OTRManager sharedManager] saveImage:image];
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onUploadDocumentButtonPressed:(id)sender {
    self.isUploaded = YES;
    if (![self isValidInfo]) {
        [self showAlertViewWithTitle:@"Information Missing" andWithMessage:@"Some of required fields are missing. You may have not selected any document type. Kindly correct it out to continue." andWithTag:TAG_ALERT_VIEW_INFO_MISSING];
    }
    else
    {
        CGPoint viewCenter = self.view.center;
        UIView *spinner = [[OTRManager sharedManager] getSpinnerViewBlockerWithPosition:viewCenter];
        [self.view addSubview:spinner];
        
        [self saveInfo];
        NSData *pdfFile = [[OTRManager sharedManager] makePDFOfCurrentImages];
        
        NSDictionary *otrInfo = [[OTRManager sharedManager] getOTRInfo];
        [[OTRManager sharedManager] sendDataToServer:otrInfo withPDF:pdfFile];
        
        NSString *email = [[OTRManager sharedManager] getStringForKey:KEY_LOGIN_USER_NAME];
        [[OTRManager sharedManager] setOTRInfoValueOfTypeString:email forKey:KEY_LOGIN_USER_NAME];
        [[OTRManager sharedManager] saveOTRInfo];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    switch (result)
    {
        case MFMailComposeResultCancelled:
        case MFMailComposeResultSaved:
        case MFMailComposeResultFailed:
            [self onOTRRequestFailWithError:nil];
            break;
        case MFMailComposeResultSent:
            [self onOTRRequestSuccessWithData:nil];
            break;
        default:
            break;
    }
}

- (IBAction)onScanMoreDocumentButtonPressed:(id)sender {
    [self checkForCameraPermission];
}

- (IBAction)onPhotoGalleryButtonPressed:(id)sender {
    [self checkForPhotoLibraryPermission];
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

- (void) preLoadInfo{
    NSString *brokerName = [[OTRManager sharedManager] getOTRInfoValueOfTypeStringForKey:KEY_BROKER_NAME];
    NSString *loadNo = [[OTRManager sharedManager] getOTRInfoValueOfTypeStringForKey:KEY_LOAD_NO];
    
    self.txtFdBrokerName.text = brokerName;
    self.txtFdLoadNumber.text = loadNo;
}

- (BOOL) isValidInfo{
    
    NSString *brokerName = self.txtFdBrokerName.text;
    NSString *loadNo = self.txtFdLoadNumber.text;
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
    BOOL isDocumentPropertySelected = NO;
    if(self.lf_switchProofOfDelivery.on
       || self.lf_switchOthers.on
       || self.lf_switchRateConformation.on
       || self.ad_switchBillOfLanding.on
       || self.ad_switchRateConformation.on)
    {
        isDocumentPropertySelected = YES;
    }
    
    BOOL isAllInfoValid = isValidBrokerName && isDocumentPropertySelected;
    
    return isAllInfoValid;
}

- (void) saveInfo{
    NSString *brokerName = self.txtFdBrokerName.text;
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:brokerName forKey:KEY_BROKER_NAME];
    NSString *loadNo = self.txtFdLoadNumber.text;
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:loadNo forKey:KEY_LOAD_NO];
    
    NSMutableArray *docTypes = [NSMutableArray new];
    if(self.lf_switchProofOfDelivery.on)[docTypes addObject:@"pod"];
    if(self.lf_switchOthers.on)[docTypes addObject:@"other"];
    if(self.lf_switchRateConformation.on)[docTypes addObject:@"rc"];
    if(self.ad_switchBillOfLanding.on)[docTypes addObject:@"bol"];
    if(self.ad_switchRateConformation.on)[docTypes addObject:@"rc"];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeArray:docTypes forKey:KEY_DOC_PROPERTY_TYPES_LIST];
}


#pragma mark OTRMANGER DELEGATE
- (void) onOTRRequestSuccessWithData:(NSDictionary *)data{
    [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
    
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:OTR_INFO_STATUS_SUCCESS forKey:KEY_OTR_INFO_STATUS];
    [[OTRManager sharedManager] saveOTRInfo];
    [self showAlertViewWithTitle:@"Success" andWithMessage:@"Information is successfuly posted to server." andWithTag:TAG_ALERT_VIEW_INFO_SEND_SUCCESS];
}
- (void) onOTRRequestFailWithError:(NSString *)error{
    [[OTRManager sharedManager] removeSpinnerViewBlockerFromView:self.view];
    
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:OTR_INFO_STATUS_FAILED forKey:KEY_OTR_INFO_STATUS];
    [[OTRManager sharedManager] saveOTRInfo];
    
    NSString *errorMessage = [NSString stringWithFormat:@"%@ Press \"OK\" to save it for later try or press \"Retry\" to try again.", error];
    
    [self showOptionAlertViewWithTitle:@"Failed" andWithMessage:errorMessage andWithTag:TAG_ALERT_VIEW_INFO_SEND_FAIL];
}

#pragma mark PRIVATE METHODS
- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg andWithTag: (int) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert setTag:tag];
    [alert show];
}

- (void) showOptionAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg andWithTag: (int) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Retry", nil];
    [alert setTag:tag];
    [alert show];
}

- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark ALERT VIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    int tag = (int) alertView.tag;
    if (tag == TAG_ALERT_VIEW_INFO_SEND_SUCCESS) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if (tag == TAG_ALERT_VIEW_INFO_SEND_FAIL) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            [self onUploadDocumentButtonPressed:nil];
        }
    }
}
@end
