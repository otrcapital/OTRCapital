//
//  CrashlyticsManager.m
//  OTRCapital
//
//  Copyright (c) 2016 OTRCapital LLC. All rights reserved.
//

#import "CrashlyticsManager.h"

@implementation CrashlyticsManager

+ (id) sharedManager {
    static CrashlyticsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)setUserEmail:(NSString *)email {
    [CrashlyticsKit setUserEmail:email];
}

- (void)setUserWithId: (NSString *)userId andName:(NSString *)userName {
    [CrashlyticsKit setUserIdentifier:userId];
    [CrashlyticsKit setUserName:userName];
}

- (void)logException:(NSError *)error {
    [[Crashlytics sharedInstance] recordError:error];
}


@end
