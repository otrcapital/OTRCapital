//
//  OTRNote.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 10.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRNote.h"

@implementation OTRNote

+ (instancetype)createFromInfo:(NSDictionary *)info {
    OTRNote *note = [OTRNote new];
    [note fillWithOtrData:info];
    return note;
}

- (void)fillWithOtrData:(NSDictionary *)otrData {
    if (!otrData) return;
    
    self.otrDataFixed = otrData;
    NSString *title = [otrData objectForKey:KEY_BROKER_NAME];
    if(title) self.title = title;
    NSString *email = [otrData objectForKey:KEY_LOGIN_USER_NAME];
    if(email) self.email = email;
    NSString *status = [otrData objectForKey:KEY_OTR_INFO_STATUS];
    if(status) self.status = status;
    NSString *loadNo = [otrData objectForKey:KEY_LOAD_NO];
    if(loadNo) self.loadNo = loadNo;
    NSString *invoiceString = [otrData objectForKey:KEY_INVOICE_AMOUNT];
    self.invoiceAmount = invoiceString;
    NSString *advReqAmount = [otrData objectForKey:KEY_ADV_REQ_AMOUT];
    if (advReqAmount) {
        self.advReqAmount = advReqAmount;
    }
    
    NSNumber *dateValue = [otrData objectForKey:KEY_DATE];
    if (dateValue) {
        NSDate *date =  [NSDate dateWithTimeIntervalSince1970:[dateValue doubleValue]];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        self.time = dateString;
    }
}

@end
