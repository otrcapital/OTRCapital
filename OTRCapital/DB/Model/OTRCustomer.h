//
//  OTRCustomer.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 13.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface OTRCustomer : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mc_number;
@property (nonatomic, retain) NSNumber *pkey;
@property (nonatomic, retain) NSNumber *factorable;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *phone;

@end

@interface OTRCustomerNote : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mc_number;
@property (nonatomic, retain) NSNumber *pkey;
@property (nonatomic, retain) NSNumber *factorable;

@end
