//
//  OTRDefaults.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRDefaults.h"

@implementation OTRDefaults

+ (void)saveString:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

+ (NSString*)getStringForKey:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults valueForKey:key];
    return value;
}

+ (NSString*)getUserName{
    return [OTRDefaults getStringForKey:KEY_LOGIN_USER_NAME];
}

+ (NSString*)getPasswrodEncoded{
    return [OTRDefaults getStringForKey:KEY_LOGIN_PASSWORD];
}

+ (NSString*)getPasswordDecoded {
    NSString *encodedPassword = [OTRDefaults getStringForKey:KEY_LOGIN_PASSWORD];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedPassword options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}


+ (void)saveRecordFetchDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd"];
    NSString *currentDate = [df stringFromDate:yesterday];
    [OTRDefaults saveString:currentDate forKey:KEY_OTR_RECORD_FETCH_DATE];
}



@end
