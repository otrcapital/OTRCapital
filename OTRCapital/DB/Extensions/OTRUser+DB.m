//
//  OTRUser+DB.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 20.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRUser+DB.h"

@implementation OTRUser (Database)

+ (OTRUser *)currentUser {
    return [OTRUser MR_findFirst];
}

+ (BOOL)isAuthorized {
    return [OTRUser currentUser] != nil;
}

+ (void)logOut {
    [OTRUser MR_truncateAll];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (NSString *)getEmail {
    return [OTRUser currentUser] ? [OTRUser currentUser].email : nil;
}

+ (NSString *)getEncodedPassword {
    return [OTRUser currentUser] ? [OTRUser currentUser].passwordData : nil;
}

+ (NSString*)getPasswordDecoded {
    NSString *encodedPassword = [OTRUser getEncodedPassword];
    
    if(!encodedPassword) return nil;
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedPassword options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

@end
