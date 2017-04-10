//
//  NSDictionary+OTRJSONString.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 10.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (OTRJSONString)

- (NSString*)jsonStringWithPrettyPrint:(BOOL) prettyPrint;
    
@end
