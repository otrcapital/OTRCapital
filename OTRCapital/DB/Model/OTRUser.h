//
//  OTRUser.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 20.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface OTRUser : NSManagedObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *passwordData;

@end
