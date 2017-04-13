//
//  OTRCustomer+DB.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 13.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OTRCustomer.h"

@interface OTRCustomer (Database)

+ (NSArray *)getNamesList;

+ (OTRCustomer *)getByName:(NSString *)name;

+ (OTRCustomer *)getByMCNumber:(NSString *)number;

@end
