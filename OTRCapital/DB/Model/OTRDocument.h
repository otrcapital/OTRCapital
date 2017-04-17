//
//  OTRDocument.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 14.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class OTRCustomer;

static NSString *OTRDocumentDataTypeFac = @"FAC";

static NSString *OTRDocumentDataTypeADV = @"ADV";


@interface OTRDocument : NSManagedObject

@property (nonatomic, strong) NSNumber  *documentId;
@property (nonatomic, strong) NSString  *advanceRequestType;
@property (nonatomic, strong) NSString  *factorType;
@property (nonatomic, strong) NSArray   *imageUrls;
@property (nonatomic, strong) NSString  *invoiceAmount;
@property (nonatomic, strong) NSString  *loadNumber;
@property (nonatomic, strong) NSArray   *documentTypes;
@property (nonatomic, strong) NSString  *broker_name;
@property (nonatomic, strong) NSString  *broker_mc_number;
@property (nonatomic, strong) NSString  *adv_req_amount;
@property (nonatomic, strong) NSString  *customerPhoneNumber;
@property (nonatomic, strong) NSString  *folderPath;
@property (nonatomic, strong) NSNumber  *broker_pkey;
@property (nonatomic, strong) NSNumber  *totalPay;
@property (nonatomic, strong) NSNumber  *totalDeduction;
@property (nonatomic, strong) NSDate    *date;


+ (id)unassotiatedObject;

@end
