//
//  OTRDocument.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 14.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class OTRCustomer;

static const

@interface OTRDocument : NSManagedObject

@property (nonatomic, retain) NSNumber *documentId;
@property (nonatomic, retain) NSString *advanceRequestType;
@property (nonatomic, retain) NSString *factorType;
@property (nonatomic, retain) NSArray  *imageUrls;
@property (nonatomic, retain) NSString *invoiceAmount;
@property (nonatomic, retain) NSString *loadNumber;
@property (nonatomic, retain) NSString *documentTypes;
@property (nonatomic, retain) NSString *broker_name;
@property (nonatomic, retain) NSString *broker_mc_number;
@property (nonatomic, retain) NSString *customerPhoneNumber;
@property (nonatomic, retain) NSNumber *broker_pkey;
@property (nonatomic, retain) NSNumber *totalPay;
@property (nonatomic, retain) NSNumber *totalDeduction;

+ (id)unassotiatedObject;

@end
