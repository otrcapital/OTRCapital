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

@end
