//
//  NSDictionary+OTRJSONString.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 10.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "NSDictionary+OTRJSONString.h"

@implementation NSDictionary (OTRJSONString)

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        DLog(@"%@", [NSString stringWithFormat: @"jsonStringWithPrettyPrint: error: %@", error.localizedDescription]);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
