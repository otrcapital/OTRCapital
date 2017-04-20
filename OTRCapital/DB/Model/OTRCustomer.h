//
//  OTRCustomer.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 13.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface OTRCustomer : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mc_number;
@property (nonatomic, strong) NSNumber *pkey;
@property (nonatomic, strong) NSNumber *factorable;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *phone;

@end

@interface OTRCustomerNote : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mc_number;
@property (nonatomic, strong) NSNumber *pkey;
@property (nonatomic, strong) NSNumber *factorable;

@end
