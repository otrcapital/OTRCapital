//
//  DBHelper.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 13.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

+ (id)instance {
    static DBHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init{
    if ([super init]) {
        [MagicalRecord setupCoreDataStack];
    }
    return self;
}


@end
