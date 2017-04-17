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
#import <SDWebImage/UIImageView+WebCache.h>

@interface HistoryTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *loadNo;
@property (weak, nonatomic) IBOutlet UILabel *rate;

@property (weak, nonatomic) IBOutlet UIButton *btnResend;

- (IBAction)onResendButtonPressed:(id)sender;
- (IBAction)onDeleteButtonPressed:(id)sender;

@end

@implementation HistoryTableViewCell

- (void)setDocument:(OTRDocument *)document {
    _document = document;
    [self updateDocumentInfo];
}

- (void)updateDocumentInfo {
    
    if(!self.document) return;
    
    NSString *title = self.document.broker_name;
    NSString *email = @"3312 Email";
    NSString *imagePath = [self.document.imageUrls firstObject];
    NSString *status = @"3312 Status";
    NSString *loadNo = self.document.loadNumber;
    NSString *invoiceAmount = self.document.invoiceAmount;
    NSString *advReqAmount = self.document.advanceRequestType;
    NSString *dateString = self.document.date ? [NSDateFormatter localizedStringFromDate:self.document.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle] : @"";
    
    self.time.text = dateString;
    self.title.text = title;
    self.address.text = email;
    self.status.text = status ? [NSString stringWithFormat:@"status: %@", status] : @"";
    self.loadNo.text =  loadNo ? [NSString stringWithFormat:@"LoadNo: %@", loadNo] : @"";
    if (advReqAmount) {
        self.rate.text = invoiceAmount ? [NSString stringWithFormat:@"Invoice: %@, Advance: %@", invoiceAmount, advReqAmount] : [NSString stringWithFormat:@"Advance: %@", advReqAmount];
    }
    else {
        self.rate.text = invoiceAmount ?[NSString stringWithFormat:@"Invoice: %@", invoiceAmount] : @"";
    }

    [self.image setShowActivityIndicatorView:YES];
    [self.image setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.image sd_setImageWithURL:[NSURL fileURLWithPath:imagePath] placeholderImage:nil];
    
    if ([status isEqual:OTR_INFO_STATUS_SUCCESS]) {
        [self.btnResend setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)onResendButtonPressed:(id)sender {    
    if(self.delegate) {
        [self.delegate resendDocumentPress:self.document];
    }
}

- (IBAction)onDeleteButtonPressed:(id)sender {
    if(self.delegate) {
        [self.delegate deleteDocumentPress:self.document];
    }
}

- (IBAction)onEmailButtonPressed:(id)sender {
    if(self.delegate) {
        [self.delegate emailDocumentPressed:self.document];
    }
}


@end
