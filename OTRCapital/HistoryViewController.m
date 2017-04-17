//
//  HistoryViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "OTRManager.h"
#import "OTRNote.h"
#import "OTRDocument+DB.h"
#import "HistoryDetailViewController.h"
#import "OTRApi.h"

#define KEY_IMAGE       @"image"
#define KEY_TITLE       @"title"
#define KEY_EMAIL       @"email"
#define KEY_TIME        @"time"
#define KEY_STATUS      @"status"
#define KEY_DIR_PATH    @"dir_path"
#define KEY_DIR_CONTENT @"dir_content"
#define KEY_DIR_NAME    @"dir_name"

#define TAG_ALERT_VIEW_INFO_SEND_SUCCESS        1
#define TAG_ALERT_VIEW_CONFORM_DELETE           2

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface HistoryViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSMutableArray *mDocuments;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"History";
    
    self.mDocuments = [[OTRDocument list] mutableCopy];

//    for (int i = (int) filePathsArray.count - 1; i >= 0 ; i--) {
//        OTRNote *note = [OTRNote new];
//        NSString *folderName = [filePathsArray  objectAtIndex:i];
//        
//        note.folderName = folderName;
//        
//        NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", rootDirectoryPath, folderName];
//        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
//        
//        if (!directoryContent || directoryContent.count == 0) {
//            continue;
//        }
//        
//        note.directoryPath = directoryPath;
//        note.directoryContents = directoryContent;
//        
//        NSString *imagePath = nil;
//        @try {
//            imagePath = [NSString stringWithFormat:@"%@/%@", directoryPath,[directoryContent objectAtIndex:0]];
//        } @catch (NSException *exception) {}
//        
//        if (imagePath) {
//            note.imagePath = imagePath;
//        }
//        
//        NSDictionary *otrData = [[OTRManager sharedManager] getOtrInfoWithKey:folderName];
//        if (otrData) {
//            note.otrDataFixed = otrData;
//            NSString *title = [otrData objectForKey:KEY_BROKER_NAME];
//            if(title) note.title = title;
//            NSString *email = [otrData objectForKey:KEY_LOGIN_USER_NAME];
//            if(email) note.email = email;
//            NSString *status = [otrData objectForKey:KEY_OTR_INFO_STATUS];
//            if(status) note.status = status;
//            NSString *loadNo = [otrData objectForKey:KEY_LOAD_NO];
//            if(loadNo) note.loadNo = loadNo;
//            NSString *invoiceString = [otrData objectForKey:KEY_INVOICE_AMOUNT];
//            note.invoiceAmount = invoiceString;
//            NSString *advReqAmount = [otrData objectForKey:KEY_ADV_REQ_AMOUT];
//            if (advReqAmount) {
//                note.advReqAmount = advReqAmount;
//            }
//        }
//        
//        NSDate *date =  [NSDate dateWithTimeIntervalSince1970:[folderName doubleValue]];
//        NSString *dateString = [NSDateFormatter localizedStringFromDate:date
//                                                              dateStyle:NSDateFormatterShortStyle
//                                                              timeStyle:NSDateFormatterShortStyle];
//        note.time = dateString;
//        
//        [tableData addObject:note];
//    }
    [self.tableView reloadData];
}

- (void) removeDataOfIndex: (NSInteger)index{
    if(index < self.mDocuments.count) {
        OTRDocument *document = self.mDocuments[index];
        [document MR_deleteEntity];
    }
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mDocuments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"HistoryTableViewCell";
    
    HistoryTableViewCell *cell = (HistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:simpleTableIdentifier owner:self options:nil] firstObject];
    }
    
    cell.document = self.mDocuments[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTRDocument *document = self.mDocuments[indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HistoryDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"HistoryDetailViewController"];
    
    NSMutableArray *imagesArray = [NSMutableArray new];
    for (NSString *imagePath in document.imageUrls) {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if(image) {
            [imagesArray addObject:image];
        }
    }
    [vc setItems:imagesArray];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showAlertViewWithTitle:(NSString *)title andWithMessage:(NSString *)msg andWithTag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)showOptionAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*)msg andWithTag: (int) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO", nil];
    [alert setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}



