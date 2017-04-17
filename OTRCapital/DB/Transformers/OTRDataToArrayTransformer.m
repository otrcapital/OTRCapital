//
//  OTRDataToArrayTransformer.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 17.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRDataToArrayTransformer.h"

@implementation OTRDataToArrayTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if (value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSData class]])
        return value;
    
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value {
    return [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)value];
}

@end
