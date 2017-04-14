//
//  OTRDocument.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 14.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface OTRDocument : NSManagedObject

@property (nonatomic, retain) NSString *advanceRequestType;
@property (nonatomic, retain) NSString *factorType;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *invoiceAmount;
@property (nonatomic, retain) NSString *loadNumber;
@property (nonatomic, retain) NSString *documentTypes;
@property (nonatomic, retain) NSNumber *totalPay;
@property (nonatomic, retain) NSNumber *totalDeduction;

+ (id)unassotiatedObject;

@end
