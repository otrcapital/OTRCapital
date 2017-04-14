//
//  OTRDocument.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 14.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRDocument.h"

@implementation OTRDocument

@dynamic advanceRequestType;
@dynamic factorType;
@dynamic imageName;
@dynamic loadNumber;
@dynamic documentTypes;
@dynamic invoiceAmount;
@dynamic totalPay;
@dynamic totalDeduction;

+ (id)unassotiatedObject {
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(OTRDocument.class) inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
}

@end
