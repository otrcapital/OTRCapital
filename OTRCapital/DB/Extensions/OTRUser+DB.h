//
//  OTRUser+DB.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 20.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OTRUser.h"

@interface OTRUser (Database)

+ (OTRUser *)currentUser;

+ (void)logOut;

+ (BOOL)isAuthorized;

+ (NSString *)getEmail;

+ (NSString *)getEncodedPassword;

+ (NSString*)getPasswordDecoded;

@end
