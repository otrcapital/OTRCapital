//
//  OTRCustomer+DB.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 13.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRCustomer+DB.h"

@implementation OTRCustomer (Database)

+ (NSArray *)getNamesList {
    NSArray *array = [OTRCustomer MR_findAll];
    NSMutableArray *mReturnArray = [NSMutableArray new];
    
    for(OTRCustomer *item in array) {
        [mReturnArray addObject:item.name];
    }
    return mReturnArray;
}

+ (NSArray *)getFactorableNamesList {
    NSArray *array = [OTRCustomer MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"factorable == 1"]];
    NSMutableArray *mReturnArray = [NSMutableArray new];
    
    for(OTRCustomer *item in array) {
        [mReturnArray addObject:item.name];
    }
    return mReturnArray;
}

+ (OTRCustomer *)getByName:(NSString *)name {
    return [OTRCustomer MR_findFirstByAttribute:@"name" withValue:name];
}

+ (OTRCustomer *)getByMCNumber:(NSString *)number {
    return [OTRCustomer MR_findFirstByAttribute:@"mc_number" withValue:number];
}

@end
