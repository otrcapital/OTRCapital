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

@interface AdvanceLoanViewController ()
{
    NSMutableArray *muary_Interest_Main;
    NSMutableArray *muary_Interest_Sub;
    UITableView *tbl_Search;
    UITapGestureRecognizer *tapper;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *lblBrokerName;
@property (strong, nonatomic) IBOutlet UITextField *txtFdBrokerName;
@property (strong, nonatomic) IBOutlet UITextField *txtFdLoadNo;
@property (strong, nonatomic) IBOutlet UITextField *txtFdTotalPay;
@property (strong, nonatomic) IBOutlet UITextField *txtFdTotalDeduction;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIView *viewTotalPay;
@property (strong, nonatomic) IBOutlet UIView *viewTotalDeduction;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) NSArray *brokerList;
@property int tblSearchX;
@property int tblSearchY;
@property int positionYTxtTotalPay;
@property int positionYTxtTotalDeduction;
@property CGSize sizeLblDescription;
@end

@implementation AdvanceLoanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 800);
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.title = @"Fuel Advance";
    self.txtFdBrokerName.delegate = self;
    self.txtFdLoadNo.delegate = self;
    self.txtFdTotalPay.delegate = self;
    self.txtFdTotalDeduction.delegate = self;
    self.lblDescription.text = @"";
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
    
    self.positionYTxtTotalPay = self.viewTotalPay.frame.origin.y;
    self.positionYTxtTotalDeduction = self.viewTotalDeduction.frame.origin.y;
    self.sizeLblDescription = self.lblDescription.frame.size;
    
    if (self.data && [self.data objectForKey:@"Name"]) {
        self.txtFdBrokerName.text = [self.data objectForKey:@"Name"];
    }
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.lblDescription.text = @"";
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
    
    self.lblDescription.text = @"";
    
    CGRect frameRect = self.viewTotalPay.frame;
    frameRect.origin.y = self.positionYTxtTotalPay;
    self.viewTotalPay.frame = frameRect;
    
    frameRect = self.viewTotalDeduction.frame;
    frameRect.origin.y = self.positionYTxtTotalDeduction;
    self.viewTotalDeduction.frame = frameRect;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
    self.lblDescription.text = @"";
    
    CGRect frameRect = self.viewTotalPay.frame;
    frameRect.origin.y = self.positionYTxtTotalPay;
    self.viewTotalPay.frame = frameRect;
    
    frameRect = self.viewTotalDeduction.frame;
    frameRect.origin.y = self.positionYTxtTotalDeduction;
    self.viewTotalDeduction.frame = frameRect;
    
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
        self.lblDescription.text = @"";
    }
    else if (textField == self.txtFdLoadNo) {
        self.lblDescription.text = @"";
    }
    else if (textField == self.txtFdTotalPay) {
        CGRect frameRect = self.viewTotalPay.frame;
        frameRect.origin.y += self.lblDescription.frame.size.height;
        self.viewTotalPay.frame = frameRect;
        
        frameRect = self.viewTotalDeduction.frame;
        frameRect.origin.y += self.lblDescription.frame.size.height;
        self.self.viewTotalDeduction.frame = frameRect;
        
        self.lblDescription.text = @"Add together anything that will add to the total pay such as line haul, lumper fees, detention etc.";
        frameRect.origin.y = self.positionYTxtTotalPay - 10;
        frameRect.origin.x = self.lblDescription.frame.origin.x;
        frameRect.size = self.sizeLblDescription;
        self.lblDescription.frame = frameRect;
    }
    else if (textField == self.txtFdTotalDeduction) {
        
        CGRect frameRect = self.viewTotalDeduction.frame;
        frameRect.origin.y += self.lblDescription.frame.size.height;
        self.viewTotalDeduction.frame = frameRect;
        
        self.lblDescription.text = @"Add together anything that will decrease total pay such as advances, fees, late delivery, etc.";
        frameRect.origin.y = self.positionYTxtTotalDeduction - 10;
        frameRect.origin.x = self.lblDescription.frame.origin.x;
        frameRect.size = self.sizeLblDescription;
        self.lblDescription.frame = frameRect;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.center = self.originalCenter;
    tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
    
    self.lblDescription.text = @"";
    
    CGRect frameRect = self.viewTotalPay.frame;
    frameRect.origin.y = self.positionYTxtTotalPay;
    self.viewTotalPay.frame = frameRect;
    
    frameRect = self.viewTotalDeduction.frame;
    frameRect.origin.y = self.positionYTxtTotalDeduction;
    self.viewTotalDeduction.frame = frameRect;
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

- (void)imagePickerDidChooseImage: (UIImage *)image andWithViewController: (UIViewController*) controller
{
    [[OTRManager sharedManager] saveImage:image];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumentOptionalPropertiesViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DocumentOptionalPropertiesViewController"];
    [vc initAdvanceLoan];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)openScanPickerWithSourceType:(MAImagePickerControllerSourceType*)sourceType {
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
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:totalPay forKey:KEY_INVOICE_AMOUNT];
    [[OTRManager sharedManager] setOTRInfoValueOfTypeString:totalDeduction forKey:KEY_ADV_REQ_AMOUT];
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