#pragma mark - HistoryTableViewCellDelegate


- (void)emailDocumentPressed:(OTRDocument *)document {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (!mc) return;
    
    NSData *pdfFile = [[OTRManager sharedManager] makePDFOfImagesOfFolder:document.folderPath];
    NSString *email = [[OTRManager sharedManager] getUserName];
    NSArray *toRecipents = [NSArray arrayWithObject:email];
    
    [[OTRHud hud] show];
    
    NSString *brokerName = document.broker_name;
    NSString *loadNo = document.loadNumber;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.pdf", brokerName, loadNo];
    
    [mc addAttachmentData:pdfFile mimeType:@"application/pdf" fileName:fileName];
    mc.mailComposeDelegate = self;
    [mc setToRecipients:toRecipents];
    NSString *subject = [NSString stringWithFormat:@"OTR Capital Document | Broker Name: %@ | Load No: %@", brokerName, loadNo];
    [mc setSubject:subject];
    //NSString *body = [self.otrInfo jsonStringWithPrettyPrint:NO];
    [mc setMessageBody:@"3312 Body???" isHTML:NO];
    [self.navigationController presentViewController:mc animated:YES completion:NULL];
    
}

- (void)deleteDocumentPress:(OTRDocument *)document {
    [self showOptionAlertViewWithTitle:@"Warning" andWithMessage:@"Are you sure, you want to delete it?" andWithTag:TAG_ALERT_VIEW_CONFORM_DELETE];
}

- (void)resendDocumentPress:(OTRDocument *)document {
    [[OTRHud hud] show];
    
    NSData *pdfFile = [[OTRManager sharedManager] makePDFOfImagesOfFolder:document.folderPath];
    
    [[OTRApi instance] sendDataToServer:document withPDF:pdfFile completionBlock:^(NSDictionary *responseData, NSError *error) {
        
        [[OTRHud hud] hide]; //3312
        
//        if(!error) {
//            [self.otrInfo setValue:OTR_INFO_STATUS_SUCCESS forKey:KEY_OTR_INFO_STATUS];
//            [[OTRManager sharedManager] updateOTRInfo:self.otrInfo forKey:self.directoryName];
//            [self.btnResend setHidden:YES];
//            [self.parent refreshView];
//            NSString *msg = [NSString stringWithFormat:@"Information is successfuly posted to server."];
//            [self showAlertViewWithTitle:@"Success" andWithMessage:msg andWithTag:TAG_ALERT_VIEW_INFO_SEND_SUCCESS];
//        }else {
//            [self.otrInfo setValue:OTR_INFO_STATUS_FAILED forKey:KEY_OTR_INFO_STATUS];
//            [[OTRManager sharedManager] updateOTRInfo:self.otrInfo forKey:self.directoryName];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
//                                                            message:error.localizedDescription
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles: nil];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [alert show];
//            });
//        }
    }];
}


#pragma mark - MFMailComposeViewControllerDelegate


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    [[OTRHud hud] hide];
    
    switch (result) {
        case MFMailComposeResultCancelled:
        case MFMailComposeResultSaved:
        case MFMailComposeResultFailed:
            [self showAlertViewWithTitle:@"Failed" andWithMessage:@"Email send failed." andWithTag:-1];
            break;
        case MFMailComposeResultSent:
            [self showAlertViewWithTitle:@"Success" andWithMessage:@"Information is successfuly emailed" andWithTag:-1];
            break;
        default:
            break;
    }
}


#pragma mark - UIAlertViewDelegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int tag = (int) alertView.tag;
    if (tag == TAG_ALERT_VIEW_CONFORM_DELETE && buttonIndex == 0) {
        [self removeDataOfIndex: buttonIndex];
    }
}



@end
