//
//  HistoryTableViewCell.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "HistoryTableViewCell.h"
#include "HistoryDetailViewController.h"
#import "NSDictionary+OTRJSONString.h"
#import "OTRApi.h"

#define TAG_ALERT_VIEW_INFO_SEND_SUCCESS        1
#define TAG_ALERT_VIEW_INFO_SEND_FAIL           2
#define TAG_ALERT_VIEW_CONFORM_DELETE           3

@interface HistoryTableViewCell ()
@property (strong, nonatomic) IBOutlet UIButton *btnResend;
- (IBAction)onResendButtonPressed:(id)sender;
- (IBAction)onDeleteButtonPressed:(id)sender;

@end

@implementation HistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.cellButton addGestureRecognizer:longPress];
}


- (void) initCellInfo{
    NSString *status = [self.otrInfo objectForKey:KEY_OTR_INFO_STATUS];
    if ([status isEqual:OTR_INFO_STATUS_SUCCESS]) {
        [self.btnResend setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
    }
}

- (IBAction)onCellClicked:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HistoryDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"HistoryDetailViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    NSMutableArray *imagesArray = [NSMutableArray new];
    for (NSString *item in self.directoryContents) {
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@", self.directoryPath, item];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if(image) {
            [imagesArray addObject:image];
        }
    }
    [vc setItems:imagesArray];
    
    [self.parentNavigationController pushViewController:vc animated:YES];
}

- (IBAction)onResendButtonPressed:(id)sender {    
    [[OTRHud hud] show];
    
    NSData *pdfFile = [[OTRManager sharedManager] makePDFOfImagesOfFolder:self.directoryName];

    [[OTRApi instance] sendDataToServer:self.otrInfo withPDF:pdfFile completionBlock:^(NSDictionary *responseData, NSError *error) {
        
        [[OTRHud hud] hide];
        
        if(!error) {
            [self.otrInfo setValue:OTR_INFO_STATUS_SUCCESS forKey:KEY_OTR_INFO_STATUS];
            [[OTRManager sharedManager] updateOTRInfo:self.otrInfo forKey:self.directoryName];
            [self.btnResend setHidden:YES];
            [self.parent refreshView];
            NSString *msg = [NSString stringWithFormat:@"Information is successfuly posted to server."];
            [self showAlertViewWithTitle:@"Success" andWithMessage:msg andWithTag:TAG_ALERT_VIEW_INFO_SEND_SUCCESS];
        }else {
            [self.otrInfo setValue:OTR_INFO_STATUS_FAILED forKey:KEY_OTR_INFO_STATUS];
            [[OTRManager sharedManager] updateOTRInfo:self.otrInfo forKey:self.directoryName];
            NSString *errorMessage = [NSString stringWithFormat:@"%@ Press \"OK\" to save it for later try or press \"Retry\" to try again.", error.localizedDescription];
            [self showOptionAlertViewWithTitle:@"Failed" andWithMessage:errorMessage andWithTag:TAG_ALERT_VIEW_INFO_SEND_FAIL];
        }
    }];
}

- (IBAction)onDeleteButtonPressed:(id)sender {
    [self showOptionAlertViewWithTitle:@"Warning" andWithMessage:@"Are you sure, you want to delete it?" andWithTag:TAG_ALERT_VIEW_CONFORM_DELETE];
}
- (IBAction)onEmailButtonPressed:(id)sender {
    [self emailDocument];
}

- (void) emailDocument {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (mc)
    {
        NSData *pdfFile = [[OTRManager sharedManager] makePDFOfImagesOfFolder:self.directoryName];
        NSString *email = [[OTRManager sharedManager] getUserName];
        NSArray *toRecipents = [NSArray arrayWithObject:email];

        [[OTRHud hud] show];
        
        NSString *brokerName = [self.otrInfo objectForKey:KEY_BROKER_NAME];
        NSString *loadNo = [self.otrInfo objectForKey:KEY_LOAD_NO];
        NSString *fileName = [NSString stringWithFormat:@"%@_%@.pdf", brokerName, loadNo];
        
        [mc addAttachmentData:pdfFile mimeType:@"application/pdf" fileName:fileName];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        NSString *subject = [NSString stringWithFormat:@"OTR Capital Document | Broker Name: %@ | Load No: %@", brokerName, loadNo];
        [mc setSubject:subject];
        NSString *body = [self.otrInfo jsonStringWithPrettyPrint:NO];
        [mc setMessageBody:body isHTML:NO];
        [self.parentNavigationController presentViewController:mc animated:YES completion:NULL];
    }
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.parentNavigationController dismissViewControllerAnimated:YES completion:NULL];
    [[OTRHud hud] hide];
    switch (result)
    {
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


#pragma mark PRIVATE METHODS
- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg andWithTag: (int) tag{
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

- (void) showOptionAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg andWithTag: (int) tag{
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

#pragma mark ALERT VIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int tag = (int) alertView.tag;
    if (tag == TAG_ALERT_VIEW_CONFORM_DELETE && buttonIndex == 0) {
        [self.parent removeDataOfIndex:self.index];
    }
}
@end
