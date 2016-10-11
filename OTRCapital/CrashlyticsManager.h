//
//  CrashlyticsManager.h
//  OTRCapital
//
//  Copyright (c) 2016 OTRCapital LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>

@interface CrashlyticsManager : NSObject

+ (id)sharedManager;

- (void) setUserEmail: (NSString *)email;
- (void) setUserWithId: (NSString *)userId andName:(NSString *)userName;
- (void) logException: (NSError *)error;

- (void) trackUserLoginWithEmail: (NSString *)email andSuccess:(BOOL)success;

@end
