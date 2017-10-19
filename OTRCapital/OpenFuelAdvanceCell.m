//
//  OpenFuelAdvanceCell.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 19.10.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OpenFuelAdvanceCell.h"

@interface OpenFuelAdvanceCell ()

@property (strong, nonatomic) IBOutlet UILabel *lbBrokerName;
@property (strong, nonatomic) IBOutlet UILabel *lbLoadNumber;
@property (strong, nonatomic) IBOutlet UILabel *lbInvAmount;
@property (strong, nonatomic) IBOutlet UILabel *lbFuelAmount;
@property (strong, nonatomic) IBOutlet UILabel *lbDate;

@end

@implementation OpenFuelAdvanceCell

- (void)setLoadInfo:(OTRNote *)info {
    self.lbBrokerName.text = info.title;
    self.lbLoadNumber.text = info.loadNo;
    self.lbInvAmount.text = info.invoiceAmount;
    self.lbFuelAmount.text = info.advReqAmount;
    self.lbDate.text = info.time;
}

@end
